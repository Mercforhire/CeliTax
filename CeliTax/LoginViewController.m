//
//  LoginViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ViewControllerFactory.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "AuthorizeResult.h"
#import "UserManager.h"
#import "MainScreenRootViewController.h"
#import "UIView+Helper.h"
#import "AlertDialogsProvider.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.emailField.delegate = self;
    [self.emailField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];
    
    self.passwordField.delegate = self;
    [self.passwordField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];

    //demo
    self.emailField.text = @"leonchn84@gmail.com";
    self.passwordField.text = @"123456";
    [self.loginButton setEnabled:YES];
}

-(void)createAndShowWaitViewForLogin
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView:self.view];
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Logging in...";
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview:self.waitView];
    }
    
    [self.waitView show:YES];
}

-(void)checkLogin
{
    if (![self.emailField.text isEmailAddress])
    {
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Email address not valid" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        
        [message show];
        
        return;
    }
    
    [self.authenticationService authenticateUser:self.emailField.text withPassword:self.passwordField.text success:^(AuthorizeResult *authorizeResult) {
        
        [self.waitView hide:YES];
        
        [self.userManager loginUserFor:authorizeResult.userName
                                andKey:authorizeResult.userAPIKey
                          andFirstname:authorizeResult.firstname
                           andLastname:authorizeResult.lastname
                         andPostalCode:authorizeResult.postalCode
                            andCountry:authorizeResult.country];
        
        [self.navigationController pushViewController:[self.viewControllerFactory createMainScreenRootViewController] animated:YES];
        
        return;
    } failure:^(AuthorizeResult *authorizeResult) {
        
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:authorizeResult.message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        
        [message show];
        
        return;
    }];
}

- (IBAction)loginPressed:(UIButton *)sender
{
    [self.loginButton setEnabled:NO];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [self createAndShowWaitViewForLogin];
    [self checkLogin];
}

- (IBAction)forgotPressed:(UIButton *)sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (IBAction)signupPressed:(UIButton *)sender
{
    [self.navigationController pushViewController:[self.viewControllerFactory createRegisterViewController] animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view scrollToView:self.passwordField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view scrollToY:0];
    
    [textField resignFirstResponder];
    
    if (textField == self.passwordField)
    {
        [self loginPressed:self.loginButton];
    }
    
    return NO;
}

-(void)textFieldDidChange:(UITextField *)textfield
{
    if (self.emailField.text.length && self.passwordField.text.length)
    {
        [self.loginButton setEnabled:YES];
    }
    else
    {
        [self.loginButton setEnabled:NO];
    }
}


@end
