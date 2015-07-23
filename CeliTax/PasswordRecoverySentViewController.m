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

@property (weak, nonatomic) IBOutlet HollowGreenButton *returnToLoginButton;

@end

@implementation PasswordRecoverySentViewController

- (void) setupUI
{
    [self.returnToLoginButton setLookAndFeel:self.lookAndFeel];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    // delete PasswordRecoveryViewController from navigation controllers stack
    if (self.navigationController.viewControllers.count > 2)
    {
        NSArray *controllers = self.navigationController.viewControllers;
        NSMutableArray *newViewControllers = [NSMutableArray arrayWithArray: controllers];
        [newViewControllers removeObject: [controllers objectAtIndex: self.navigationController.viewControllers.count - 2]];
        self.navigationController.viewControllers = newViewControllers;
    }
}

- (IBAction) returnToLoginPressed: (UIButton *) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

@end