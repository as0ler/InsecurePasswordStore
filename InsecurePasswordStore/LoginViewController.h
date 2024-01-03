#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)submit:(id)sender;
- (IBAction)getHint:(id)sender;

- (NSString*)deviceName;
- (NSString*)deviceUUID;
- (void) sendUserInfo:(NSString*)username withDeviceName:(NSString*)deviceName DeviceId:(NSString*)deviceId;
- (NSString *)getPathForFilename:(NSString *)filename;
- (void)storeCredentialsForUsername:(NSString *)username withPassword:(NSString *)password isAdmin:(NSNumber *)isAdmin;
- (void)storeEncryptedCredentialsForUsername:(NSString *)username withPassword:(NSData *)password;
- (BOOL)isUserValidForUsername:(NSString *)username withPassword:(NSString *)password;
- (BOOL) isValidAdminForUsername:username;
- (void)doLogin;
- (void)viewDidLoad;
- (void) changeBgWithColor:(NSString *)color;
- (void) showAlert:(NSString *)message;

@end
