//
// RegisterViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "M13Checkbox.h"
#import "HollowGreenButton.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *emailRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (weak, nonatomic) IBOutlet UIButton *canadaButton;
@property (weak, nonatomic) IBOutlet UIButton *usaButton;

@property (weak, nonatomic) IBOutlet UILabel *taxCountryLabel;

@property (weak, nonatomic) IBOutlet HollowGreenButton *doneButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MBProgressHUD *waitView;

@property (strong, nonatomic) NSString *country;

@property (weak, nonatomic) IBOutlet UIButton *termsButton;

@property (weak, nonatomic) IBOutlet M13Checkbox *agreeCheckBox;

@end

@implementation RegisterViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Create Account", nil)];
    
    [self.lookAndFeel applyGrayBorderTo: self.emailField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField];
    [self.emailField setPlaceholder:NSLocalizedString(@"Please enter email address", nil)];

    [self.lookAndFeel applyGrayBorderTo: self.emailRepeatField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailRepeatField];
    [self.emailRepeatField setPlaceholder:NSLocalizedString(@"Please re-enter your email address", nil)];

    [self.lookAndFeel applyGrayBorderTo: self.passwordField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordField];
    [self.passwordField setPlaceholder:NSLocalizedString(@"Please enter your password", nil)];

    [self.lookAndFeel applyGrayBorderTo: self.passwordRepeatField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordRepeatField];
    [self.passwordRepeatField setPlaceholder:NSLocalizedString(@"Please re-enter your password", nil)];

    [self.lookAndFeel applyGrayBorderTo: self.firstnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.firstnameField];
    [self.firstnameField setPlaceholder:NSLocalizedString(@"First Name", nil)];

    [self.lookAndFeel applyGrayBorderTo: self.lastnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.lastnameField];
    [self.lastnameField setPlaceholder:NSLocalizedString(@"Last Name", nil)];

    [self.taxCountryLabel setText:NSLocalizedString(@"Tax Country", nil)];
    
    [self.doneButton setLookAndFeel:self.lookAndFeel];
    [self.doneButton setTitle:NSLocalizedString(@"Create Account", nil) forState:UIControlStateNormal];
    
    [self.termsButton setTitle:NSLocalizedString(@"Terms and Conditions", nil) forState:UIControlStateNormal];
    
    (self.agreeCheckBox.titleLabel).font = [UIFont latoFontOfSize: 13];
    (self.agreeCheckBox.titleLabel).textColor = [UIColor blackColor];
    (self.agreeCheckBox).strokeColor = [UIColor grayColor];
    (self.agreeCheckBox).checkColor = self.lookAndFeel.appGreenColor;
    (self.agreeCheckBox).checkAlignment = M13CheckboxAlignmentLeft;
    [self.agreeCheckBox.titleLabel setNumberOfLines:2];
    [self.agreeCheckBox.titleLabel setText: NSLocalizedString(@"I have read and agree with the terms and conditions", nil)];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.emailField.delegate = self;
    [self.emailField addTarget: self
                        action: @selector(textFieldDidChange:)
              forControlEvents: UIControlEventEditingChanged];

    self.emailRepeatField.delegate = self;
    [self.emailRepeatField addTarget: self
                              action: @selector(textFieldDidChange:)
                    forControlEvents: UIControlEventEditingChanged];

    self.passwordField.delegate = self;
    [self.passwordField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];

    self.passwordRepeatField.delegate = self;
    [self.passwordRepeatField addTarget: self
                                 action: @selector(textFieldDidChange:)
                       forControlEvents: UIControlEventEditingChanged];

    self.passwordRepeatField.delegate = self;
    [self.passwordRepeatField addTarget: self
                                 action: @selector(textFieldDidChange:)
                       forControlEvents: UIControlEventEditingChanged];

    self.firstnameField.delegate = self;
    [self.firstnameField addTarget: self
                            action: @selector(textFieldDidChange:)
                  forControlEvents: UIControlEventEditingChanged];

    self.lastnameField.delegate = self;
    [self.lastnameField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];

    [self.agreeCheckBox addTarget: self
                           action: @selector(agreeChecked:)
                 forControlEvents: UIControlEventValueChanged];
    
    [self canadaPressed: nil];
}

