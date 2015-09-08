//
//  LoginSettingsViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LoginSettingsViewController.h"
#import "HollowGreenButton.h"
#import "AlertDialogsProvider.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "UserManager.h"
#import "User.h"

@interface LoginSettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField1;
@property (weak, nonatomic) IBOutlet UITextField *emailField2;
@property (weak, nonatomic) IBOutlet UILabel *passwordChangeLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *password1Field;
@property (weak, nonatomic) IBOutlet UITextField *password2Field;
@property (weak, nonatomic) IBOutlet UIButton *deactivateAccountButton;
@property (weak, nonatomic) IBOutlet HollowGreenButton *saveButton;
@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation LoginSettingsViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Login Settings", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.emailField1];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField1];
    [self.emailField1 setPlaceholder:NSLocalizedString(@"Please enter your new email", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.emailField2];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField2];
    [self.emailField2 setPlaceholder:NSLocalizedString(@"Please re-enter your email address", nil)];
    
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
    
    [self.deactivateAccountButton setTitle:NSLocalizedString(@"De-activate Account", nil) forState:UIControlStateNormal];
    
    [self.saveButton setLookAndFeel:self.lookAndFeel];
    [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    [self.emailLabel setText:self.userManager.user.loginName];
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
        
        [self.saveButton setEnabled: YES];
        
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
        
        [self.saveButton setEnabled: YES];
        
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
        
        [self.saveButton setEnabled: YES];
        
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
        
        [self.saveButton setEnabled: YES];
        
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
        
        [self.saveButton setEnabled: YES];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)deactivatePressed:(UIButton *)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure", nil)
                                                      message:NSLocalizedString(@"Do you really want to delete your account and all data?", nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"Confirm", nil),nil];
    
    [message show];
}

- (IBAction)savePressed:(HollowGreenButton *)sender
{
    [self.saveButton setEnabled:NO];
    
    [self createAndShowWaitView];
    
    BOOL wantToChangeEmail = NO;
    BOOL wantToChangePassword = NO;
    
    if (self.emailField1.text.length > 0 || self.emailField2.text.length)
    {
        wantToChangeEmail = YES;
    }
    
    if (self.oldPasswordField.text.length > 0 || self.password1Field.text.length || self.password2Field.text.length)
    {
        wantToChangePassword = YES;
    }
    
    if (wantToChangeEmail && !wantToChangePassword)
    {
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
                
                UIAlertView *message = [[UIAlertView alloc]
                                        initWithTitle: NSLocalizedString(@"Error", nil)
                                        message: NSLocalizedString(@"Failed to change email, please try again later", nil)
                                        delegate: nil
                                        cancelButtonTitle: nil
                                        otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
                
                [message show];
                
                [self.saveButton setEnabled: YES];
            }];
        }
    }
    else if (!wantToChangeEmail && wantToChangePassword)
    {
        if ([self checkInputsForChangePassword])
        {
            [self.authenticationService updatePassword:self.oldPasswordField.text
                                    passwordToChangeTo:self.password1Field.text
                                               success:^
             {
                 
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
                 
                 [self.saveButton setEnabled: YES];
                 
             }];
        }
    }
    else if (wantToChangeEmail && wantToChangePassword)
    {
        [self.authenticationService updateEmailTo:self.emailField1.text success:^{
            
            [self.userManager changeEmail:self.emailField1.text];
            
            [self.authenticationService updatePassword:self.oldPasswordField.text
                                    passwordToChangeTo:self.password1Field.text
                                               success:^
             {
                 
                 UIAlertView *message = [[UIAlertView alloc] initWithTitle: @""
                                                                   message: NSLocalizedString(@"Account email and password successfully changed", nil)
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
                                         otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
                 
                 [message show];
                 
                 [self.saveButton setEnabled: YES];
                 
             }];
            
        } failure:^(NSString *reason) {
            
            [self.waitView hide: YES];
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Error", nil)
                                    message: NSLocalizedString(@"Failed to change email, please try again later", nil)
                                    delegate: nil
                                    cancelButtonTitle: nil
                                    otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];
            
            [message show];
            
            [self.saveButton setEnabled: YES];
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: NSLocalizedString(@"Confirm", nil)])
    {
        //TODO: deactivate account, delete all local data, and log out
        [AlertDialogsProvider showWorkInProgressDialog];
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
    self.emailField1.text = [self.emailField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.emailField2.text = [self.emailField2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( (self.emailField1.text.length && self.emailField2.text.length) ||
         (self.oldPasswordField.text.length && self.password1Field.text.length && self.password2Field.text.length) )
    {
        [self.saveButton setEnabled: YES];
    }
    else
    {
        [self.saveButton setEnabled: NO];
    }
}

@end
