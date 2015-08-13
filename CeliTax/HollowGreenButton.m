//
//  HollowGreenButton.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HollowGreenButton.h"
#import "LookAndFeel.h"

@implementation HollowGreenButton
{
    LookAndFeel *myLookAndFeel;
}

- (void) applyDefaults
{
    [self setEnabled:self.enabled];
}

- (void) setLookAndFeel: (LookAndFeel *) lookAndFeel;
{
    myLookAndFeel = lookAndFeel;
    
    [self applyDefaults];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        self.backgroundColor = [myLookAndFeel appGreenColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void) setEnabled: (BOOL) enabled
{
    [super setEnabled: enabled];
    
    if (enabled)
    {
        [myLookAndFeel applyHollowGreenButtonStyleTo:self];
    }
    else
    {
        [myLookAndFeel applyDisabledButtonStyleTo:self];
    }
}

@end
