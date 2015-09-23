#import "VarReadViewController.h"
#import "CloudService.h"
#import "VarReadCell.h"

@interface VarReadViewController ()

@end

@implementation VarReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.key;
    self.view.backgroundColor = [UIColor lightGrayColor];

    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = [UIScreen mainScreen].bounds.size.height -
    self.navigationController.navigationBar.frame.size.height - 16;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[VarReadCell class]
           forCellReuseIdentifier:@"VarReadCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)refreshTable
{
    void (^getVariableCompletion) (NSArray *result, NSError *error) = ^(id result, NSError *error) {
        if (!error) {
            
            // check result data type
            if ([self.dataType isEqual:@"string"]) {
                NSString *valStr = (NSString *)result;
                self.val = valStr;
            } else if ([self.dataType isEqual:@"int32"]) {
                NSNumber *valInt = (NSNumber *)result;
                self.val = valInt.stringValue;
            }
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
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
    
    [CloudService getVariable:self.key ForDevice:self.photon :getVariableCompletion];

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
    return 1;
}

- (VarReadCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VarReadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VarReadCell" forIndexPath:indexPath];
    cell.val.text = self.val;
    
    return cell;
}

@end