- (void) agreeChecked: (M13Checkbox *) checkBox
{
    [self textFieldDidChange:nil];
}

- (void) createAndShowWaitViewForRegister
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Registering...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }

    [self.waitView show: YES];
}

- (void) checkRegister
{
    if (![self.emailField.text isEqualToString: self.emailRepeatField.text])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Email address in both fields do not match", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (![self.emailField.text isEmailAddress])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Email address is not valid", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (![self.passwordField.text isEqualToString: self.passwordRepeatField.text])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Password in both fields do not match", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (self.passwordField.text.length < 6)
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: NSLocalizedString(@"Password has to be least 6 characters long", nil)
                                                         delegate: nil
                                                cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    [self.authenticationService registerNewUser: self.emailField.text
                                       password: self.passwordField.text
                                      firstname: self.firstnameField.text
                                       lastname: self.lastnameField.text
                                        country: self.country
                                        success:^(RegisterResult *registerResult)
    {
        
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Welcome", nil)
                                          message: NSLocalizedString(@"Please login with your new account", nil)
                                         delegate: nil
                                cancelButtonTitle: nil
                                otherButtonTitles: NSLocalizedString(@"Ok", nil), nil];

        [message show];

        [self.navigationController popViewControllerAnimated: YES];
        
    } failure:^(RegisterResult *registerResult) {
        
        [self.waitView hide: YES];
        
        NSString *errorMessage;
        
        if ([registerResult.message isEqualToString: AuthenticationService.USER_ALREADY_EXIST])
        {
            errorMessage = NSLocalizedString(@"This email address is already used by another account. Please use a different email address", nil);
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
                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];

        [message show];
        
        [self.doneButton setEnabled: YES];
        
    }];
}

- (IBAction) donePressed: (UIButton *) sender
{
    [self.doneButton setEnabled: NO];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailRepeatField resignFirstResponder];
    [self.passwordRepeatField resignFirstResponder];

    [self createAndShowWaitViewForRegister];
    [self checkRegister];
}

- (IBAction) canadaPressed: (UIButton *) sender
{
    self.country = @"Canada";
}

- (IBAction) usaPressed: (UIButton *) sender
{
    self.country = @"USA";
}

- (void) setCountry: (NSString *) country
{
    _country = country;

    if ([_country isEqualToString: @"Canada"])
    {
        (self.canadaButton).alpha = 1;
        (self.usaButton).alpha = 0.2;
    }
    else
    {
        (self.canadaButton).alpha = 0.2;
        (self.usaButton).alpha = 1;
    }
}

- (IBAction)termsAndConditionsPressed:(UIButton *)sender
{
    [Utils OpenLink:@"http://celitax.ca/terms_of_service.html"];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView scrollToView:textField];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailField || textField == self.emailRepeatField)
    {
        textField.text = (textField.text).lowercaseString;
    }
    
    if (textField == self.firstnameField || textField == self.lastnameField)
    {
        textField.text = (textField.text).capitalizedString;
    }
    
    [self.scrollView scrollToY:0];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    NSString *emailFieldTrimmedString = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordFieldTrimmedString = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailRepeatFieldTrimmedString = [self.emailRepeatField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordRepeatFieldTrimmedString = [self.passwordRepeatField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstnameFieldTrimmedString = [self.firstnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastnameFieldTrimmedString = [self.lastnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailFieldTrimmedString && passwordFieldTrimmedString &&
        emailRepeatFieldTrimmedString && passwordRepeatFieldTrimmedString &&
        firstnameFieldTrimmedString && lastnameFieldTrimmedString && self.country &&
        self.agreeCheckBox.checkState == M13CheckboxStateChecked)
    {
        [self.doneButton setEnabled: YES];
    }
    else
    {
        [self.doneButton setEnabled: NO];
    }
}

@end