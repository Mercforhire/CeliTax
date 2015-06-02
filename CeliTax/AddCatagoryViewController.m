//
// AddCatagoryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "UserManager.h"
#import "User.h"
#import "DataService.h"
#import "SelectionsPickerViewController.h"
#import "ColorPickerViewController.h"
#import "AllColorsPickerViewController.h"
#import "ViewControllerFactory.h"
#import "WYPopoverController.h"

@interface AddCatagoryViewController () <SelectionsPickerPopUpDelegate, ColorPickerViewPopUpDelegate, UIPopoverControllerDelegate, AllColorsPickerViewPopUpDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic, strong) NSMutableArray *catagoryNames;

@property (nonatomic, strong) WYPopoverController *colorPickerPopover;
@property (nonatomic, strong) WYPopoverController *namesPickerPopover;
@property (nonatomic, strong) WYPopoverController *allColorsPickerPopover;

@property (nonatomic, strong) SelectionsPickerViewController *namesPickerViewController;
@property (nonatomic, strong) ColorPickerViewController *colorPickerViewController;
@property (nonatomic, strong) AllColorsPickerViewController *allColorsPickerViewController;

@property (nonatomic, strong) UIButton *nameFieldOverlayButton;

@end

@implementation AddCatagoryViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.catagoryNames = [NSMutableArray new];

    // sample names
    [self.catagoryNames addObject: @"Bread"];
    [self.catagoryNames addObject: @"Rice"];
    [self.catagoryNames addObject: @"Fruit"];
    [self.catagoryNames addObject: @"Flour"];
    [self.catagoryNames addObject: @"Meat"];
    [self.catagoryNames addObject: @"Chicken"];
    [self.catagoryNames addObject: @"Custom"];

    self.colorPickerViewController = [self.viewControllerFactory createColorPickerViewController];
    self.colorPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.colorPickerViewController];
    [self.colorPickerViewController setDelegate: self];
    [self.colorPickerPopover setPopoverContentSize: self.colorPickerViewController.viewSize];

    self.namesPickerViewController = [self.viewControllerFactory createNamesPickerViewControllerWithNames: self.catagoryNames];
    self.namesPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.namesPickerViewController];
    [self.namesPickerViewController setDelegate: self];
    [self.namesPickerPopover setPopoverContentSize: self.namesPickerViewController.viewSize];

    self.allColorsPickerViewController = [self.viewControllerFactory createAllColorsPickerViewController];
    self.allColorsPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.allColorsPickerViewController];
    [self.allColorsPickerViewController setDelegate: self];
    [self.allColorsPickerPopover setPopoverContentSize: self.allColorsPickerViewController.viewSize];

    // conditionally check for any version >= iOS 8 using 'isOperatingSystemAtLeastVersion'
    if ([NSProcessInfo instancesRespondToSelector: @selector(isOperatingSystemAtLeastVersion:)])
    {
        // this is purely to fix the crashing problem
        UIPopoverPresentationController *garbageController = self.popoverPresentationController;
        [garbageController setSourceRect: self.namesPickerViewController.view.frame];
        [garbageController setSourceView: self.namesPickerViewController.view];
    }

    UITapGestureRecognizer *colorBoxPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(colorBoxPressed)];
    [self.colorView addGestureRecognizer: colorBoxPressedTap];

    self.nameField.delegate = self;
    [self.nameField addTarget: self
                       action: @selector(textFieldDidChange:)
             forControlEvents: UIControlEventEditingChanged];

    self.nameFieldOverlayButton = [[UIButton alloc] initWithFrame: self.nameField.frame];
    [self.nameFieldOverlayButton addTarget: self action: @selector(textBoxPressed) forControlEvents: UIControlEventTouchUpInside];

    [self.view addSubview: self.nameFieldOverlayButton];
}

- (void) colorBoxPressed
{
    [self.colorPickerPopover presentPopoverFromRect: self.colorView.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) textBoxPressed
{
    [self.namesPickerPopover presentPopoverFromRect: self.nameField.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) colorSelected: (UIColor *) newColor
{
    [self.colorView setBackgroundColor: newColor];
}

- (IBAction) confirmPressed: (UIButton *) sender
{
    [self.manipulationService addCatagoryForName: self.nameField.text
                                        forColor: self.colorView.backgroundColor
                                         success: ^{
        [self.navigationController popViewControllerAnimated: YES];
    } failure: ^(NSString *reason) {
        DLog(@"self.manipulationService addCatagoryForUserKey failed!");
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.nameField.text.length)
    {
        [self.confirmButton setEnabled: YES];
    }
    else
    {
        [self.confirmButton setEnabled: NO];
    }
}

#pragma mark - NamesPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index
{
    [self.namesPickerPopover dismissPopoverAnimated: YES];

    if (index == self.catagoryNames.count - 1)
    {
        [self.nameField becomeFirstResponder];
    }
    else
    {
        self.nameField.text = self.catagoryNames [index];

        [self.nameField resignFirstResponder];

        [self textFieldDidChange: self.nameField];
    }
}

#pragma mark - ColorPickerViewController

#pragma mark - AllColorsPickerViewPopUpDelegate

- (void) selectedColor: (UIColor *) color
{
    self.colorView.backgroundColor = color;

    [self.colorPickerPopover dismissPopoverAnimated: YES];
}

- (void) customColorPressed
{
    [self.colorPickerPopover dismissPopoverAnimated: NO];

    [self.allColorsPickerPopover presentPopoverFromRect: self.colorView.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) doneButtonPressed
{
    [self.allColorsPickerPopover dismissPopoverAnimated: NO];
}

@end