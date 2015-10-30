//
//  WhiteBorderView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "WhiteBorderView.h"

@implementation WhiteBorderView


- (void)baseInit
{
    self.topBorder = YES;
    self.bottomBorder = YES;
    self.leftBorder = YES;
    self.rightBorder = YES;
    
    self.borderThickness = 3.0f;
}

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self baseInit];
    }
    return self;
}

-(void)setTopBorder:(BOOL)topBorder
{
    _topBorder = topBorder;
    
    [self setNeedsDisplay];
}

-(void)setLeftBorder:(BOOL)leftBorder
{
    _leftBorder = leftBorder;
    
    [self setNeedsDisplay];
}

-(void)setRightBorder:(BOOL)rightBorder
{
    _rightBorder = rightBorder;
    
    [self setNeedsDisplay];
}

-(void)setBottomBorder:(BOOL)bottomBorder
{
    _bottomBorder = bottomBorder;
    
    [self setNeedsDisplay];
}

-(void)setBorderThickness:(float)borderThickness
{
    _borderThickness = borderThickness;
    
    [self setNeedsDisplay];
}

-(void)setMargin:(float)margin
{
    _margin = margin;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, self.borderThickness);
    
    // Drawing code
    if (self.leftBorder)
    {
        CGContextMoveToPoint(context, self.margin, self.margin); //start at this point
        
        CGContextAddLineToPoint(context, self.margin, self.frame.size.height - self.margin); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.rightBorder)
    {
        CGContextMoveToPoint(context, self.frame.size.width - self.margin, self.margin); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width - self.margin, self.frame.size.height - self.margin); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.topBorder)
    {
        CGContextMoveToPoint(context, self.margin, self.margin); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width - self.margin, self.margin); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.bottomBorder)
    {
        CGContextMoveToPoint(context, self.margin, self.frame.size.height - self.margin); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width - self.margin, self.frame.size.height - self.margin); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
}


@end
