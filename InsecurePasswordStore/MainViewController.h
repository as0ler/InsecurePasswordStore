#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

- (void) createCredentials;
- (void) createPIN;
- (IBAction)viewCredentialsTap:(id)sender;
- (IBAction)AdminBtnTapped:(id)sender;
- (IBAction)checkDeviceSecurityTap:(id)sender;
- (BOOL) isUserAdmin;
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

 
