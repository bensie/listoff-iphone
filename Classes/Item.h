#import "ObjectiveResource.h"

@interface Item : NSObject {
    NSString *itemId;
    NSString *todoId;
    NSString *name;
    NSString *amount;
    NSDate   *updatedAt;
    NSDate   *createdAt;
}

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *todoId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;
    
- (NSString *)amountAsCurrency;

@end