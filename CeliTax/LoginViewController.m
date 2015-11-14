//
// LoginViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ViewControllerFactory.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "PasswordRecoveryViewController.h"
#import "HollowGreenButton.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet HollowGreenButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation LoginViewController

- (void) setupUI
{
    [self.emailField setPlaceholder:NSLocalizedString(@"Email Address", nil)];
    [self.lookAndFeel applyGrayBorderTo: self.emailField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField];

    [self.passwordField setPlaceholder:NSLocalizedString(@"Password", nil)];
    [self.lookAndFeel applyGrayBorderTo: self.passwordField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordField];

    [self.loginButton setLookAndFeel:self.lookAndFeel];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    [self.forgotPasswordButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
    
    NSDictionary *boldBlackTextAttributes = @{
                                NSFontAttributeName:[UIFont latoBoldFontOfSize:15],
                                NSForegroundColorAttributeName:[UIColor blackColor]
                                };
    
    NSDictionary *boldGreenTextAttributes = @{
                                               NSFontAttributeName:[UIFont latoBoldFontOfSize:15],
                                               NSForegroundColorAttributeName:self.lookAndFeel.appGreenColor
                                               };
    
    NSString *titlePart1 = NSLocalizedString(@"Need an account?", nil);
    NSString *titlePart2 = NSLocalizedString(@"Sign up now!", nil);
    
    NSString *titleBothParts = [NSString stringWithFormat:@"%@ %@", titlePart1, titlePart2];
    
    NSMutableAttributedString *signupButtonAttributedString = [[NSMutableAttributedString alloc] initWithString:titleBothParts attributes:boldBlackTextAttributes];
    
    NSRange rangeOfTextToGreen = [titleBothParts rangeOfString:titlePart2];
    
    [signupButtonAttributedString setAttributes:boldGreenTextAttributes range:rangeOfTextToGreen];
    
    [self.signupButton setAttributedTitle:signupButtonAttributedString forState:UIControlStateNormal];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];

    self.emailField.delegate = self;
    self.passwordField.delegate = self;

    //TODO: Remove DEMO CODE
    self.emailField.text = @"leonchn84@gmail.com";
    self.passwordField.text = @"123456";
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [self.navigationController setNavigationBarHidden: NO];
    [self.navigationItem setHidesBackButton: YES];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];

    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void) createAndShowWaitViewForLogin
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Logging in...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }

    [self.waitView show: YES];
}

- (void) checkLogin
{
    if (![self.emailField.text isEmailAddress])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Email address is not valid", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.loginButton setEnabled: YES];

        return;
    }

    [self.authenticationService authenticateUser: self.emailField.text
                                        password: self.passwordField.text
                                         success: ^(AuthorizeResult *authorizeResult)
     {
         
         [self.userManager loginUserFor: authorizeResult.userName
                                    key: authorizeResult.userAPIKey
                              firstname: authorizeResult.firstname
                               lastname: authorizeResult.lastname
                                country: authorizeResult.country];
         
         [self.userManager updateUserSubscriptionExpiryDate:^{
             
             [self.waitView hide: YES];
             
             [self.navigationController pushViewController: [self.viewControllerFactory createMainViewController] animated: YES];
             
             [self.loginButton setEnabled: YES];
             
         } failure:^(NSString *reason) {
             
             [self.waitView hide: YES];
             
             [self.navigationController pushViewController: [self.viewControllerFactory createMainViewController] animated: YES];
             
             [self.loginButton setEnabled: YES];
             
         }];
         
     } failure: ^(AuthorizeResult *authorizeResult) {
         
         [self.waitView hide: YES];
         
         NSString *errorMessage;
         
         if ([authorizeResult.message isEqualToString: AuthenticationService.USER_PASSWORD_WRONG])
         {
             errorMessage = NSLocalizedString(@"The password entered for this user is incorrect", nil);
         }
         else if ([authorizeResult.message isEqualToString: AuthenticationService.USER_DOESNT_EXIST])
         {
             errorMessage = NSLocalizedString(@"This user does not exist", nil);
         }
         else
         {
             errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
         }
         
         UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                           message: errorMessage
                                                          delegate: nil cancelButtonTitle: nil
                                                 otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];
         
         [message show];
         
         [self.loginButton setEnabled: YES];
         
     }];
}

- (IBAction) loginPressed: (UIButton *) sender
{
    if (self.emailField.text.length && self.passwordField.text.length)
    {
        [self.loginButton setEnabled: NO];
        [self.emailField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
        [self createAndShowWaitViewForLogin];
        [self checkLogin];
    }
    else
    {
        NSString *errorMessage = NSLocalizedString(@"Please enter your account's email's address and password to log in", nil);
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: errorMessage
                                                         delegate: nil cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];
        
        [message show];
    }
}

- (IBAction) forgotPressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createPasswordRecoveryViewController] animated: YES];
    
    [self.navigationItem setHidesBackButton: NO];
}

- (IBAction) signupPressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createRegisterViewController] animated: YES];
    
    [self.navigationItem setHidesBackButton: NO];
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view scrollToY: 0 - kbSize.height / 2];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    if (textField == self.passwordField && self.passwordField.text.length)
    {
        [self loginPressed: self.loginButton];
    }

    return NO;
}

@end