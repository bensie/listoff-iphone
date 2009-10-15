#import "TodosViewController.h"

#import "Todo.h"
#import "Helpers.h"
#import "ConnectionManager.h"
#import "TodoAddViewController.h"
#import "TodoDetailViewController.h"

@interface TodosViewController ()
- (void)fetchRemoteTodos;
- (UIBarButtonItem *)newAddButton;
- (void)showTodo:(Todo *)todo;
- (void)deleteRowsAtIndexPaths:(NSArray *)array;
- (void)destroyRemoteTodoAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TodosViewController

@synthesize todos;
@synthesize tableView;

#pragma mark -
#pragma mark Actions

- (IBAction)add {
    Todo *todo = [[Todo alloc] init];
    TodoAddViewController *controller = 
        [[TodoAddViewController alloc] initWithTodo:todo];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    [todo release];
}

- (IBAction)refresh {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ConnectionManager sharedInstance] runJob:@selector(fetchRemoteTodos) 
                                      onTarget:self];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"To-Do Lists";
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [self newAddButton];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [todos release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [todos count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    static NSString *TodoCellId = @"TodoCellId";
    
    UITableViewCell *cell = 
        [aTableView dequeueReusableCellWithIdentifier:TodoCellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:TodoCellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    Todo *todo = [todos objectAtIndex:indexPath.row];
    cell.textLabel.text = todo.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"(%d items)", 
								 [[todo findAllItems] count]];
    
    return cell;
}

-  (void)tableView:(UITableView *)aTableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView beginUpdates]; 
    if (editingStyle == UITableViewCellEditingStyleDelete) { 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[ConnectionManager sharedInstance] runJob:@selector(destroyRemoteTodoAtIndexPath:) 
                                          onTarget:self
                                      withArgument:indexPath];
    }
    [aTableView endUpdates]; 
} 

- (void)destroyRemoteTodoAtIndexPath:(NSIndexPath *)indexPath {
    Todo *todo = [todos objectAtIndex:indexPath.row];
    NSError *error = nil;
    BOOL destroyed = [todo destroyRemoteWithResponse:&error];
    if (destroyed == YES) {
        [todos removeObjectAtIndex:indexPath.row];
        [self performSelectorOnMainThread:@selector(deleteRowsAtIndexPaths:) 
                               withObject:[NSArray arrayWithObject:indexPath]  
                            waitUntilDone:NO];
    } else {    
        [UIHelpers handleRemoteError:error];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)array {
    [tableView deleteRowsAtIndexPaths:array
                     withRowAnimation:UITableViewRowAnimationFade]; 
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Todo *todo = [todos objectAtIndex:indexPath.row];
    [self showTodo:todo];
}

#pragma mark -
#pragma mark Private methods

- (void)fetchRemoteTodos {
    NSError *error = nil;
    self.todos = [Todo findAllRemoteWithResponse:&error];
    if (self.todos == nil && error != nil) {
        [UIHelpers handleRemoteError:error];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) 
                                     withObject:nil 
                                  waitUntilDone:NO]; 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showTodo:(Todo *)todo {
	TodoDetailViewController *controller = 
        [[TodoDetailViewController alloc] initWithTodo:todo];
	[self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (UIBarButtonItem *)newAddButton {
    return [[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                 target:self 
                                 action:@selector(add)];
}

@end
