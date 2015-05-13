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

@interface RegisterViewController () <UITextFieldDelegate,UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *emailRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRepeatField;

@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (strong, nonatomic) UIPickerView *countryPicker;
@property (nonatomic, strong) NSMutableArray *countrySelections;
@property (weak, nonatomic) IBOutlet UITextField *postalField;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    self.countryField.delegate = self;
    [self.countryField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
    
    self.postalField.delegate = self;
    [self.postalField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
    
    //sample names
    self.countrySelections = [NSMutableArray new];
    
    [self.countrySelections addObject:@"Canada"];
    [self.countrySelections addObject:@"USA"];
    
    // Set up the initial state of the catagory names picker.
    self.countryPicker = [[UIPickerView alloc] init];
    self.countryPicker.delegate = self;
    self.countryPicker.dataSource = self;
    self.countryPicker.showsSelectionIndicator = YES;
    
    self.countryField.inputView = self.countryPicker;
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
                                    withCountry:self.countryField.text
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view scrollToView:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view scrollToY:0];
    
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidChange:(UITextField *)textfield
{
    if (self.emailField.text.length && self.passwordField.text.length &&
        self.emailRepeatField.text.length && self.passwordRepeatField.text.length &&
        self.firstnameField.text.length && self.lastnameField && self.countryField && self.postalField)
    {
        [self.doneButton setEnabled:YES];
    }
    else
    {
        [self.doneButton setEnabled:NO];
    }
}

#pragma mark - UIPickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.countrySelections.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.countrySelections[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.countryField.text = self.countrySelections[row];
    
    [self.countryField resignFirstResponder];
}

@end
