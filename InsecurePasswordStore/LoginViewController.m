#import "LoginViewController.h"
#import <sqlite3.h>
#import <sys/utsname.h>
#import <Foundation/Foundation.h>
#import "Utils.h"


@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;

NSString * const key = @"3ncryptKEY";


- (NSString*)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString*)deviceUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (void) sendUserInfo:(NSString*)username withDeviceName:(NSString*)deviceName DeviceId:(NSString*)deviceId {
    NSString *endpoint = @"http://www.upc.edu/";
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    if (request == nil) {
        return;
    }
    NSDictionary *jsonBodyDict = @{@"user":username, @"type":@"ios", @"model":deviceName, @"uuid": deviceId};
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [request setURL:[NSURL URLWithString:endpoint]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
        NSLog(@"Yay, done! Customer Data Sent to our servers!");
    }];
    [task resume];
}


- (NSString *)getPathForFilename:(NSString *)filename {
    // Get the path to the Documents directory belonging to this app.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Append the filename to get the full, absolute path.
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    return fullPath;
}

- (void)storeCredentialsForUsername:(NSString *)username withPassword:(NSString *)password isAdmin:(NSNumber *)isAdmin {
    // Write the credentials to a SQLite database.
    sqlite3 *credentialsDB;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    
    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        // Create the table if it doesn't exist.
        const char *createCredsStmt =
        "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, isadmin INTEGER);";
        
        sqlite3_exec(credentialsDB, createCredsStmt, NULL, NULL, NULL);
        
        // Check to see if the user exists; update if yes, add if no.
        const char *queryStmt = "SELECT id FROM users WHERE username=?";
        int userID = -1;
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                userID = sqlite3_column_int(compiledStmt, 0);
            }
            
            sqlite3_finalize(compiledStmt);
        }
        
        const char *addUpdateStmt;
        NSLog(@"%@", [NSString stringWithFormat:@"Creating username %@ and password %@", username, password]);
        if (userID >= 0) {
            addUpdateStmt = "UPDATE users SET username=?, password=?, isadmin=? WHERE id=?";
        } else {
            addUpdateStmt = "INSERT INTO users(username, password, isadmin) VALUES(?, ?, ?)";
        }
        
        if (sqlite3_prepare_v2(credentialsDB, addUpdateStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStmt, 2, [password UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStmt, 3, [[isAdmin stringValue] UTF8String], -1, SQLITE_TRANSIENT);
            
            
            if (userID >= 0) sqlite3_bind_int(compiledStmt, 3, userID);
            if (sqlite3_step(compiledStmt) != SQLITE_DONE) {
                NSLog(@"Error storing credentials in SQLite database.");
            }
        }
        
        // Clean things up.
        if (compiledStmt && credentialsDB) {
            if (sqlite3_finalize(compiledStmt) != SQLITE_OK) {
                NSLog(@"Error finalizing SQLite compiled statement.");
            } else if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
            
        } else {
            NSLog(@"Error closing SQLite database.");
        }
    }
}

- (void)storeEncryptedCredentialsForUsername:(NSString *)username withPassword:(NSData *)password {
    // Write the credentials to a SQLite database.
    sqlite3 *credentialsDB;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    
    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        // Create the table if it doesn't exist.
        const char *createEncryptedCredsStmt =
        "CREATE TABLE IF NOT EXISTS administrators (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password BLOB);";
        
        sqlite3_exec(credentialsDB, createEncryptedCredsStmt, NULL, NULL, NULL);
        
        // Check to see if the user exists; update if yes, add if no.
        const char *queryStmt = "SELECT id FROM administrators WHERE username=?";
        int userID = -1;
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                userID = sqlite3_column_int(compiledStmt, 0);
            }
            
            sqlite3_finalize(compiledStmt);
        }
        
        const char *addUpdateStmt;
        NSLog(@"%@", [NSString stringWithFormat:@"Creating username %@ with encrypted password as administrator", username]);
        if (userID >= 0) {
            addUpdateStmt = "UPDATE administrators SET username=?, password=? WHERE id=?";
        } else {
            addUpdateStmt = "INSERT INTO administrators(username, password) VALUES(?, ?)";
        }
        
        if (sqlite3_prepare_v2(credentialsDB, addUpdateStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStmt, 2, [password bytes], -1, SQLITE_TRANSIENT);
            
            if (userID >= 0) sqlite3_bind_int(compiledStmt, 3, userID);
            if (sqlite3_step(compiledStmt) != SQLITE_DONE) {
                NSLog(@"Error storing credentials in SQLite database.");
            }
        }
        
        // Clean things up.
        if (compiledStmt && credentialsDB) {
            if (sqlite3_finalize(compiledStmt) != SQLITE_OK) {
                NSLog(@"Error finalizing SQLite compiled statement.");
            } else if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
            
        } else {
            NSLog(@"Error closing SQLite database.");
        }
    }
}

