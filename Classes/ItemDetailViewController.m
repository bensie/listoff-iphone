#import "ItemDetailViewController.h"

#import "Item.h"
#import "Helpers.h"
#import "ConnectionManager.h"

@interface ItemDetailViewController ()
- (void)saveRemoteItem;
- (UITextField *)newContentField;
@end

@implementation ItemDetailViewController

@synthesize item;
@synthesize contentField;

- (id)initWithItem:(Item *)anItem {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.item = anItem;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.831 alpha:1.0];

    contentField = [self newContentField];
    [contentField becomeFirstResponder];
    
    UIBarButtonItem *cancelButton = [UIHelpers newCancelButton:self];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [UIHelpers newSaveButton:self];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];        
} 

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (item.itemId) {
        self.title = @"Edit Item";
        contentField.text = item.content;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.title = @"Add Item";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [contentField release];
    [item release];
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)save {
    item.content = contentField.text;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ConnectionManager sharedInstance] runJob:@selector(saveRemoteItem) 
                                      onTarget:self];
}

- (IBAction)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table methods

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = 
        [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                reuseIdentifier:nil] autorelease];

    [cell.contentView addSubview:contentField];
    
    return cell;
}

#pragma mark - 
#pragma mark Text Field Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
    [textField resignFirstResponder];
	[self save];
	return YES;
}    

- (IBAction)textFieldChanged:(id)sender {
    BOOL enableSaveButton = 
        ([self.contentField.text length] > 0);
    [self.navigationItem.rightBarButtonItem setEnabled:enableSaveButton];
}

#pragma mark -
#pragma mark Private methods

- (void)saveRemoteItem {
    // If the model is new, then create will be called.
    // Otherwise the model will be updated.
    NSError *error = nil;
    BOOL saved = [item saveRemoteWithResponse:&error];
    if (saved == YES) {
        [self.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) 
                                                    withObject:[NSNumber numberWithBool:YES] 
                                                 waitUntilDone:NO]; 
    } else {
        [UIHelpers handleRemoteError:error];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (UITextField *)newContentField {
    UITextField *field = [UIHelpers newTableCellTextField:self];
    field.placeholder = @"Enter data";
    field.keyboardType = UIKeyboardTypeASCIICapable;
    field.returnKeyType = UIReturnKeyNext;
    [field addTarget:self 
              action:@selector(textFieldChanged:) 
    forControlEvents:UIControlEventEditingChanged];
    return field;
}

@end
