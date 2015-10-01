//
//  LoginSettingsViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LoginSettingsViewController.h"
#import "HollowGreenButton.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "UserManager.h"
#import "User.h"
#import "SolidGreenButton.h"
#import "LoginViewController.h"
#import "ViewControllerFactory.h"

@interface LoginSettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) BOOL emailContainerActivated; //needs a setter
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *editEmailButton1;
@property (weak, nonatomic) IBOutlet UIButton *editEmailButton2;

@property (nonatomic) float emailContainerHeightBarOriginalHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailContainerHeightBar;
@property (weak, nonatomic) IBOutlet UITextField *emailField1;
@property (weak, nonatomic) IBOutlet UITextField *emailField2;
@property (weak, nonatomic) IBOutlet HollowGreenButton *saveEmailButton;

@property (nonatomic) BOOL passwordContainerActivated; //needs a setter
@property (weak, nonatomic) IBOutlet UILabel *passwordChangeLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *editPasswordButton1;
@property (weak, nonatomic) IBOutlet UIButton *editPasswordButton2;

@property (nonatomic) float passwordContainerHeightBarOriginalHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordContainerHeightBar;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *password1Field;
@property (weak, nonatomic) IBOutlet UITextField *password2Field;
@property (weak, nonatomic) IBOutlet HollowGreenButton *savePasswordButton;

@property (nonatomic) BOOL deactivateContainerActivated; //needs a setter
@property (weak, nonatomic) IBOutlet UIButton *deactivateAccountButton;

@property (nonatomic) float deactivateContainerHeightBarOriginalHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deactivateContainerHeightBar;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *deactivateConfirmationButton;

@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation LoginSettingsViewController

-(void)setEmailContainerActivated:(BOOL)emailContainerActivated
{
    _emailContainerActivated = emailContainerActivated;
    
    if (!_emailContainerActivated)
    {
        self.emailContainerHeightBar.constant = 0;
        
        return;
    }
    
    _passwordContainerActivated = NO;
    
    _deactivateContainerActivated = NO;
    
    self.emailContainerHeightBar.constant = self.emailContainerHeightBarOriginalHeight;
    
    self.passwordContainerHeightBar.constant = 0;
    
    self.deactivateContainerHeightBar.constant = 0;
}

-(void)setPasswordContainerActivated:(BOOL)passwordContainerActivated
{
    _passwordContainerActivated = passwordContainerActivated;
    
    if (!_passwordContainerActivated)
    {
        self.passwordContainerHeightBar.constant = 0;
        
        return;
    }
    
    _emailContainerActivated = NO;
    
    _deactivateContainerActivated = NO;
    
    self.emailContainerHeightBar.constant = 0;
    
    self.passwordContainerHeightBar.constant = self.passwordContainerHeightBarOriginalHeight;
    
    self.deactivateContainerHeightBar.constant = 0;
}

-(void)setDeactivateContainerActivated:(BOOL)deactivateContainerActivated
{
    _deactivateContainerActivated = deactivateContainerActivated;
    
    if (!_deactivateContainerActivated)
    {
        self.deactivateContainerHeightBar.constant = 0;
        
        return;
    }
    
    _emailContainerActivated = NO;
    
    _passwordContainerActivated = NO;
    
    self.emailContainerHeightBar.constant = 0;
    
    self.passwordContainerHeightBar.constant = 0;
    
    self.deactivateContainerHeightBar.constant = self.deactivateContainerHeightBarOriginalHeight;
}

