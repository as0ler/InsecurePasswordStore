#import "MainViewController.h"
#import "AppDelegate.h"
#import "Credential.h"
#import "Utils.h"
#import <sys/stat.h>


@interface MainViewController ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation MainViewController: UIViewController

- (void) createCredentials {
    Credential *newCredential = [NSEntityDescription insertNewObjectForEntityForName:@"Credential"
                                                      inManagedObjectContext:self.managedObjectContext];
    newCredential.identifier = 1;
    newCredential.username = @"admin";
    newCredential.password = @"OtherS3cr3tF0und";
    newCredential.website = @"www.linkedin.com";
    newCredential.notes = @"";
    
    newCredential = [NSEntityDescription insertNewObjectForEntityForName:@"Credential"
                                                      inManagedObjectContext:self.managedObjectContext];
    newCredential.identifier = 2;
    newCredential.username = @"superadmin";
    newCredential.password = @"12345678";
    newCredential.website = @"www.twitter.com";
    newCredential.notes = @"";
    
    newCredential = [NSEntityDescription insertNewObjectForEntityForName:@"Credential"
                                                      inManagedObjectContext:self.managedObjectContext];
    newCredential.identifier = 3;
    newCredential.username = @"murphy";
    newCredential.password = @"s3curePassword";
    newCredential.website = @"www.instagram.com";
    newCredential.notes = @"";
    
    newCredential = [NSEntityDescription insertNewObjectForEntityForName:@"Credential"
                                                      inManagedObjectContext:self.managedObjectContext];
    newCredential.identifier = 3;
    newCredential.username = @"bankUser";
    newCredential.password = @"730273987";
    newCredential.website = @"www.bank.com";
    newCredential.notes = @"";
    
    newCredential = [NSEntityDescription insertNewObjectForEntityForName:@"Credential"
                                                      inManagedObjectContext:self.managedObjectContext];
    newCredential.identifier = 3;
    newCredential.username = @"Rubius";
    newCredential.password = @"p4t4t4ft1t4";
    newCredential.website = @"www.youtube.com";
    newCredential.notes = @"";
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in saving data: %@", [error localizedDescription]);
        [self showAlertWithTitle:@"Error" message:@"Error Saved in Core Data"];
    }else{
        [self showAlertWithTitle:@"Success" message:@"Data saved in Core Data"];
    }
}

- (void) createPIN {
    NSUserDefaults *secretDetails = [NSUserDefaults standardUserDefaults];
    [secretDetails setObject:@"1337" forKey:@"PIN"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Credential" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([result count] == 0) {
        [self createCredentials];
    }
    [self createPIN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)viewCredentialsTap:(id)sender {

    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"PIN Required"
                                message:@"Insert the correct PIN"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];

                                                       }];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
        UITextField *textField = alert.textFields[0];
        NSUserDefaults *secretDetails = [NSUserDefaults standardUserDefaults];
        NSString *pin = [secretDetails objectForKey:@"PIN"];
        if ([textField.text isEqualToString:pin]) {
            [self performSegueWithIdentifier: @"showCredentialsView" sender: self];
        }
        else{
            [self showAlertWithTitle:@"Failure" message:@"invalid PIN"];
        }

    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
               textField.placeholder = @"PIN";
               textField.keyboardType = UIKeyboardTypeDefault;
           }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)AdminBtnTapped:(id)sender {
    if ([self isUserAdmin]) {
        [self performSegueWithIdentifier: @"showAdminView" sender: self];
    } else {
        [self showAlertWithTitle:@"Access Denied" message:@"User has not admin privileges"];
    }
}


- (IBAction)checkDeviceSecurityTap:(id)sender {
    struct stat s;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@"/bin/bash"]) {
        [self showAlertWithTitle:@"Security Check Failed" message:@"Device is at risk!"];
    } else if ([fileManager fileExistsAtPath:@"/bin/ls"]) {
        [self showAlertWithTitle:@"Security Check Failed" message:@"Device is at risk!"];
    } else if (!stat("/usr/sbin/sshd", &s)) {
        [self showAlertWithTitle:@"Security Check Failed" message:@"Device is at risk!. You are almost there!"];
    } else {
        [self showAlertWithTitle:@"Security Check Passed" message:@"Device is clean. Yay!"];
    }
}


- (BOOL) isUserAdmin {
    return [[Utils getConfigKey:@"isAdmin"] boolValue];
}


- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
