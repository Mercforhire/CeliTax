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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        customView = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
        
        // 2. Add as a subview
        [self addSubview:customView];
        
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        customView = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
        
        // 2. Add as a subview
        [self addSubview:customView];
        
        [self baseInit];
    }
    return self;
}

- (void) baseInit
{
    self.backgroundColor = [UIColor clearColor];
    
    (self.flashButton).backgroundColor = [UIColor whiteColor];
    
    self.flashButton.layer.cornerRadius = 5.0f;
    
    self.lightningImageView.image = [self.lightningImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    (self.lightningImageView).tintColor = [UIColor darkGrayColor];
}

-(void)setOn:(BOOL)on
{
    _on = on;
    
    if (_on)
    {
        (self.flashButton).backgroundColor = [UIColor clearColor];
        
        (self.lightningImageView).tintColor = [UIColor colorWithRed:252.0f/255 green:219.0f/255 blue:65.0f/255 alpha:1];
    }
    else
    {
        (self.flashButton).backgroundColor = [UIColor colorWithWhite:220.0f/255 alpha:1];
        
        (self.lightningImageView).tintColor = [UIColor darkGrayColor];
    }
    
}
@end
