//
//  PieView.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-11.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "PieView.h"

// This determines the distance between the pie chart and the labels,
// or the frame, if no labels are present.
// Examples: if this is 1.0, then they are flush, if it's 0.5, then
// the pie chart only goes halfway from the center point to the nearest
// label or edge of the frame.
#define kRadiusPortion 0.90

@implementation PieView {
    CGFloat centerX;
    CGFloat centerY;
    CGFloat radius;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // Compute the center & radius of the circle.
    centerX = frame.size.width / 2.0;
    centerY = frame.size.height / 2.0;
    radius = centerX < centerY ? centerX : centerY;
    radius *= kRadiusPortion;
    
    [self setNeedsDisplay];
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
    
    [self setNeedsDisplay];
}



- (void)drawRect:(CGRect)rect
{
    // Draw a white background for the pie chart.
    // We need to do this since many of our color components have alpha < 1.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextAddArc(context, centerX, centerY, radius, 0, 2 * M_PI, 1);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillPath(context);
    
    CGContextSaveGState(context);
    float shadowSize = radius / 15.0;
    CGContextSetShadow(context, CGSizeMake(shadowSize, shadowSize), shadowSize);
    CGContextBeginTransparencyLayer(context, NULL);
    
    for (int i = 0; i < [self.colors count]; ++i)
    {
        [self drawSlice:i usingColor:self.colors[i] inContext:context];
    }
    
    //if there are no colors, draw a white circle
    if (!self.colors || !self.colors.count)
    {
        [self drawSlice:0 usingColor:[UIColor whiteColor] inContext:context];
    }
    
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
}

- (void)drawSlice:(int)index usingColor:(UIColor *)fillColor inContext:(CGContextRef)context
{
    float oneSlice = 1.0f;
    
    if (self.colors.count)
    {
        oneSlice = 1.0f / self.colors.count;
    }
    
    CGFloat startAngle = 2 * M_PI * oneSlice * index;
    CGFloat endAngle = 2 * M_PI * oneSlice * (index + 1);
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, centerX, centerY, radius, startAngle, endAngle, 0);
    CGPathAddLineToPoint(path, NULL, centerX, centerY);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    if (self.colors.count > 1)
    {
        // Draw the slice outline.
        CGContextSaveGState(context);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGContextAddPath(context, path);
        CGContextSetLineWidth(context, 0.5);
        UIColor* darken = [UIColor colorWithWhite:0.0 alpha:0.2];
        CGContextSetStrokeColorWithColor(context, darken.CGColor);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
    CGPathRelease(path);
}

@end
