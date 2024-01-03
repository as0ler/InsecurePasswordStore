#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Credential : NSManagedObject

@property NSUInteger identifier;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * notes;

@end