-(void)setDeactivateAccountButtonActivated:(BOOL)active
{
    if (active)
    {
        [self.deactivateConfirmationButton setEnabled:YES];
        [self.deactivateConfirmationButton setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:83.0f/255.0f blue:72.0f/255.0f alpha:1]];
    }
    else
    {
        [self.deactivateConfirmationButton setEnabled:NO];
        [self.deactivateConfirmationButton setBackgroundColor: [UIColor lightGrayColor]];
    }
    
    [self.lookAndFeel applySlightlyDarkerBorderTo:self.deactivateConfirmationButton];
}

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Login Settings", nil)];
    
    [self.editEmailButton1 setLookAndFeel:self.lookAndFeel];
    [self.editPasswordButton1 setLookAndFeel:self.lookAndFeel];
    
    [self.emailLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Email: %@", nil), self.userManager.user.loginName]];
    
    [self.lookAndFeel applyGrayBorderTo: self.emailField1];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField1];
    [self.emailField1 setPlaceholder:NSLocalizedString(@"Please enter new email address", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.emailField2];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField2];
    [self.emailField2 setPlaceholder:NSLocalizedString(@"Please re-enter new email address", nil)];
    
    [self.saveEmailButton setLookAndFeel:self.lookAndFeel];
    [self.saveEmailButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    [self.passwordChangeLabel setText:NSLocalizedString(@"Password Change", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.oldPasswordField];
    [self.lookAndFeel addLeftInsetToTextField: self.oldPasswordField];
    [self.oldPasswordField setPlaceholder:NSLocalizedString(@"Please enter old password", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.password1Field];
    [self.lookAndFeel addLeftInsetToTextField: self.password1Field];
    [self.password1Field setPlaceholder:NSLocalizedString(@"Please enter new password", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.password2Field];
    [self.lookAndFeel addLeftInsetToTextField: self.password2Field];
    [self.password2Field setPlaceholder:NSLocalizedString(@"Please re-enter new password", nil)];
    
    [self.savePasswordButton setLookAndFeel:self.lookAndFeel];
    [self.savePasswordButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    [self.deactivateAccountButton setTitle:NSLocalizedString(@"De-activate Account", nil) forState:UIControlStateNormal];
    [self setDeactivateAccountButtonActivated:NO];
    
    [self.lookAndFeel applyGrayBorderTo: self.confirmPasswordField];
    [self.lookAndFeel addLeftInsetToTextField: self.confirmPasswordField];
    [self.confirmPasswordField setPlaceholder:NSLocalizedString(@"Please enter your password", nil)];
    
    self.emailContainerHeightBarOriginalHeight = self.emailContainerHeightBar.constant;
    self.emailContainerHeightBar.constant = 0;
    
    self.passwordContainerHeightBarOriginalHeight = self.passwordContainerHeightBar.constant;
    self.passwordContainerHeightBar.constant = 0;
    
    self.deactivateContainerHeightBarOriginalHeight = self.deactivateContainerHeightBar.constant;
    self.deactivateContainerHeightBar.constant = 0;
    
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    self.emailField1.delegate = self;
    [self.emailField1 addTarget: self
                         action: @selector(textFieldDidChange:)
               forControlEvents: UIControlEventEditingChanged];
    
    self.emailField2.delegate = self;
    [self.emailField2 addTarget: self
                         action: @selector(textFieldDidChange:)
               forControlEvents: UIControlEventEditingChanged];
    
    self.oldPasswordField.delegate = self;
    [self.oldPasswordField addTarget: self
                              action: @selector(textFieldDidChange:)
                    forControlEvents: UIControlEventEditingChanged];
    
    self.password1Field.delegate = self;
    [self.password1Field addTarget: self
                            action: @selector(textFieldDidChange:)
                  forControlEvents: UIControlEventEditingChanged];
    
    self.password2Field.delegate = self;
    [self.password2Field addTarget: self
                            action: @selector(textFieldDidChange:)
                  forControlEvents: UIControlEventEditingChanged];
    
    self.confirmPasswordField.delegate = self;
    [self.confirmPasswordField addTarget: self
                            action: @selector(textFieldDidChange:)
                  forControlEvents: UIControlEventEditingChanged];
}

- (void) createAndShowWaitView
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Updating account info...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }
    
    [self.waitView show: YES];
}

- (IBAction)editEmailPressed:(UIButton *)sender
{
    self.emailContainerActivated = !self.emailContainerActivated;
}

- (IBAction)editPasswordPressed:(UIButton *)sender
{
    self.passwordContainerActivated = !self.passwordContainerActivated;
}

- (IBAction)deactivatePressed:(UIButton *)sender
{
    self.deactivateContainerActivated = !self.deactivateContainerActivated;
}

- (BOOL) checkInputsForChangePassword
{
    if (![self.password1Field.text isEqualToString: self.password2Field.text])
    {
        [self.waitView hide: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Password in both fields do not match", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
        
        [message show];
        
        [self.savePasswordButton setEnabled: YES];
        
        return NO;
    }
    
    if (self.password1Field.text.length < 6)
    {
        [self.waitView hide: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Password should be at least 6 characters", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
        
        [message show];
        
        [self.savePasswordButton setEnabled: YES];
        
        return NO;
    }
    
    return YES;
}

- (BOOL) checkInputsForChangeEmail
{
    if (![self.emailField1.text isEqualToString: self.emailField2.text])
    {
        [self.waitView hide: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Email address in both fields do not match", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
        
        [message show];
        
        [self.saveEmailButton setEnabled: YES];
        
        return NO;
    }
    
    if (![self.emailField1.text isEmailAddress])
    {
        [self.waitView hide: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Email address is not valid", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
        
        [message show];
        
        [self.saveEmailButton setEnabled: YES];
        
        return NO;
    }
    
    if ([self.emailField1.text isEqual:self.userManager.user.loginName])
    {
        [self.waitView hide: YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"The new email is same as the original email", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
        
        [message show];
        
        [self.saveEmailButton setEnabled: YES];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)saveEmailPressed:(UIButton *)sender
{
    [self.saveEmailButton setEnabled:NO];
    
    [self createAndShowWaitView];
    
    if ([self checkInputsForChangeEmail])
    {
        [self.authenticationService updateEmailTo:self.emailField1.text success:^{
            
            [self.userManager changeEmail:self.emailField1.text];
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: @""
                                                              message: NSLocalizedString(@"Account email successfully changed", nil)
                                                             delegate: nil
                                                    cancelButtonTitle: nil
                                                    otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
            
            [message show];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSString *reason) {
            
            [self.waitView hide: YES];
            
            NSString *errorMessage;
            
            if ([reason isEqualToString:USER_CHANGE_EMAIL_ALREADY_EXIST])
            {
                errorMessage = NSLocalizedString(@"The email address is already used by another account. Please use a different email address", nil);
            }
            else
            {
                errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
            }
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Error", nil)
                                    message: errorMessage
                                    delegate: nil
                                    cancelButtonTitle: nil
                                    otherButtonTitles: @"Ok", nil];
            
            [message show];
            
            [self.saveEmailButton setEnabled: YES];
        }];
    }
}

- (IBAction)savePasswordPressed:(UIButton *)sender
{
    [self.savePasswordButton setEnabled:NO];
    
    [self createAndShowWaitView];
    
    if ([self checkInputsForChangePassword])
    {
        [self.authenticationService updatePassword:self.oldPasswordField.text
                                passwordToChangeTo:self.password1Field.text
                                           success:^ {
             
             UIAlertView *message = [[UIAlertView alloc] initWithTitle: @""
                                                               message: NSLocalizedString(@"Account password successfully changed", nil)
                                                              delegate: nil
                                                     cancelButtonTitle: nil
                                                     otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
             
             [message show];
             
             [self.navigationController popViewControllerAnimated:YES];
             
         } failure:^(NSString *reason) {
             
             [self.waitView hide: YES];
             
             NSString *errorMessage;
             
             if ([reason isEqualToString:USER_PASSWORD_WRONG])
             {
                 errorMessage = NSLocalizedString(@"The old password provided is incorrect", nil);
             }
             else
             {
                 errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
             }
             
             UIAlertView *message = [[UIAlertView alloc]
                                     initWithTitle: NSLocalizedString(@"Error", nil)
                                     message: errorMessage
                                     delegate: nil
                                     cancelButtonTitle: nil
                                     otherButtonTitles: @"Ok", nil];
             
             [message show];
             
             [self.savePasswordButton setEnabled: YES];
             
         }];
    }
}

- (IBAction)deactivateConfirmationPressed:(UIButton *)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                      message:NSLocalizedString(@"Do you really want to delete your account and all data?", nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"Confirm", nil),nil];
    
    [message show];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ( [title isEqualToString: NSLocalizedString(@"Confirm", nil)] )
    {
        [self.deactivateConfirmationButton setEnabled:NO];
        
        [self createAndShowWaitView];
        
        [self.authenticationService killAccount:self.confirmPasswordField.text success:^{
            
            [self.userManager deleteAllLocalUserData];
            
            [self.userManager logOutUser];
            
            LoginViewController *loginViewController = [self.viewControllerFactory createLoginViewController];
            
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            
            [viewControllers insertObject:loginViewController atIndex:0];
            
            [self.navigationController setViewControllers:viewControllers animated:NO];
            
            [self.navigationController popToViewController:loginViewController animated:YES];
            
        } failure:^(NSString *reason) {
            
            [self.waitView hide: YES];
            
            NSString *errorMessage;
            
            if ([reason isEqualToString:USER_PASSWORD_WRONG])
            {
                errorMessage = NSLocalizedString(@"The old password provided is incorrect", nil);
            }
            else
            {
                errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
            }
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Error", nil)
                                    message: errorMessage
                                    delegate: nil
                                    cancelButtonTitle: nil
                                    otherButtonTitles: @"Ok", nil];
            
            [message show];
            
            [self.deactivateConfirmationButton setEnabled: YES];
            
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailField1 || textField == self.emailField2 || textField == self.emailField2)
    {
        textField.text = [textField.text lowercaseString];
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.emailContainerActivated)
    {
        self.emailField1.text = [self.emailField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.emailField2.text = [self.emailField2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (self.emailField1.text.length && self.emailField2.text.length)
        {
            [self.saveEmailButton setEnabled: YES];
        }
        else
        {
            [self.saveEmailButton setEnabled: NO];
        }
    }
    else if (self.passwordContainerActivated)
    {
        if (self.oldPasswordField.text.length && self.password1Field.text.length && self.password2Field.text.length)
        {
            [self.savePasswordButton setEnabled: YES];
        }
        else
        {
            [self.savePasswordButton setEnabled: NO];
        }
    }
    else if (self.deactivateContainerActivated)
    {
        if (self.confirmPasswordField.text.length)
        {
            [self setDeactivateAccountButtonActivated:YES];
        }
        else
        {
            [self setDeactivateAccountButtonActivated:NO];
        }
    }
}

@end
