#import <UIKit/UIKit.h>

@protocol SettingsDelegate;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property BOOL isTouchID;
@property (nonatomic, weak) id<SettingsDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@protocol SettingsDelegate <NSObject>
- (void)DidCloseSettings;
@end