//
// ModifyCatagoryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ModifyCatagoryViewController.h"
#import "NKOColorPickerView.h"
#import "UserManager.h"
#import "User.h"
#import "UIView+Helper.h"

@interface ModifyCatagoryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *colorBoxView;
@property (weak, nonatomic) IBOutlet UITextField *catagoryNameField;
@property (weak, nonatomic) IBOutlet NKOColorPickerView *colorPickerView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation ModifyCatagoryViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(272, 280);
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.colorPickerView setColor: self.catagoryToModify.color];
    [self.colorBoxView setBackgroundColor: self.catagoryToModify.color];

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color) {
        // Your code handling a color change in the picker view.
        [self colorSelected: color];
    };

    [self.colorPickerView setDidChangeColorBlock: colorDidChangeBlock];
    [self.colorPickerView setColor: self.catagoryToModify.color];

    self.catagoryNameField.delegate = self;
    self.catagoryNameField.text = self.catagoryToModify.name;
    
    [self.lookAndFeel applyGrayBorderTo:self.colorBoxView];
    [self.lookAndFeel applyGrayBorderTo:self.catagoryNameField];
    [self.lookAndFeel addLeftInsetToTextField:self.catagoryNameField];
    
    [self.lookAndFeel applySolidGreenButtonStyleTo:self.confirmButton];
}

- (void) colorSelected: (UIColor *) newColor
{
    [self.colorBoxView setBackgroundColor: newColor];

    self.catagoryToModify.color = newColor;
}

- (IBAction) confirmPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate requestPopUpToDismiss];
    }
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    [self.view scrollToView: self.catagoryNameField];
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    [self.view scrollToY: 0];

    self.catagoryToModify.name = self.catagoryNameField.text;

    if (self.catagoryNameField.text.length)
    {
        [self.confirmButton setEnabled: YES];
    }
    else
    {
        [self.confirmButton setEnabled: NO];
    }

    [textField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

@end