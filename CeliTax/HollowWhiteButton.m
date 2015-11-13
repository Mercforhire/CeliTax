//
//  HollowWhiteButton.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HollowWhiteButton.h"
#import "CeliTax-Swift.h"


@implementation HollowWhiteButton
{
    LookAndFeel *myLookAndFeel;
}

- (void) applyDefaults
{
    self.enabled = self.enabled;
}

- (void) setLookAndFeel: (LookAndFeel *) lookAndFeel;
{
    myLookAndFeel = lookAndFeel;
    
    [self applyDefaults];
}

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    
    if (highlighted)
    {
        self.backgroundColor = [UIColor whiteColor];
        (self.titleLabel).textColor = myLookAndFeel.appGreenColor;
    }
    else
    {
        self.backgroundColor = myLookAndFeel.appGreenColor;
        (self.titleLabel).textColor = [UIColor whiteColor];
        
    }
}

- (void) setEnabled: (BOOL) enabled
{
    super.enabled = enabled;
    
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
