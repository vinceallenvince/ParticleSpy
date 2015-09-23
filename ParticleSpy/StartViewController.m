// TODO: create error manager
// TODO: create login manager

#import "StartViewController.h"
#import "CloudService.h"
#import "DevicesViewController.h"
#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "KeychainManager.h"

static int splashMargin = 40;
static int splashHeight = 120;
static int btnWidth = 100;
static int btnHeight = 44;

@interface StartViewController () <LoginDelegate>

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //
    
    // check defaults if touchid is enabled
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"touchid"]) {
    
        void (^getDevicesCompletion) (NSArray *devices, NSError *error) = ^(NSArray *devices, NSError *error) {
            if (!error) {
                DevicesViewController *devicesViewController = [[DevicesViewController alloc] init];
                devicesViewController.devices = devices;
                [self.navigationController pushViewController:devicesViewController animated:YES];
            } else {
                
                NSString *titleString = @"We experienced an error reading your devices.";
                NSString *messageString = [error localizedDescription];
                NSString *moreString = [error localizedFailureReason] ?
                [error localizedFailureReason] : @"";
                
                messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [errorAlert show];
            }
        };
        
        void (^loginBlock) (NSError *error) = ^(NSError *error) {
            if (!error) {
                NSLog(@"HERE!");
                [CloudService getDevices:getDevicesCompletion];
            } else {
                
                NSString *titleString = @"Wrong credentials or no internet connectivity, please try again.";
                NSString *messageString = [error localizedDescription];
                NSString *moreString = [error localizedFailureReason] ?
                [error localizedFailureReason] : @"";
                
                messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [errorAlert show];
            }
        };
        
        
        LAContext *myContext = [[LAContext alloc] init];
        
        NSError *authError = nil;
        NSString *myLocalizedReasonString = @"Press and hold to log in.";
        
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:myLocalizedReasonString
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        // User authenticated successfully, take appropriate action
                                        [[SparkCloud sharedInstance] loginWithUser:[KeychainManager readValueByKey:@"username"]
                                                                          password:[KeychainManager readValueByKey:@"password"]
                                                                        completion:loginBlock];
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self handleBtn];
                                        });
                                    }
                                }];
        } else { // Could not evaluate policy;

            NSString *titleString = @"Touch ID error.";
            NSString *messageString = [authError localizedDescription];
            NSString *moreString = [authError localizedFailureReason] ?
            [authError localizedFailureReason] : @"";
            
            messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlert show];
        }
        
    }

    
    //
    
    UIView *container = [[UIView alloc] init];
    [container setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:container];
    
    NSLayoutConstraint *horizontalConstraint;
    horizontalConstraint = [NSLayoutConstraint constraintWithItem:container
                                                      attribute:NSLayoutAttributeCenterX
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeCenterX
                                                     multiplier:1
                                                       constant:0];
    
    [self.view addConstraint:horizontalConstraint];
    
    NSLayoutConstraint *verticalConstraint;
    verticalConstraint = [NSLayoutConstraint constraintWithItem:container
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1
                                      constant:0];
    
    [self.view addConstraint:verticalConstraint];

    //
    
    UILabel *msg = [[UILabel alloc] init];
    [msg setTranslatesAutoresizingMaskIntoConstraints:NO];
    msg.text = @"Control your Particles.";
    msg.textAlignment = NSTextAlignmentCenter;
    [container addSubview:msg];
    
    //
    
    UIButton *btnStart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStart setTranslatesAutoresizingMaskIntoConstraints:NO];

    btnStart.backgroundColor = [UIColor whiteColor];
    btnStart.layer.cornerRadius = 6;
    
    [btnStart setTitle:@"Get Started"
                   forState:(UIControlState)UIControlStateNormal];
    
    [btnStart addTarget:self
                      action:@selector(handleBtn)
            forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    [container addSubview:btnStart];
    
    // Autolayout
    
    NSDictionary *metrics = @{@"buttonHeight":@44.0};
    NSDictionary *views = NSDictionaryOfVariableBindings(msg, btnStart);

    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[msg]-|"
                                                          options: 0
                                                          metrics:nil
                                                            views:views];
    [container addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[btnStart]-|"
                                                                   options: 0
                                                                   metrics:nil
                                                                     views:views];
    [container addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[msg]-15.0-[btnStart(buttonHeight)]-|"
                                                          options: NSLayoutFormatAlignAllCenterX
                                                          metrics:metrics
                                                            views:views];
    [container addConstraints:constraints];

}

- (void)handleBtn
{
    // show login modal
    /*LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:YES completion:nil];*/
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.delegate = self;
    
    /*UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];*/
    
    [self presentViewController:loginViewController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - LoginDelegate protocol

- (void)DidLoginWithDevices:(NSArray *)devices
{
    [self dismissViewControllerAnimated:YES completion: nil];
    
    DevicesViewController *devicesViewController = [[DevicesViewController alloc] init];
    devicesViewController.devices = devices;
    [self.navigationController pushViewController:devicesViewController animated:YES];
}

- (void)DidCancelLogin
{
    [self dismissViewControllerAnimated:YES completion: nil];
}


@end
