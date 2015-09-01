//
//  ProfileBarView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-18.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ProfileBarView.h"
#import "SolidGreenButton.h"

@implementation ProfileBarView
{
    ProfileBarView *customView;
    
    LookAndFeel *myLookAndFeel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        [self addSubview:customView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        [self addSubview:customView];
        
    }
    return self;
}

- (void) setLookAndFeel: (LookAndFeel *) lookAndFeel;
{
    myLookAndFeel = lookAndFeel;
    
    [self.editButton1 setLookAndFeel:myLookAndFeel];
}

@end
