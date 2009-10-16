#import "Item.h"

@implementation Item

@synthesize itemId;
@synthesize todoId;
@synthesize content;
@synthesize createdAt;
@synthesize updatedAt;

#pragma mark ObjectiveResource overrides to handle nested resources

+ (NSString *)getRemoteCollectionName {
	return @"todos";
}

- (NSString *)nestedPath {
	NSString *path = [NSString stringWithFormat:@"%@/items", todoId];
	if (itemId) {
		path = [path stringByAppendingFormat:@"/%@", itemId];
	}
	return path;
}

- (BOOL)createRemoteWithResponse:(NSError **)aError {
    return [self createRemoteAtPath:[[self class] getRemoteElementPath:[self nestedPath]] 
                       withResponse:aError];
}

- (BOOL)updateRemoteWithResponse:(NSError **)aError {
    return [self updateRemoteAtPath:[[self class] getRemoteElementPath:[self nestedPath]] 
                       withResponse:aError];
}

- (BOOL)destroyRemoteWithResponse:(NSError **)aError {
    return [self destroyRemoteAtPath:[[self class] getRemoteElementPath:[self nestedPath]] 
                        withResponse:aError];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [itemId release];
    [todoId release];
    [content release];
    [createdAt release];
    [updatedAt release];
	[super dealloc];
}

@end
