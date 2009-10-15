#import "Todo.h"

#import "Item.h"

@implementation Todo

@synthesize todoId;
@synthesize name;
@synthesize itemsCount;
@synthesize updatedAt;
@synthesize createdAt;

- (NSArray *)findAllItems {
	return [Item findRemote:[NSString stringWithFormat:@"%@/%@", 
                                todoId, @"items"]];
}

- (void) dealloc {
    [todoId release];
    [name release];
	[itemsCount release];
    [updatedAt release];
    [createdAt release];
	[super dealloc];
}

@end
