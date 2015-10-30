//
//  Triangle.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-07.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Triangle.h"

@implementation Triangle
{
    UIBezierPath* trianglePath;
}

- (void) baseInit
{
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self baseInit];
    }
    
    return self;
}

- (instancetype) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self baseInit];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context); // save state
    
    [[UIColor colorWithRed:116.0f/255 green:191.0f/255 blue:81.0f/255 alpha:1] setFill];
    [trianglePath fill];
    
    CGContextRestoreGState(context);
}

-(void)setPointsUp:(BOOL)pointsUp
{
    _pointsUp = pointsUp;
    
    if (_pointsUp)
    {
        trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(0, self.frame.size.height)];
        [trianglePath addLineToPoint:CGPointMake(self.frame.size.width / 2, 0)];
        [trianglePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [trianglePath closePath];
    }
    else
    {
        trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(0, 0)];
        [trianglePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [trianglePath addLineToPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height)];
        [trianglePath closePath];
    }
    
    [self setNeedsDisplay];
}

@end
