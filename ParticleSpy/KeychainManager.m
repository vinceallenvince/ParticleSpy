#import "KeychainManager.h"

@implementation KeychainManager

+ (NSString *)readValueByKey:(NSString *)key
{
    NSString *val;
    NSString *keyToSearchFor = key;
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    
    NSDictionary *query = @{
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService : service,
                            (__bridge id)kSecAttrAccount : keyToSearchFor,
                            (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue
                            };
    
    CFTypeRef cfValue = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&cfValue);
    
    if (status == errSecSuccess) {
        val = [[NSString alloc] initWithData:(__bridge_transfer NSData *)cfValue encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Failed to read key: %@ with code: %ld", key, (long)status);
    }

    return val;
}

+ (OSStatus)writeValue:(NSString *)value ByKey:(NSString *)key
{
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    
    NSDictionary *secItem = @{
                              (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                              (__bridge id)kSecAttrService : service,
                              (__bridge id)kSecAttrAccount : key,
                              (__bridge id)kSecValueData : valueData
                              };
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)secItem, &result);
    
    if (status == errSecSuccess) {
        NSLog(@"Successfully stored username.");
    } else {
        NSLog(@"Failed to store the value with code: %ld", (long)status);
    }

    return status;
}

@end
