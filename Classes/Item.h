#import "ObjectiveResource.h"

@interface Item : NSObject {
    NSString *itemId;
    NSString *todoId;
    NSString *content;
    NSDate   *updatedAt;
    NSDate   *createdAt;
}

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *todoId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

@end