//
//  HelpScreenViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HelpScreenViewController.h"

@interface HelpScreenViewController () {
    RevealBlock _revealBlock;
}

@end

@implementation HelpScreenViewController

-(id)initWithRevealBlock:(RevealBlock)revealBlock
{
    if (self = [super initWithNibName:@"HelpScreenViewController" bundle:nil])
    {
        _revealBlock = [revealBlock copy];
        
        //initialize the slider bar menu button
        UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed:7.0/255 green:61.0/255 blue:48.0/255 alpha:1.0f];
        [menuButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = menuItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//slide out the slider bar
- (void)revealSidebar
{
    _revealBlock();
}

@end
