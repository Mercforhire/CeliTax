//
// SendReceiptsToViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-06-08.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SendReceiptsToViewController.h"
#import "NSString+Helper.h"

@interface SendReceiptsToViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation SendReceiptsToViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(264, 125);
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.lookAndFeel applyHollowGreenButtonStyleTo: self.sendButton];

    // Set the property to tell the popover container how big this view will be.
    self.preferredContentSize = self.viewSize;

    self.emailField.delegate = self;
    [self.emailField addTarget: self
                        action: @selector(textFieldDidChange:)
              forControlEvents: UIControlEventEditingChanged];
}

- (IBAction) sendPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate sendReceiptsToEmailRequested: self.emailField.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.emailField.text.length && [self.emailField.text isEmailAddress])
    {
        [self.sendButton setEnabled: YES];
    }
    else
    {
        [self.sendButton setEnabled: NO];
    }
}

@end