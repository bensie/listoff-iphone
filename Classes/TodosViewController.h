#import <UIKit/UIKit.h>

@class TodoTableCell;

@interface TodosViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *todos;
    UITableView *tableView;
}

@property (nonatomic, retain) NSArray *todos;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)add;
- (IBAction)refresh;

@end
