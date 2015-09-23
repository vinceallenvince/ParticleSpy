#import "LogoutViewController.h"
#import "Spark-SDK.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Logout";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    [self performSelector:@selector(logout) withObject:nil afterDelay:2];
}

- (void)logout
{
    [[SparkCloud sharedInstance] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
