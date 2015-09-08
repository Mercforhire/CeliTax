//
//  FlashButtonView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "FlashButtonView.h"

@interface FlashButtonView ()

@property (weak, nonatomic) IBOutlet UIImageView *lightningImageView;

@end

@implementation FlashButtonView
{
    FlashButtonView *customView;
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
        
        [self baseInit];
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
        
        [self baseInit];
    }
    return self;
}

- (void) baseInit
{
    [self setBackgroundColor: [UIColor clearColor]];
    
    [self.flashButton setBackgroundColor:[UIColor whiteColor]];
    
    self.flashButton.layer.cornerRadius = 5.0f;
    
    self.lightningImageView.image = [self.lightningImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.lightningImageView setTintColor:[UIColor darkGrayColor]];
}

-(void)setOn:(BOOL)on
{
    _on = on;
    
    if (_on)
    {
        [self.flashButton setBackgroundColor:[UIColor clearColor]];
        
        [self.lightningImageView setTintColor:[UIColor colorWithRed:252.0f/255 green:219.0f/255 blue:65.0f/255 alpha:1]];
    }
    else
    {
        [self.flashButton setBackgroundColor:[UIColor colorWithWhite:220.0f/255 alpha:1]];
        
        [self.lightningImageView setTintColor:[UIColor darkGrayColor]];
    }
    
}
@end
