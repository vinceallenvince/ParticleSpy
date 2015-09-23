// TODO: use autolayout for form container
// TODO: add forgot password button
// X TODO: persist username in the same session
// X TODO: add spinner after clicking login button

#import "Security/Security.h"
#import "LoginViewController.h"
#import "DevicesViewController.h"
#import "Spark-SDK.h"
#import "Device.h"
#import "CloudService.h"
#import "KeychainManager.h"

static int formMargin = 40;
static int formHeight = 320;

struct txtField {
    UITextBorderStyle borderStyle;
    __unsafe_unretained NSString *placeholder;
    __unsafe_unretained NSString *text;
    UIReturnKeyType returnKeyType;
    BOOL enablesReturnKeyAutomatically;
    BOOL secureTextEntry;
};

@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *username;
@property (strong, nonatomic) UITextField *password;
@property (strong, nonatomic) UIButton *btnLogin;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *storedUsername;
@property (strong, nonatomic) NSString *storedPassword;
@property (strong, nonatomic) UIActivityIndicatorView *activitySpinner;
@end

@implementation LoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.storedUsername = [KeychainManager readValueByKey:@"username"];
        self.storedPassword = [KeychainManager readValueByKey:@"password"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancel)];
    
    //
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    int screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIView *form = [[UIView alloc] initWithFrame:CGRectMake(formMargin / 2,
                                                         screenHeight / 2 - formHeight / 2,
                                                         screenWidth - formMargin,
                                                         formHeight)];
    
    //form.backgroundColor = [UIColor grayColor];
    [self.view addSubview:form];
    
    
    UILabel *formTitle = [[UILabel alloc] init];
    [formTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    formTitle.text = @"Particle Login";
    formTitle.textAlignment = NSTextAlignmentCenter;
    //formTitle.backgroundColor = [UIColor redColor];
    
    [form addSubview:formTitle];
    
    //
    
    struct txtField usernameField = {
        UITextBorderStyleRoundedRect,
        @"username",
        self.storedUsername,
        UIReturnKeyDone,
        YES,
        NO
    };
    
    struct txtField passwordField = {
        UITextBorderStyleRoundedRect,
        @"password",
        self.storedPassword,
        UIReturnKeyDone,
        YES,
        YES
    };
    
    self.username = [self createTextField:usernameField];
    UITextField *username = self.username;
    [username setTranslatesAutoresizingMaskIntoConstraints:NO];
    [form addSubview:username];
    
    self.password = [self createTextField:passwordField];
    UITextField *password = self.password;
    [password setTranslatesAutoresizingMaskIntoConstraints:NO];
    [form addSubview:password];
    
    //
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnLogin setTranslatesAutoresizingMaskIntoConstraints:NO];
    btnLogin.backgroundColor = [UIColor whiteColor];
    btnLogin.layer.cornerRadius = 6;
    
    [btnLogin setTitle:@"Log in"
                   forState:(UIControlState)UIControlStateNormal];
    
    [btnLogin addTarget:self
                      action:@selector(handleBtn)
            forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    [form addSubview:btnLogin];
    
    
    // Autolayout
    
    NSDictionary *metrics = @{
                              @"padding": @12.0,
                              @"labelHeight": @44.0,
                              @"fieldHeight": @44.0,
                              @"buttonHeight":@44.0
                              };
    
    NSDictionary *views = NSDictionaryOfVariableBindings(formTitle, username, password, btnLogin);
    
    // formTitle
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[formTitle]-|"
                                                                   options: 0
                                                                   metrics:metrics
                                                                     views:views];
    [form addConstraints:constraints];
    
    
    // username
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[username]-|"
                                                                   options: 0
                                                                   metrics:metrics
                                                                     views:views];
    [form addConstraints:constraints];
    
    
    // password
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|"
                                                          options: 0
                                                          metrics:metrics
                                                            views:views];
    [form addConstraints:constraints];
    
    // btnLogin
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[btnLogin]-|"
                                                          options: 0
                                                          metrics:metrics
                                                            views:views];
    [form addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[formTitle(labelHeight)]-[username(fieldHeight)]-[password(fieldHeight)]-[btnLogin(buttonHeight)]"
                                                          options: NSLayoutFormatAlignAllCenterX
                                                          metrics:metrics
                                                            views:views];
    [form addConstraints:constraints];
    
    
    //
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                     [UIScreen mainScreen].bounds.size.height - 44,
                                                                     self.view.bounds.size.width,
                                                                     44)];
    
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancel)];
    [toolbar setItems:@[itemCancel]];
    
    
    [self.view addSubview:toolbar];
}

- (void)handleCancel
{
    [self.delegate DidCancelLogin];
}

- (void)handleForgotPassword
{
    NSLog(@"Forgot Password flow...");
}

- (UITextField *)createTextField:(struct txtField)params {
    
    UITextField *field = [[UITextField alloc] init];
    field.borderStyle = params.borderStyle;
    field.placeholder = params.placeholder;
    field.text = params.text; // remove
    field.returnKeyType = params.returnKeyType;
    field.enablesReturnKeyAutomatically = params.enablesReturnKeyAutomatically;
    field.secureTextEntry = params.secureTextEntry;
    field.delegate = self;
    return field;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)handleBtn
{
    void (^getDevicesCompletion) (NSArray *devices, NSError *error) = ^(NSArray *devices, NSError *error) {
        if (!error) {
            // remove secure info from the fields
            self.username.text = nil;
            self.password.text = nil;
            [self.delegate DidLoginWithDevices:devices];
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
            
            // save values to keychain
            // TODO: only save if stored values don't exist or different from existing values
            if (!self.storedUsername) {
                [KeychainManager writeValue:self.username.text ByKey:@"username"];
            } else if (self.storedUsername != self.username.text) {
                // TODO: update stored value
            }
            
            if (!self.storedPassword) {
                [KeychainManager writeValue:self.password.text ByKey:@"password"];
            } else if (self.storedPassword != self.password.text) {
                // TODO: update stored value
            }
            
            [CloudService getDevices:getDevicesCompletion];
        } else {
            
            NSString *titleString = @"Wrong credentials or no internet connectivity, please try again.";
            NSString *messageString = [error localizedDescription];
            NSString *moreString = [error localizedFailureReason] ?
                [error localizedFailureReason] : @"";
            
            messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlert show];
            
            [self.activitySpinner stopAnimating];
            [self.btnLogin setEnabled:YES];
        }
    };
    
    [[SparkCloud sharedInstance] loginWithUser:self.username.text
                                      password:self.password.text
                                    completion:loginBlock];
    
    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    
    [self.activitySpinner setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                           [UIScreen mainScreen].bounds.size.height/1.5)];
    [self.activitySpinner startAnimating];
    
    [self.view addSubview:self.activitySpinner];
    [self.btnLogin setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
