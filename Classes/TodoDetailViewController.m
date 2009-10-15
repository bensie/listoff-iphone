#import "TodoDetailViewController.h"

#import "Todo.h"
#import "Item.h"
#import "Helpers.h"
#import "ConnectionManager.h"
#import "ItemDetailViewController.h"

@interface TodoDetailViewController ()
- (void)fetchRemoteItems;
- (void)updateRemoteTodo;
- (void)deleteRowsAtIndexPaths:(NSArray *)array;
- (void)destroyRemoteItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)showItem:(Item *)item;
- (UITableViewCell *)makeItemCell:(UITableView *)tableView forRow:(NSUInteger)row;
- (UITableViewCell *)makeAddItemCell:(UITableView *)tableView forRow:(NSUInteger)row;
- (UITableViewCell *)makeTodoCell:(UITableView *)tableView forRow:(NSUInteger)row;
- (UITextField *)newNameField;
@end

@implementation TodoDetailViewController

@synthesize nameField;
@synthesize todo;
@synthesize items;

enum TodoDetailTableSections {
	kTodoSection = 0,
    kItemsSection
};

- (id)initWithTodo:(Todo *)aTodo {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.todo = aTodo;
    }
    
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.831 alpha:1.0];

    self.title = todo.name;
    
    nameField = [self newNameField];
    
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ConnectionManager sharedInstance] runJob:@selector(fetchRemoteItems) 
                                      onTarget:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [nameField release];
    [todo release];
    [items release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];

	nameField.enabled = editing;
    
	[self.tableView beginUpdates];
	
    NSUInteger itemsCount = [items count];
    
    NSArray *itemsInsertIndexPath = 
        [NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemsCount 
                                                    inSection:kItemsSection]];
    
    if (editing) {

        [self.tableView insertRowsAtIndexPaths:itemsInsertIndexPath 
                              withRowAnimation:UITableViewRowAnimationTop];
	} else {

        [self.tableView deleteRowsAtIndexPaths:itemsInsertIndexPath 
                              withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tableView endUpdates];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ConnectionManager sharedInstance] runJob:@selector(updateRemoteTodo) 
                                      onTarget:self];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == nameField) {
		todo.name = nameField.text;
		self.title = todo.name;
	}
	return YES;
}

#pragma mark -
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case kTodoSection:
            rows = 1;
            break;
        case kItemsSection:
            rows = [items count];
            if (self.editing) {
                rows++; // "Add Item" cell
            }
            break;
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
        case kTodoSection:
			title = @"List";
            break;
        case kItemsSection:
			title = @"Items";
            break;
	}
  	return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = nil;

    NSUInteger row = indexPath.row;

    // For the Items section, create a cell for each item.
    if (indexPath.section == kItemsSection) {
		NSUInteger itemsCount = [items count];
        if (row < itemsCount) {
            cell = [self makeItemCell:tableView forRow:row];
        } 
        // If the row is outside the range of the items, it's
        // the row that was added to allow insertion.
        else {
            cell = [self makeAddItemCell:tableView forRow:row];
        }
    }
    // For the Todo section, create a cell for each text field.
    else {
        cell = [self makeTodoCell:tableView forRow:row];
    }
    
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing && (indexPath.section == kItemsSection)) {
        return indexPath;
    }
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kItemsSection) {
        Item *item = nil;
        if (indexPath.row < [items count]) {
            item = [items objectAtIndex:indexPath.row];
        } else {
            item = [[[Item alloc] init] autorelease];
            item.todoId = todo.todoId;
        }
        [self showItem:item];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    // Only allow editing in the Items section.  The last row
    // was added automatically for adding a new item.  All
    // other rows are eligible for deletion.
    if (indexPath.section == kItemsSection) {
        if (indexPath.row == [items count]) {
            style = UITableViewCellEditingStyleInsert;
        } else {
            style = UITableViewCellEditingStyleDelete;
        }
    }    
    return style;
}

 - (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only allow deletion in the Items section.
    if ((editingStyle == UITableViewCellEditingStyleDelete) && 
        (indexPath.section == kItemsSection)) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[ConnectionManager sharedInstance] runJob:@selector(destroyRemoteItemAtIndexPath:) 
                                          onTarget:self
                                      withArgument:indexPath];
    }
}

- (void)destroyRemoteItemAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [items objectAtIndex:indexPath.row];
    NSError *error = nil;
    BOOL destroyed = [item destroyRemoteWithResponse:&error];
    if (destroyed == YES) {
        [items removeObjectAtIndex:indexPath.row];
        [self performSelectorOnMainThread:@selector(deleteRowsAtIndexPaths:) 
                               withObject:[NSArray arrayWithObject:indexPath]  
                            waitUntilDone:NO];
    } else {    
        [UIHelpers handleRemoteError:error];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)array {
    [self.tableView deleteRowsAtIndexPaths:array
                          withRowAnimation:UITableViewRowAnimationTop]; 
}

#pragma mark -
#pragma mark Private methods

- (void)fetchRemoteItems {
    self.items = [NSMutableArray arrayWithArray:[todo findAllItems]];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) 
                                     withObject:nil 
                                  waitUntilDone:NO]; 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)updateRemoteTodo {
    NSError *error = nil;
    BOOL updated = [todo updateRemoteWithResponse:&error];
    if (updated == NO) {
        [UIHelpers handleRemoteError:error];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showItem:(Item *)item {
    ItemDetailViewController *controller = 
    [[ItemDetailViewController alloc] initWithItem:item];
    controller.item = item;
    [self.navigationController pushViewController:controller animated:YES];	
    [controller release];
}

- (UITableViewCell *)makeItemCell:(UITableView *)tableView forRow:(NSUInteger)row {
    static NSString *ItemsCellId = @"ItemsCellId";
    
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:ItemsCellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:ItemsCellId] autorelease];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Item *item = [items objectAtIndex:row];
    cell.textLabel.text = item.content;
    return cell;
}

- (UITableViewCell *)makeAddItemCell:(UITableView *)tableView forRow:(NSUInteger)row {
    static NSString *AddItemCellId = @"AddItemCellId";
    
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:AddItemCellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:AddItemCellId] autorelease];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @"Add Item";   
    return cell;
}

- (UITableViewCell *)makeTodoCell:(UITableView *)tableView forRow:(NSUInteger)row {
    static NSString *TodoCellId = @"TodoCellId";
    
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:TodoCellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:TodoCellId] autorelease];
    }
    
    if (row == 0)  {
        [cell.contentView addSubview:nameField];	
    }
    
    return cell;
}

- (UITextField *)newNameField {
    UITextField *field = [UIHelpers newTableCellTextField:self];
    field.text = todo.name;
    field.returnKeyType = UIReturnKeyDone;
    field.enabled = NO;
    return field;
}

@end
