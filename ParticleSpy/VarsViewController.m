// TODO: Should list vars and functions

#import "VarsViewController.h"
#import "VarReadViewController.h"
#import "CloudService.h"

@interface VarsViewController ()

@end

@implementation VarsViewController

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

    self.navigationItem.title = @"Variables";
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    NSLog(@"%@", self.device);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.device.vars count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSDictionary *vars = self.device.vars[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", vars.allKeys[0], vars.allValues[0]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VarReadViewController *varReadViewController = [[VarReadViewController alloc] init];
    NSDictionary *vars = self.device.vars[indexPath.row];
    NSString *key = vars.allKeys[0];
    NSString *dataType = vars.allValues[0];
    varReadViewController.photon = self.device.photon;
    varReadViewController.key = key;
    varReadViewController.dataType = dataType;
    
    void (^getVariableCompletion) (NSArray *result, NSError *error) = ^(id result, NSError *error) {
        if (!error) {
            
            // check result data type
            if ([dataType isEqual:@"string"]) {
                NSString *valStr = (NSString *)result;
                varReadViewController.val = valStr;
            } else if ([dataType isEqual:@"int32"]) {
                NSNumber *valInt = (NSNumber *)result;
                varReadViewController.val = valInt.stringValue;
            }
            
            [self.navigationController pushViewController:varReadViewController animated:YES];
        } else {
            NSString *titleString = @"We experienced an error reading from your device. Please try again.";
            NSString *messageString = [error localizedDescription];
            NSString *moreString = [error localizedFailureReason] ?
            [error localizedFailureReason] : @"";
            
            messageString = [NSString stringWithFormat:@"%@ %@", messageString, moreString];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlert show];
        }
        
    };
    
    [CloudService getVariable:key ForDevice:self.device.photon :getVariableCompletion];
}

@end
