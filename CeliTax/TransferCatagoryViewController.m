//
//  TransferCatagoryViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TransferCatagoryViewController.h"
#import "UserManager.h"
#import "User.h"
#import "ItemCatagory.h"

@interface TransferCatagoryViewController () <UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fromCatagoryName;
@property (weak, nonatomic) IBOutlet UITextField *toCatagoryName;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;

@property (strong, nonatomic) NSArray *catagories;
@property (strong, nonatomic) ItemCatagory *fromCatagory;
@property (strong, nonatomic) ItemCatagory *toCatagory;

@property (strong, nonatomic) UIPickerView *fromPicker;
@property (strong, nonatomic) UIPickerView *toPicker;

@end

@implementation TransferCatagoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.dataService fetchCatagoriesForUserKey:self.userManager.user.userKey success:^(NSArray *catagories) {
        self.catagories = catagories;
    } failure:^(NSString *reason) {
        //should not happen
    }];
    
    NSAssert(self.catagories.count >= 2, @"Must have more than two catagories to attempt to transfer");
    
    self.fromCatagoryName.delegate = self;
    [self.fromCatagoryName addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    self.fromPicker = [[UIPickerView alloc] init];
    self.fromPicker.delegate = self;
    self.fromPicker.dataSource = self;
    self.fromPicker.showsSelectionIndicator = YES;
    
    self.fromCatagoryName.inputView = self.fromPicker;
    
    self.toCatagoryName.delegate = self;
    [self.toCatagoryName addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    
    self.toPicker = [[UIPickerView alloc] init];
    self.toPicker.delegate = self;
    self.toPicker.dataSource = self;
    self.toPicker.showsSelectionIndicator = YES;
    
    self.toCatagoryName.inputView = self.toPicker;
}

- (IBAction)transferPressed:(UIButton *)sender
{
    [self.manipulationService transferCatagoryForUserKey:self.userManager.user.userKey fromCatagoryID:self.fromCatagory.identifer toCatagoryID:self.toCatagory.identifer success:^{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success"
                                                          message:@"Transfer complete"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok",nil];
        
        [message show];
    } failure:^(NSString *reason) {
        DLog(@"self.manipulationService transferCatagoryForUserKey FAILED!");
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if( [title isEqualToString: @"Ok"] )
    {
        if (self.delegate)
        {
            [self.delegate requestPopUpToDismiss];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidChange:(UITextField *)textfield
{
    if (self.fromCatagoryName.text.length && self.toCatagoryName.text.length )
    {
        [self.transferButton setEnabled:YES];
    }
    else
    {
        [self.transferButton setEnabled:NO];
    }
}

#pragma mark - UIPickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.fromPicker)
    {
        return self.catagories.count;
    }
    else if (pickerView == self.toPicker)
    {
        return self.catagories.count - 1;
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.fromPicker)
    {
        return self.catagories[row];
    }
    else if (pickerView == self.toPicker)
    {
        //skip to the next one
        if (self.catagories[row] == self.toCatagory)
        {
            return self.catagories[row + 1];
        }
        else
        {
            return self.catagories[row];
        }
    }
    
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.fromPicker)
    {
        self.fromCatagory = self.catagories[row];
        
        self.toCatagory = nil;
        
        [self.fromCatagoryName resignFirstResponder];
        
        DLog(@"From Catagory set to %@", self.fromCatagory.name);
    }
    else if (pickerView == self.toPicker)
    {
        [self.toCatagoryName resignFirstResponder];
        
        //skip to the next one
        if (self.catagories[row] == self.toCatagory)
        {
            self.toCatagory = self.catagories[row + 1];
        }
        else
        {
            self.toCatagory = self.catagories[row];
        }
        
        DLog(@"To Catagory set to %@", self.toCatagory.name);
    }
}

@end
