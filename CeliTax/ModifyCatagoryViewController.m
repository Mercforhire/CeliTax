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

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    [self.colorPickerView setHidden:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.colorPickerView setHidden:NO];
}

- (void) colorSelected: (UIColor *) newColor
{
    [self.colorBoxView setBackgroundColor: newColor];

    self.catagoryToModify.color = newColor;
}

- (IBAction) confirmPressed: (UIButton *) sender
{
    [self.manipulationService modifyCatagoryForCatagoryID:self.catagoryToModify.identifer
                                                  newName:self.catagoryToModify.name
                                                 newColor:self.catagoryToModify.color
                                                  success:^
    {
        if (self.delegate)
        {
            [self.delegate requestPopUpToDismiss];
        }
        
    } failure:^(NSString *reason) {
        //should not happen
        
    }];
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