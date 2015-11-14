//
// BaseViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "CeliTax-Swift.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view

    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.title = @"";
    self.navigationItem.backBarButtonItem = item;
    
    if (!self.tutorialManager.navigationController)
    {
        self.tutorialManager.navigationController = self.navigationController;
    }
}

@end