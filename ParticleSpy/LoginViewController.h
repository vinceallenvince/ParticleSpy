#import <UIKit/UIKit.h>

@protocol LoginDelegate;

@interface LoginViewController : UIViewController
@property (nonatomic, weak) id<LoginDelegate> delegate;
@end

@protocol LoginDelegate <NSObject>
- (void)DidLoginWithDevices:(NSArray *)devices;
- (void)DidCancelLogin;
@end
