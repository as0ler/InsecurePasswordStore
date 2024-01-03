#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "Credential.h"

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.credentials = [[NSMutableArray alloc] init];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Credential" inManagedObjectContext:[delegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Credential *credential in result) {
        NSString *str = [NSString stringWithFormat:@"%@\t\t\t\t%@", [credential username], [credential password]];
        [self.credentials addObject:str];
    }
    [self.myTableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.credentials.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.credentials[indexPath.row];
    
    return cell;
}
@end

