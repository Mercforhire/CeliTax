//
// PasswordRecoveryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "PasswordRecoveryViewController.h"
#import "ViewControllerFactory.h"
#import "PasswordRecoverySentViewController.h"
#import "HollowGreenButton.h"

@interface PasswordRecoveryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet HollowGreenButton *sendEmailButton;

@end

@implementation PasswordRecoveryViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Password Recovery", nil)];
    
    [self.instructionsLabel setText:NSLocalizedString(@"To recover your password, please type in your email address", nil)];
    
    [self.emailAddressField setPlaceholder:NSLocalizedString(@"Email Address", nil)];
    [self.lookAndFeel applyGrayBorderTo: self.emailAddressField];
    [self.lookAndFeel addLeftInsetToTextField: self.emailAddressField];

    [self.sendEmailButton setLookAndFeel:self.lookAndFeel];
    [self.sendEmailButton setTitle:NSLocalizedString(@"Send Email", nil) forState:UIControlStateNormal];
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

- (IBAction) sendEmailPressed: (UIButton *) sender
{
    [self.sendEmailButton setEnabled:NO];
    
    [self.authenticationService forgotPassword:self.emailAddressField.text success:^{
        
        [self.navigationController pushViewController: [self.viewControllerFactory createPasswordRecoverySentViewController] animated: YES];
        
    } failure:^(NSString *reason) {
        
        NSString *errorMessage;
        
        if ([reason isEqualToString: AuthenticationService.USER_DOESNT_EXIST])
        {
            errorMessage = NSLocalizedString(@"This user does not exist", nil);
        }
        else
        {
            errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
        }
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                          message: errorMessage
                                                         delegate: nil cancelButtonTitle: nil
                                                otherButtonTitles: NSLocalizedString(@"Dismiss", nil), nil];
        
        [message show];
        
        [self.sendEmailButton setEnabled:YES];
    }];
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height / 2];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
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