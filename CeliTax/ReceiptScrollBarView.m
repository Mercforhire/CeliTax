//
//  ReceiptScrollBarView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptScrollBarView.h"

@interface ReceiptScrollBarView ()
{
    UIScrollView *scollView;
}

@end

#define PHOTO_CELL_HEIGHT_VS_WIDTH_RATIO    1.3333
#define PHOTO_CELL_TOP_MARGIN               0
#define PHOTO_CELL_BOTTOM_MARGIN            0
#define PHOTO_CELL_SIDE_MARGIN              0

@implementation ReceiptScrollBarView

- (void)baseInit
{
    scollView = [UIScrollView new];
    
    [scollView setShowsHorizontalScrollIndicator:NO];
    [scollView setShowsVerticalScrollIndicator:NO];
    [scollView setBounces:NO];
    
    [self addSubview:scollView];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //self.frame will now return something
    [self baseInit];
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [scollView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.shadowRadius = 2.5f;
    maskLayer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(self.bounds, 8, 8), 10, 10, nil);
    maskLayer.shadowOpacity = 1;
    maskLayer.shadowOffset = CGSizeZero;
    maskLayer.shadowColor = [UIColor whiteColor].CGColor;
    
    self.layer.mask = maskLayer;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

-(void)setImages:(NSArray *)images
{
    if (images)
    {
        _images = images;
        
        //remove all subviews
        NSArray *viewsToRemove = [scollView subviews];
        for (UIView *v in viewsToRemove)
        {
            [v removeFromSuperview];
        }
        
        //calculate the total width needed to display all images
        NSInteger widthOfOneImage = self.frame.size.width - PHOTO_CELL_SIDE_MARGIN * 2;
        NSInteger heightOfOneImage = widthOfOneImage * PHOTO_CELL_HEIGHT_VS_WIDTH_RATIO;
        
        long heightOfAllImages = PHOTO_CELL_TOP_MARGIN + heightOfOneImage * images.count + PHOTO_CELL_BOTTOM_MARGIN;
        
        //add all the images
        for (int i = 0; i < images.count; i++)
        {
            UIButton *imageButton = [[UIButton alloc] initWithFrame:
                                     CGRectMake(PHOTO_CELL_SIDE_MARGIN,
                                                PHOTO_CELL_TOP_MARGIN + heightOfOneImage * i,
                                                widthOfOneImage,
                                                heightOfOneImage)];
            [imageButton setBackgroundImage:images[i] forState:UIControlStateNormal];
            [imageButton setTag:i];
            [imageButton setBackgroundColor:[UIColor orangeColor]];
            [imageButton addTarget:self action:@selector(imageViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [scollView addSubview:imageButton];
        }
        
        [scollView setContentSize:CGSizeMake(self.frame.size.width, heightOfAllImages)];
        
        [self setNeedsDisplay];
    }
    //clear all images
    else
    {
        //remove all subviews
        NSArray *viewsToRemove = [scollView subviews];
        for (UIView *v in viewsToRemove)
        {
            [v removeFromSuperview];
        }
        
        [self setNeedsDisplay];
    }
}

-(void)imageViewClicked:(UIButton *)sender
{
    DLog(@"Receipt %ld pressed", (long)sender.tag);
}

@end