- (BOOL)isUserValidForUsername:(NSString *)username withPassword:(NSString *)password {
    sqlite3 *credentialsDB;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    int userId = 0;
    int isAdmin = 0;
    NSString* passwordDB = @"";
    
    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        // Check to see if the user exists
        const char *queryStmt = "SELECT id, isadmin FROM users WHERE username=?";
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStmt, 2, [password UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                userId = sqlite3_column_int(compiledStmt, 0);
                isAdmin = sqlite3_column_int(compiledStmt, 1);
            }
            if (compiledStmt) {
                sqlite3_finalize(compiledStmt);
            }
        }
        
        if (isAdmin > 0) {
            // Check to see if the admin user exists
            const char *encryptedQueryStmt = "SELECT password FROM administrators WHERE username=?";
            NSData *passwordEncrypted;
            
            if (sqlite3_prepare_v2(credentialsDB, encryptedQueryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
                sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
                while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                    passwordEncrypted = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStmt, 0) length:sqlite3_column_bytes(compiledStmt, 0)];
                }
                if ([passwordEncrypted length] > 0) {
                    passwordDB = [[NSString alloc] initWithData:[Utils AES128DecryptedData:passwordEncrypted WithKey:key] encoding:NSUTF8StringEncoding];
                }
                
            }
        } else {
            // Check to see if the admin user exists
            const char *queryStmt = "SELECT password FROM users WHERE username=?";
            
            if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
                sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
                while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                    const char *_passDB = (const char *) sqlite3_column_text(compiledStmt, 0);
                    if (_passDB) {
                        passwordDB = [[NSString alloc] initWithUTF8String:_passDB];
                    }
                }
            }
        }
        
        if (compiledStmt) {
            sqlite3_finalize(compiledStmt);
        }
        
        // Closing DB.
        if (credentialsDB) {
            if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
        }
    }
    return ( [passwordDB length] > 0 && [password isEqualToString:passwordDB] && userId > 0);
}

- (BOOL) isValidAdminForUsername:username {
    sqlite3 *credentialsDB;
    int isAdmin = 0;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    
    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        // Check to see if the user exists and returns whether is admin or not
        const char *queryStmt = "SELECT isadmin FROM users WHERE username=?";
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                isAdmin = sqlite3_column_int(compiledStmt, 0);
            }
            if (compiledStmt) {
                sqlite3_finalize(compiledStmt);
            }
        }
        
        // Closing DB.
        if (credentialsDB) {
            if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
        }
    }
    return (isAdmin > 0);
}
    



- (void)doLogin {
    // Write the credentials to a SQLite database.
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if ([self isUserValidForUsername:username withPassword:password]) {
        NSLog(@"%@", [NSString stringWithFormat:@"Username %@ and password %@ are correct!", username, password]);
        [Utils updateConfigKey:@"isAdmin" WithValue:[self isValidAdminForUsername:username] ? @YES:@NO];
        [self sendUserInfo:username withDeviceName:[self deviceName] DeviceId:[self deviceUUID]];
        [self performSegueWithIdentifier: @"loginSuccess" sender: self];
    } else {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Login Failed"
                                    message:@"Invalid credentials."
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *username = @"master";
    NSString *password = @"Passw0rd!";
    NSString *adminUser = @"admin";
    NSString *adminPassword = @"s3cr3tPass";
    
    NSData *encryptedPass = [Utils AES128EncryptedData: [adminPassword dataUsingEncoding:NSUTF8StringEncoding] WithKey:key];
    
    [self storeCredentialsForUsername:username withPassword:password isAdmin:@0];
    [self storeCredentialsForUsername:adminUser withPassword:@"" isAdmin:@1];
    [self storeEncryptedCredentialsForUsername:adminUser withPassword:encryptedPass];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit:(id)sender {
    if ([Utils isJailbroken]) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Insecure Device"
                                    message:@"Unable to log in. We have identified a Jailbroken device!"
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
    } else {
        [self doLogin];
    }
}

- (IBAction)getHint:(id)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"HINT"
                                message:@"Check the database where the credentials are stored."
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
    
- (void) changeBgWithColor:(NSString *)color{
    NSLog(@"Changing background color...");
    if ([color isEqualToString:@"green"]) {
        self.view.backgroundColor = [UIColor greenColor];
    } else if ([ color isEqualToString:@"blue"]) {
        self.view.backgroundColor = [UIColor blueColor];
    } else if ([color isEqualToString:@"red"]) {
        self.view.backgroundColor = [UIColor redColor];
    } else if ([color isEqualToString:@"black"]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else if ([color isEqualToString:@"white"]) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else if ([color isEqualToString:@"brown"]) {
        self.view.backgroundColor = [UIColor brownColor];
    } else if ([color isEqualToString:@"purple"]) {
        self.view.backgroundColor = [UIColor purpleColor];
    }
    else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}
    
- (void) showAlert:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Alert"
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
