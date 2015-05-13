//
//  ModifyCatagoryPopUpViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ModifyCatagoryPopUpViewController.h"

@interface ModifyCatagoryPopUpViewController ()

@end

@implementation ModifyCatagoryPopUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)editPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate editButtonPressed];
    }
}

- (IBAction)transferPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate transferButtonPressed];
    }
}

- (IBAction)deletePressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate deleteButtonPressed];
    }
}


@end
