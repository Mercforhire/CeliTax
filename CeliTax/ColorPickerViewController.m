//
//  ColorPickerViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-11.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController ()


@end

@implementation ColorPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (IBAction)colorBoxPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate selectedColor:sender.backgroundColor];
    }
}

- (IBAction)customerColorButtonPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate customColorPressed];
    }
}

@end
