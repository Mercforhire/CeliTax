//
// RegisterViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"
#import "AuthenticationService.h"
#import "RegisterResult.h"
#import "M13Checkbox.h"
#import "HollowGreenButton.h"

@interface RegisterViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *emailRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (weak, nonatomic) IBOutlet UIButton *canadaButton;
@property (weak, nonatomic) IBOutlet UIButton *usaButton;

@property (weak, nonatomic) IBOutlet HollowGreenButton *doneButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MBProgressHUD *waitView;

@property (strong, nonatomic) NSString *country;

@property (weak, nonatomic) IBOutlet M13Checkbox *agreeCheckBox;

@end

@implementation RegisterViewController

- (void) setupUI
{
    [self.lookAndFeel applyGrayBorderTo: self.emailField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailField];

    [self.lookAndFeel applyGrayBorderTo: self.emailRepeatField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailRepeatField];

    [self.lookAndFeel applyGrayBorderTo: self.passwordField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordField];

    [self.lookAndFeel applyGrayBorderTo: self.passwordRepeatField];
    [self.lookAndFeel addLeftInsetToTextField: self.passwordRepeatField];

    [self.lookAndFeel applyGrayBorderTo: self.firstnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.firstnameField];

    [self.lookAndFeel applyGrayBorderTo: self.lastnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.lastnameField];

    [self.doneButton setLookAndFeel:self.lookAndFeel];
    
    [self.agreeCheckBox.titleLabel setFont: [UIFont latoFontOfSize: 13]];
    [self.agreeCheckBox.titleLabel setTextColor: [UIColor blackColor]];
    [self.agreeCheckBox setStrokeColor: [UIColor grayColor]];
    [self.agreeCheckBox setCheckColor: self.lookAndFeel.appGreenColor];
    [self.agreeCheckBox setCheckAlignment: M13CheckboxAlignmentLeft];
    [self.agreeCheckBox.titleLabel setText: @"I agree to the terms and conditions"];
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
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Registering...";
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

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"" message: @"Email address in both fields not match" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (![self.emailField.text isEmailAddress])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"" message: @"Email address not valid" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (![self.passwordField.text isEqualToString: self.passwordRepeatField.text])
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"" message: @"Password in both fields not match" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    if (self.passwordField.text.length < 6)
    {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"" message: @"Password should be at least 6 characters" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
    }

    [self.authenticationService registerNewUser: self.emailField.text
                                   withPassword: self.passwordField.text
                                  withFirstname: self.firstnameField.text
                                   withLastname: self.lastnameField.text
                                    withCountry: self.country
                                        success:^(RegisterResult *registerResult) {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: @"Welcome"
                                          message: registerResult.message
                                         delegate: nil
                                cancelButtonTitle: nil
                                otherButtonTitles: @"Ok", nil];

        [message show];

        [self.navigationController popViewControllerAnimated: YES];

        return;
    } failure:^(RegisterResult *registerResult) {
        [self.waitView hide: YES];

        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle: @"Error"
                                          message: registerResult.message
                                         delegate: nil
                                cancelButtonTitle: nil
                                otherButtonTitles: @"Ok", nil];

        [message show];
        
        [self.doneButton setEnabled: YES];

        return;
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
        [self.canadaButton setAlpha: 1];
        [self.usaButton setAlpha: 0.2];
    }
    else
    {
        [self.canadaButton setAlpha: 0.2];
        [self.usaButton setAlpha: 1];
    }
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailField || textField == self.emailRepeatField)
    {
        textField.text = [textField.text lowercaseString];
    }
    
    if (textField == self.firstnameField || textField == self.lastnameField)
    {
        textField.text = [textField.text capitalizedString];
    }
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