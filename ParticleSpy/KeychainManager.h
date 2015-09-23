#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject
+ (NSString *)readValueByKey:(NSString *)key;
+ (OSStatus)writeValue:(NSString *)value ByKey:(NSString *)key;
@end
