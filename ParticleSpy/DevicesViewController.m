#import "DevicesViewController.h"
#import "Device.h"
#import "VarsViewController.h"
#import "LogoutViewController.h"
#import "CloudService.h"
#import "SettingsViewController.h"

// TODO: get functions

@interface DevicesViewController () <SettingsDelegate>
@property (strong, nonatomic) UIBarButtonItem *settingsButton;
@property (strong, nonatomic) UIBarButtonItem *logoutButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation DevicesViewController

@dynamic refreshControl;

- (instancetype)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Devices";

    self.settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(settings:)];
    
    self.navigationItem.leftBarButtonItem = self.settingsButton;
    
    self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(logout:)];
    
    self.navigationItem.rightBarButtonItem = self.logoutButton;
    
    
    
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (![self.devices count]) {
        NSString *titleString = @"We experienced an error reading your devices.";
        NSString *messageString = @"Please check your Internet connection and try again.";
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [errorAlert show];
    }
    
    NSLog(@"%@", self.devices);
}

- (void)settings:(id)sender
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.delegate = self;
    
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (void)logout:(id)sender
{
    LogoutViewController *logoutViewController = [[LogoutViewController alloc] init];
    [self.navigationController pushViewController:logoutViewController animated:YES];
}

- (void)refreshTable
{
    void (^getDevicesCompletion) (NSArray *devices, NSError *error) = ^(NSArray *devices, NSError *error) {
        if (!error) {
            self.devices = devices;
            [self.tableView reloadData];
        } else {
            NSString *titleString = @"We experienced an error reading your devices.";
            NSString *messageString = [error localizedDescription];
            NSString *moreString = [error localizedFailureReason] ?
            [error localizedFailureReason] : @"";
            
            messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlert show];
        }
        [self.refreshControl endRefreshing];
    };
    
    [CloudService getDevices:getDevicesCompletion];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    Device *dev = self.devices[indexPath.row];    
    cell.textLabel.text = dev.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *dev = self.devices[indexPath.row];
    if (dev.connected) {
        cell.backgroundColor = [[UIColor alloc] initWithRed:220/255.0f
                                                      green:255/255.0f
                                                       blue:220/255.0f
                                                      alpha:1];
    } else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.font = [UIFont fontWithName:@"CircularTT-Bold" size:18];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *dev = self.devices[indexPath.row];
    if (dev.connected) {
        VarsViewController *varsViewController = [[VarsViewController alloc] init];
        varsViewController.device = dev;
        [self.navigationController pushViewController:varsViewController animated:YES];
    }
}

- (void)DidCloseSettings
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
