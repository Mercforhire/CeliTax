//
// ImageCounterIconView.m
// CeliTax
//
// Created by Leon Chen on 2015-05-16.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ImageCounterIconView.h"
#import "UIFont+Lato.h"

@interface ImageCounterIconView ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UILabel *counterLabel;

@property (nonatomic, strong) UIColor *redColor;

@end

@implementation ImageCounterIconView

- (void) baseInit
{
    [self setBackgroundColor: [UIColor clearColor]];

    self.redColor = [UIColor colorWithRed: 255/255.0f green: 45/255.0f blue: 85/255.0f alpha: 1.0f];

    self.imageButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.imageButton addTarget: self action: @selector(imagePressed) forControlEvents: UIControlEventTouchUpInside];

    [self addSubview: self.imageButton];
    
    self.image = [UIImage imageNamed:@"receipt_icon.png"];

    [self refreshCounterLabel];
}

- (void) refreshCounterLabel
{
    if (self.counterLabel)
    {
        [self.counterLabel removeFromSuperview];
    }

    UIFont *defaultFont = [UIFont latoFontOfSize: 10];
    CGSize labelSize = [[NSString stringWithFormat: @"%ld", (long)self.counter] sizeWithAttributes: @{NSFontAttributeName: defaultFont}];
    labelSize.height = labelSize.height + 4;
    labelSize.width = labelSize.height > labelSize.width ? labelSize.height : labelSize.width;
    
    self.counterLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.size.width - labelSize.width,
                                                                   0,
                                                                   labelSize.width, labelSize.height)];
   
    self.counterLabel.textAlignment = NSTextAlignmentCenter;
    [self.counterLabel setFont: [UIFont latoFontOfSize: 12]];
    [self.counterLabel setBackgroundColor: self.redColor];
    [self.counterLabel setText: [NSString stringWithFormat: @"%ld", (long)self.counter]];
    [self.counterLabel setTextColor: [UIColor whiteColor]];
    [self.counterLabel.layer setCornerRadius: labelSize.height / 2];
    self.counterLabel.clipsToBounds = YES;
    self.counterLabel.userInteractionEnabled = NO;

    [self addSubview: self.counterLabel];
}

- (void) imagePressed
{
    if (self.delegate)
    {
        [self.delegate imageCounterIconClicked];
    }
}

- (id) initWithFrame: (CGRect) frame;
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder;
{
    self = [super initWithCoder: aDecoder];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (void) setCounter: (NSInteger) counter
{
    _counter = counter;

    [self refreshCounterLabel];
}

- (void) setImage: (UIImage *) image
{
    _image = image;

    [self.imageButton setImage: _image forState: UIControlStateNormal];
}

-(void)setToGreen
{
    self.image = [UIImage imageNamed:@"receipt_green_icon.png"];
}

@end