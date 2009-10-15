#import <UIKit/UIKit.h>

@class Todo;

@interface TodoAddViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *nameField;
    UITextField *amountField;
    Todo *todo;
}

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *amountField;
@property (nonatomic, retain) Todo *todo;

- (id)initWithTodo:(Todo *)todo;

- (IBAction)save;
- (IBAction)cancel;

@end
