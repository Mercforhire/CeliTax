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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(250, 50);
    }
    return self;
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
