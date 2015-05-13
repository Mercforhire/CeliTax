//
//  AddCatagoryViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AddCatagoryViewController.h"
#import "ItemCatagory.h"
#import "NKOColorPickerView.h"
#import "UserManager.h"
#import "User.h"
#import "UIView+Helper.h"
#import "DataService.h"

@interface AddCatagoryViewController () <UITextFieldDelegate,UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet NKOColorPickerView *colorPickerView;
@property (strong, nonatomic) UIPickerView *namesPicker;
@property (strong, nonatomic) UIToolbar *mypickerToolbar;

@property (nonatomic, strong) NSMutableArray *catagoryNames;

@property BOOL customNameEntryMode; //set to YES if user clicked customNameButton

@end

@implementation AddCatagoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.catagoryNames = [NSMutableArray new];
    
    //sample names
    [self.catagoryNames addObject:@"Rice"];
    [self.catagoryNames addObject:@"Flour"];
    [self.catagoryNames addObject:@"Bread"];
    [self.catagoryNames addObject:@"Cake"];
    
    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color) {
        //Your code handling a color change in the picker view.
        [self colorSelected:color];
    };
    
    [self.colorPickerView setDidChangeColorBlock:colorDidChangeBlock];
    [self.colorPickerView setColor:[UIColor lightGrayColor]];
    
    // Set up the initial state of the catagory names picker.
    self.namesPicker = [[UIPickerView alloc] init];
    self.namesPicker.delegate = self;
    self.namesPicker.dataSource = self;
    self.namesPicker.showsSelectionIndicator = YES;
    
    self.nameField.inputView = self.namesPicker;
    self.nameField.delegate = self;
    
    // Create Custom Name button in UIPickerView
    self.mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56)];
    [self.mypickerToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *customNameButton = [[UIBarButtonItem alloc] initWithTitle:@"Custom Name" style:UIBarButtonItemStylePlain target:self action:@selector(customNameButtonPressed)];
    [barItems addObject:customNameButton];
    [self.mypickerToolbar setItems:barItems animated:YES];
    
    self.nameField.inputAccessoryView = self.mypickerToolbar;
}

-(void)customNameButtonPressed
{
    if (self.customNameEntryMode)
    {
        self.nameField.inputView = self.namesPicker;
        
        self.customNameEntryMode = NO;
    }
    else
    {
        self.nameField.inputView = nil;
        
        self.customNameEntryMode = YES;
    }
    
    [self.nameField resignFirstResponder];
    
    [self.nameField becomeFirstResponder];
}

-(void)colorSelected:(UIColor *)newColor
{
    [self.colorView setBackgroundColor:newColor];
}

- (IBAction)confirmPressed:(UIButton *)sender
{
    [self.manipulationService addCatagoryForUserKey:self.userManager.user.userKey forName:self.nameField.text forColor:self.colorPickerView.color success:^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSString *reason) {
        //should out happen
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view scrollToView:self.nameField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view scrollToY:0];
    
    if ( self.nameField.text.length )
    {
        [self.confirmButton setEnabled:YES];
    }
    else
    {
        [self.confirmButton setEnabled:NO];
    }
    
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark - UIPickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.catagoryNames.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.catagoryNames[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.nameField.text = self.catagoryNames[row];
    
    [self.nameField resignFirstResponder];
}
 
@end
