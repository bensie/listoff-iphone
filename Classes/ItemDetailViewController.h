#import <UIKit/UIKit.h>

@class Item;

@interface ItemDetailViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *contentField;
    Item     *item;
}

@property (nonatomic, retain) UITextField *contentField;
@property (nonatomic, retain) Item *item;

- (id)initWithItem:(Item *)item;

- (IBAction)save;
- (IBAction)cancel;

@end
