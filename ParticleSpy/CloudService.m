#import "CloudService.h"
#import "Device.h"

//typedef void (^ IteratorBlock)(id, int);


@implementation CloudService

+ (void)getDevices:(GetDevicesBlock)completionBlock;
{
    void (^getDevicesBlock) (NSArray *sparkDevices, NSError *error) = ^(NSArray *sparkDevices, NSError *error) {
        
        NSMutableArray *devices = [[NSMutableArray alloc] init];
        
        for (SparkDevice *device in sparkDevices)
        {
            /*NSDictionary *myDeviceVariables = device.variables;
             NSLog(@"MyDevice first Variable is called %@ and is from type %@", myDeviceVariables.allKeys[0], myDeviceVariables.allValues[0]);*/
            
            /*Device *dev = [[Device alloc] initWithPhoton:device Type:device.type ID:device.id Name:device.name Connected:device.connected];*/
            
            Device *dev = [[Device alloc] initWithPhoton:device];
            dev.type = device.type;
            dev.id = device.id;
            dev.name = device.name;
            dev.connected = device.connected;
            
            NSDictionary *myDeviceVariables = device.variables;
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (NSString *var in myDeviceVariables.allKeys)
            {
                NSLog(@"%@", var);
                NSDictionary *item = @{var: [myDeviceVariables valueForKey:var]};
                [arr addObject:item];
            }
            
            dev.vars = [arr copy];
            
            [devices addObject:dev];
        }
        
        completionBlock([devices copy], error);

    };

    
    [[SparkCloud sharedInstance] getDevices:getDevicesBlock];
}

+ (void)getVariable:(NSString *)key ForDevice:(SparkDevice *)device :(GetVariableBlock)completionBlock
{
    [device getVariable:key completion:^(id result, NSError *error) {
        completionBlock(result, error);
    }];
}

@end
