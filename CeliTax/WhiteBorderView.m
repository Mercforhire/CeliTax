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
    
    self.borderThickness = 1.0f;
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

- (id)initWithCoder:(NSCoder *)aDecoder;
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, self.borderThickness);
    
    // Drawing code
    if (self.leftBorder)
    {
        CGContextMoveToPoint(context, 0.0f, 0.0f); //start at this point
        
        CGContextAddLineToPoint(context, 0, self.frame.size.height); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.rightBorder)
    {
        CGContextMoveToPoint(context, self.frame.size.width, 0.0f); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.topBorder)
    {
        CGContextMoveToPoint(context, 0.0f, 0.0f); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width, 0); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
    
    if (self.bottomBorder)
    {
        CGContextMoveToPoint(context, 0.0f, self.frame.size.height); //start at this point
        
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height); //draw to this point
        
        // and now draw the Path!
        CGContextStrokePath(context);
    }
}


@end
