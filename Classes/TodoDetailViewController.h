#import <UIKit/UIKit.h>

@class Todo;

@interface TodoDetailViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *nameField;
    Todo *todo;
    NSMutableArray *items;
}

@property (nonatomic, retain) Todo *todo;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITextField *nameField;

- (id)initWithTodo:(Todo *)todo;

@end
