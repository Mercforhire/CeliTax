//
// PasswordRecoverySentViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "PasswordRecoverySentViewController.h"
#import "HollowGreenButton.h"

@interface PasswordRecoverySentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet HollowGreenButton *returnToLoginButton;

@end

@implementation PasswordRecoverySentViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Password Recovery", nil)];
    
    [self.instructionsLabel setText:NSLocalizedString(@"Thank you, an email has been sent with recovery options", nil)];
    
    [self.returnToLoginButton setLookAndFeel:self.lookAndFeel];
    [self.returnToLoginButton setTitle:NSLocalizedString(@"Return to Login", nil) forState:UIControlStateNormal];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    // delete PasswordRecoveryViewController from navigation controllers stack
    // TODO: make this less risky by targetting the PasswordRecoveryViewController to delete
    if (self.navigationController.viewControllers.count > 2)
    {
        NSArray *controllers = self.navigationController.viewControllers;
        NSMutableArray *newViewControllers = [NSMutableArray arrayWithArray: controllers];
        [newViewControllers removeObject: controllers[self.navigationController.viewControllers.count - 2]];
        self.navigationController.viewControllers = newViewControllers;
    }
}

- (IBAction) returnToLoginPressed: (UIButton *) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

@end