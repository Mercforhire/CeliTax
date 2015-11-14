//
// ModifyCatagoryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ModifyCatagoryViewController.h"
#import "NKOColorPickerView.h"
#import "SolidGreenButton.h"

#import "CeliTax-Swift.h"

@interface ModifyCatagoryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *colorBoxView;
@property (weak, nonatomic) IBOutlet UITextField *catagoryNameField;
@property (weak, nonatomic) IBOutlet NKOColorPickerView *colorPickerView;
@property (weak, nonatomic) IBOutlet SolidGreenButton *confirmButton;

@end

@implementation ModifyCatagoryViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(272, 160);
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.catagoryNameField setPlaceholder:NSLocalizedString(@"Enter Category Name", nil)];
    
    [self.confirmButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    
    (self.colorPickerView).color = self.catagoryToModify.color;
    (self.colorBoxView).backgroundColor = self.catagoryToModify.color;
    
    self.catagoryNameField.text = self.catagoryToModify.name;
    (self.colorPickerView).color = self.catagoryToModify.color;

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color) {
        // Your code handling a color change in the picker view.
        [self colorSelected: color];
    };

    (self.colorPickerView).didChangeColorBlock = colorDidChangeBlock;
    

    self.catagoryNameField.delegate = self;
    [self.catagoryNameField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];
    
    [self.lookAndFeel applySlightlyDarkerBorderTo:self.colorBoxView];
    [self.lookAndFeel applyGrayBorderTo:self.catagoryNameField];
    [self.lookAndFeel addLeftInsetToTextField:self.catagoryNameField];
    
    [self.confirmButton setLookAndFeel:self.lookAndFeel];
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

- (void) colorSelected: (UIColor *) newColor
{
    (self.colorBoxView).backgroundColor = newColor;
    [self.lookAndFeel applySlightlyDarkerBorderTo:self.colorBoxView];

    self.catagoryToModify.color = newColor;
    
    if (self.catagoryNameField.text.length)
    {
        [self.confirmButton setEnabled: YES];
    }
    else
    {
        [self.confirmButton setEnabled: NO];
    }
}

- (IBAction) confirmPressed: (UIButton *) sender
{
    self.catagoryToModify.name = self.catagoryNameField.text;
    
    if ([self.manipulationService modifyCatagoryForCatagoryID:self.catagoryToModify.localID categoryName:self.catagoryToModify.name categoryColor:self.catagoryToModify.color save:YES])
        
    {
        if (self.delegate)
        {
            [self.delegate requestPopUpToDismiss];
        }
    }
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

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

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    [self.view scrollToView: self.catagoryNameField];
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    [self.view scrollToY: 0];

    [textField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textField
{
    if (textField.text.length && ![self.catagoryToModify.name isEqualToString:textField.text])
    {
        [self.confirmButton setEnabled: YES];
    }
    else
    {
        [self.confirmButton setEnabled: NO];
    }
}

@end