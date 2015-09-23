#import <UIKit/UIKit.h>
#import "Spark-SDK.h"

/**
 * Creates a one-cell table view with refresh control to update cell value.
 */

@interface VarReadViewController : UITableViewController
@property (strong, nonatomic) SparkDevice *photon;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *val;
@property (strong, nonatomic) NSString *dataType;
@end
