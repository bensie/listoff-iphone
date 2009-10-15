#import "ObjectiveResource.h"

@interface Todo : NSObject {
    NSString *todoId;
    NSString *name;
	NSString *itemsCount;
    NSDate   *updatedAt;
    NSDate   *createdAt;
}

@property (nonatomic, copy) NSString *todoId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *itemsCount;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

- (NSArray *)findAllItems;

@end