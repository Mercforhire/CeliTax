//
// ColorPickerViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-11.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "CeliTax-Swift.h"

@interface ColorPickerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pickButton;

@end

@implementation ColorPickerViewController

- (instancetype) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // Custom initialization
        self.viewSize = CGSizeMake(46, 274);
    }

    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.pickButton setTitle:NSLocalizedString(@"Pick", nil) forState:UIControlStateNormal];
    
    // apply gray border to all subviews
    for (UIView *subview in (self.view).subviews)
    {
        [self.lookAndFeel applySlightlyDarkerBorderTo: subview];
    }
}

- (IBAction) colorBoxPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate selectedColor: sender.backgroundColor];
    }
}

- (IBAction) customerColorButtonPressed: (UIButton *) sender
{
    if (self.delegate)
    {
        [self.delegate customColorPressed];
    }
}

@end