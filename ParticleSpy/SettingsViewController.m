// X TODO: check if touchid is available before enabling button
// TODO: Add section

// TODO: make table view a separate class; add it here

#import "SettingsViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingsViewController ()
@property (strong, nonatomic) UISwitch *touchIDSwitch;
@property (strong, nonatomic) NSArray *options;
@end

@implementation SettingsViewController

- (instancetype)init
{
    // Call the superclass's designated initializer
    self = [super init];
    if (self) {
        self.isTouchID = [[NSUserDefaults standardUserDefaults] boolForKey:@"touchid"];
        self.options = @[@"Enable Touch ID"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44);
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = [UIColor whiteColor];
    
    // TODO: add bottom border
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    headerView.backgroundColor = [[UIColor alloc] initWithRed:242/255.0f
                                                        green:242/255.0f
                                                         blue:242/255.0f
                                                        alpha:1];
    tableView.tableHeaderView = headerView;
    
    
    //Initialize the dataArray
    self.dataArray = [[NSMutableArray alloc] init];
    
    //First section data
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:@"Enable Touch ID", nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [self.dataArray addObject:firstItemsArrayDict];
    
    [tableView reloadData];
    
    [self.view addSubview:tableView];
    
    //
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                     [UIScreen mainScreen].bounds.size.height - 44,
                                                                     self.view.bounds.size.width,
                                                                     44)];
    
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(handleClose)];
    [toolbar setItems:@[itemCancel]];
    

    [self.view addSubview:toolbar];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
   return @" ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [self.options count];
    NSDictionary *dictionary = [self.dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    

    LAContext *myContext = [[LAContext alloc] init];
    
    NSError *authError = nil;
    
    UISwitch *touchIDSwitch = [[UISwitch alloc] init];
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [touchIDSwitch setOn:self.isTouchID];
        [touchIDSwitch addTarget:self action:@selector(touchIDSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        touchIDSwitch.enabled = NO;
        [touchIDSwitch setOn:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.accessoryView = touchIDSwitch;
    
    NSDictionary *dictionary = [self.dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    
    return cell;
}


- (void)touchIDSwitchChanged:(UISwitch *)sender
{
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"touchid"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"touchid"];
    }
}


- (void)handleClose
{
    [self.delegate DidCloseSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
