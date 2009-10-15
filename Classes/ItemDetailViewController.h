#import <UIKit/UIKit.h>

@class Item;

@interface ItemDetailViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *nameField;
    UITextField *amountField;
    Item     *item;
}

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *amountField;
@property (nonatomic, retain) Item *item;

- (id)initWithItem:(Item *)item;

- (IBAction)save;
- (IBAction)cancel;

@end
