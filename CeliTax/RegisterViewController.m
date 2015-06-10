//
//  RegisterViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "RegisterResult.h"
#import "UIView+Helper.h"

@interface RegisterViewController () <UITextFieldDelegate,UIScrollViewDelegate>
{
    UIImage *canadaFlag;
    UIImage *canadaFlagInactive;
    UIImage *usaFlag;
    UIImage *usaFlagInactive;
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *emailRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *postalField;

@property (weak, nonatomic) IBOutlet UIButton *canadaButton;
@property (weak, nonatomic) IBOutlet UIButton *usaButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MBProgressHUD *waitView;

@property (strong, nonatomic) NSString *country;
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.doneButton.frame.origin.y +self.doneButton.frame.size.height )];
    
    self.emailField.delegate = self;
    [self.emailField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    self.emailRepeatField.delegate = self;
    [self.emailRepeatField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    
    self.passwordField.delegate = self;
    [self.passwordField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    self.passwordRepeatField.delegate = self;
    [self.passwordRepeatField addTarget:self
                                 action:@selector(textFieldDidChange:)
                       forControlEvents:UIControlEventEditingChanged];
    
    self.passwordRepeatField.delegate = self;
    [self.passwordRepeatField addTarget:self
                                 action:@selector(textFieldDidChange:)
                       forControlEvents:UIControlEventEditingChanged];
    
    self.firstnameField.delegate = self;
    [self.firstnameField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    self.lastnameField.delegate = self;
    [self.lastnameField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    self.cityField.delegate = self;
    [self.cityField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
    
    self.postalField.delegate = self;
    [self.postalField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];

    
    canadaFlag = [[UIImage imageNamed:@"Canada_flag.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    canadaFlagInactive = [[UIImage imageNamed:@"Canada_flag_gray.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    usaFlag = [[UIImage imageNamed:@"USA_flag.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    usaFlagInactive = [[UIImage imageNamed:@"USA_flag_gray.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self canadaPressed:nil];
}

-(void)createAndShowWaitViewForRegister
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView:self.view];
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Registering...";
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview:self.waitView];
    }
    
    [self.waitView show:YES];
}

-(void)checkRegister
{
    if (![self.emailField.text isEqualToString:self.emailRepeatField.text])
    {
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Email address in both fields not match" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [message show];
        
        return;
    }
    
    if (![self.emailField.text isEmailAddress])
    {
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Email address not valid" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [message show];
        
        return;
    }
    
    if (![self.passwordField.text isEqualToString:self.passwordRepeatField.text])
    {
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Password in both fields not match" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [message show];
        
        return;
    }
    
    if (self.passwordField.text.length < 6)
    {
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Password should be at least 6 characters" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [message show];
        
        return;
    }
    
    [self.authenticationService registerNewUser:self.emailField.text
                                   withPassword:self.passwordField.text
                                  withFirstname:self.firstnameField.text
                                   withLastname:self.lastnameField.text
                                       withCity:self.cityField.text
                                    withCountry:self.country
                                     withPostal:self.postalField.text
                                        success:^(RegisterResult *registerResult) {
        
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Welcome"
                                message:registerResult.message
                                delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"Ok",nil];
        
        [message show];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
                                            
    } failure:^(RegisterResult *registerResult) {
        
        [self.waitView hide:YES];
        
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Error"
                                message:registerResult.message
                                delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"Ok",nil];
        
        [message show];
        
        return;
        
    }];
}

- (IBAction)donePressed:(UIButton *)sender
{
    [self.doneButton setEnabled:NO];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailRepeatField resignFirstResponder];
    [self.passwordRepeatField resignFirstResponder];
    
    [self createAndShowWaitViewForRegister];
    [self checkRegister];
}

- (IBAction)canadaPressed:(UIButton *)sender
{
    self.country = @"Canada";
}

- (IBAction)usaPressed:(UIButton *)sender
{
    self.country = @"USA";
}

-(void)setCountry:(NSString *)country
{
    _country = country;
    
    if ([_country isEqualToString:@"Canada"])
    {
        [self.canadaButton setImage:canadaFlag forState:UIControlStateNormal];
        [self.usaButton setImage:usaFlagInactive forState:UIControlStateNormal];
    }
    else
    {
        [self.canadaButton setImage:canadaFlagInactive forState:UIControlStateNormal];
        [self.usaButton setImage:usaFlag forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView scrollToView:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.scrollView scrollToY:0];
    
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidChange:(UITextField *)textfield
{
    if (self.emailField.text.length && self.passwordField.text.length &&
        self.emailRepeatField.text.length && self.passwordRepeatField.text.length &&
        self.firstnameField.text.length && self.lastnameField && self.country && self.postalField)
    {
        [self.doneButton setEnabled:YES];
    }
    else
    {
        [self.doneButton setEnabled:NO];
    }
}

@end
