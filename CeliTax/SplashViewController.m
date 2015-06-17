//
// SplashViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "ViewControllerFactory.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [self.navigationController pushViewController: [self.viewControllerFactory createLoginViewController] animated: YES];
}

@end