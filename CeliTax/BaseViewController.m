//
// BaseViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-04-29.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view

    UIView *titleImageContainer = [[UIView alloc] initWithFrame: self.navigationController.navigationBar.frame];
    [titleImageContainer setUserInteractionEnabled: NO];

    UIImageView *titleImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"celitaxlogo_small.png"]];
    [titleImage setFrame: CGRectMake(0, 10, self.navigationController.navigationBar.frame.size.width, 30)];
    [titleImage setContentMode: UIViewContentModeScaleAspectFit];
    [titleImage setUserInteractionEnabled: NO];
    
    [titleImageContainer addSubview:titleImage];

    [self.navigationController.view addSubview: titleImageContainer];
}

@end