#import "Device.h"

@implementation Device

- (instancetype)initWithPhoton:(SparkDevice *)photon
{
    self = [super init];
    if (self) {
        self.photon = photon;
    }
    return self;
}

@end
