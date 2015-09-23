#import <Foundation/Foundation.h>
#import "Spark-SDK.h"

@interface Device : NSObject
@property SparkDevice *photon;
@property SparkDeviceType type;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property BOOL connected;
@property (strong, nonatomic) NSArray *vars;

- (instancetype)initWithPhoton:(SparkDevice *)photon;
@end
