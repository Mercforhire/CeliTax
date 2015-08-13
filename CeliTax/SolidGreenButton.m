//
//  SolidGreenButton.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SolidGreenButton.h"
#import "LookAndFeel.h"

@implementation SolidGreenButton
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
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor: [myLookAndFeel appGreenColor] forState:UIControlStateHighlighted];
    }
    else
    {
        self.backgroundColor = [myLookAndFeel appGreenColor];
    }
}

- (void) setEnabled: (BOOL) enabled
{
    [super setEnabled: enabled];
    
    if (enabled)
    {
        [myLookAndFeel applySolidGreenButtonStyleTo:self];
    }
    else
    {
        [myLookAndFeel applyDisabledButtonStyleTo:self];
    }
}

@end
