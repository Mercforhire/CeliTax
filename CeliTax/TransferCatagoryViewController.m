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
#import "Catagory.h"

@interface TransferCatagoryViewController () <UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *toCatagoryName;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;

@property (strong, nonatomic) NSMutableArray *catagories;

@property (strong, nonatomic) Catagory *toCatagory;

@property (strong, nonatomic) UIPickerView *toPicker;

@end

@implementation TransferCatagoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(300, 162);
    }
    return self;
}

-(void)setToCatagory:(Catagory *)toCatagory
{
    _toCatagory = toCatagory;
    
    if (_toCatagory)
    {
        self.toCatagoryName.text = _toCatagory.name;
    }
    else
    {
        self.toCatagoryName.text = @"";
    }
    
    [self checkAndEnableOrDisableConfirmButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.catagories = [NSMutableArray new];
    
    [self.dataService fetchCatagoriesSuccess:^(NSArray *catagories) {
        
        for (Catagory *catagory in catagories)
        {
            if (catagory.identifer != self.fromCatagory.identifer)
            {
                [self.catagories addObject:catagory];
            }
        }
        
    } failure:^(NSString *reason) {
        //should not happen
    }];
    
    NSAssert(self.catagories.count >= 2, @"Must have more than two catagories to attempt to transfer");
    
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
    [self.manipulationService transferCatagoryFromCatagoryID:self.fromCatagory.identifer toCatagoryID:self.toCatagory.identifer success:^{
        
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

-(void)checkAndEnableOrDisableConfirmButton
{
    if ( self.toCatagoryName.text.length )
    {
        [self.transferButton setEnabled:YES];
    }
    else
    {
        [self.transferButton setEnabled:NO];
    }
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
    [self checkAndEnableOrDisableConfirmButton];
}

#pragma mark - UIPickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.toPicker)
    {
        return self.catagories.count;
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.toPicker)
    {
        Catagory *thisCatagory = self.catagories[row];
        
        return thisCatagory.name;
    }
    
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.toPicker)
    {
        [self.toCatagoryName resignFirstResponder];
        
        self.toCatagory = self.catagories[row];
        
        DLog(@"To Catagory set to %@", self.toCatagory.name);
    }
}

@end
