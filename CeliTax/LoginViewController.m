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
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "AuthorizeResult.h"
#import "UserManager.h"
#import "UIView+Helper.h"
#import "AlertDialogsProvider.h"
#import "User.h"
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
    [self.lookAndFeel applyGrayBorderTo: self.emailField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField];

    [self.lookAndFeel applyGrayBorderTo: self.passwordField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordField];

    [self.loginButton setLookAndFeel:self.lookAndFeel];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];

    self.emailField.delegate = self;
    [self.emailField addTarget: self
                        action: @selector(textFieldDidChange:)
              forControlEvents: UIControlEventEditingChanged];

    self.passwordField.delegate = self;
    [self.passwordField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];

    //TODO: Remove DEMO CODE
    self.emailField.text = @"leonchn84@gmail.com";
    self.passwordField.text = @"123456";
    [self.loginButton setEnabled: YES];
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
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Logging in...";
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

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"" message: @"Email address not valid" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];

        return;
    }

    [self.authenticationService authenticateUser: self.emailField.text withPassword: self.passwordField.text success: ^(AuthorizeResult *authorizeResult) {
        [self.waitView hide: YES];

        [self.userManager loginUserFor: authorizeResult.userName
                                andKey: authorizeResult.userAPIKey
                          andFirstname: authorizeResult.firstname
                           andLastname: authorizeResult.lastname
                               andCity: authorizeResult.city
                         andPostalCode: authorizeResult.postalCode
                            andCountry: authorizeResult.country];
        self.userManager.user.avatarImage = [UIImage imageNamed: @"userIcon.png"];

        [self.navigationController pushViewController: [self.viewControllerFactory createMainViewController] animated: YES];

        [self.loginButton setEnabled: YES];

        return;
    } failure: ^(AuthorizeResult *authorizeResult) {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Error" message: authorizeResult.message delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];

        [self.loginButton setEnabled: YES];

        return;
    }];
}

- (IBAction) loginPressed: (UIButton *) sender
{
    [self.loginButton setEnabled: NO];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];

    [self createAndShowWaitViewForLogin];
    [self checkLogin];
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

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

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.emailField.text.length && self.passwordField.text.length)
    {
        [self.loginButton setEnabled: YES];
    }
    else
    {
        [self.loginButton setEnabled: NO];
    }
}

@end