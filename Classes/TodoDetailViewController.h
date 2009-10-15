#import <UIKit/UIKit.h>

@class Todo;

@interface TodoDetailViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *nameField;
    UITextField *amountField;
    Todo *todo;
    NSMutableArray *items;
}

@property (nonatomic, retain) Todo *todo;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *amountField;

- (id)initWithTodo:(Todo *)todo;

@end
