//
//  HollowWhiteButton.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HollowWhiteButton.h"
#import "LookAndFeel.h"

@implementation HollowWhiteButton
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
        [self.titleLabel setTextColor:myLookAndFeel.appGreenColor];
    }
    else
    {
        self.backgroundColor = myLookAndFeel.appGreenColor;
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        
    }
}

- (void) setEnabled: (BOOL) enabled
{
    [super setEnabled: enabled];
    
    if (enabled)
    {
        [myLookAndFeel applyHollowWhiteButtonStyleTo:self];
    }
    else
    {
        [myLookAndFeel applyDisabledButtonStyleTo:self];
    }
}

@end
