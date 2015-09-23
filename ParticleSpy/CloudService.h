#import <Foundation/Foundation.h>
#import "Spark-SDK.h"

typedef void (^ GetDevicesBlock)(NSArray *, NSError *);
typedef void (^ GetVariableBlock)(NSArray *result, NSError *error);

@interface CloudService : NSObject

+ (void)getDevices:(GetDevicesBlock)completionBlock;
+ (void)getVariable:(NSString *)key ForDevice:(SparkDevice *)device :(GetVariableBlock)completionBlock;

@end
