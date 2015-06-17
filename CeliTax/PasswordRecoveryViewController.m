//
// PasswordRecoveryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "PasswordRecoveryViewController.h"
#import "NSString+Helper.h"
#import "UIView+Helper.h"
#import "ViewControllerFactory.h"
#import "PasswordRecoverySentViewController.h"

@interface PasswordRecoveryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;

@end

@implementation PasswordRecoveryViewController

- (void) setupUI
{
    [self.lookAndFeel applyGrayBorderTo: self.emailAddressField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailAddressField];

    [self.lookAndFeel applyHollowGreenButtonStyleTo: self.sendEmailButton];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.emailAddressField.delegate = self;
    [self.emailAddressField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];
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
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view scrollToY: 0 - kbSize.height / 2];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

- (IBAction) sendEmailPressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createPasswordRecoverySentViewController] animated: YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    if (textField == self.emailAddressField && self.emailAddressField.text.length)
    {
        [self sendEmailPressed: self.sendEmailButton];
    }

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.emailAddressField.text.length && [self.emailAddressField.text isEmailAddress])
    {
        [self.sendEmailButton setEnabled: YES];
    }
    else
    {
        [self.sendEmailButton setEnabled: NO];
    }
}

@end