//
//  UIView+Helper.m
//  Inspection
//
//  Created by Phil Denis on 2013-03-02.
//  Copyright (c) 2013 Openlane. All rights reserved.
//

#import "UIView+Helper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Helper)

- (void) centerInView: (UIView *) view
{
    [self centerHorizontallyInView: view];
    [self centerVerticallyInView: view];
}

- (void) centerHorizontallyInView: (UIView *) view
{
    CGRect frame = self.frame;
    CGFloat x = (view.frame.size.width - frame.size.width) / 2;
    frame.origin = CGPointMake(x, frame.origin.y);

    self.frame = frame;
}

- (void) centerVerticallyInView: (UIView *) view
{
    CGRect frame = self.frame;
    CGFloat y = (view.frame.size.height - frame.size.height) / 2;
    frame.origin = CGPointMake(frame.origin.x, y);

    self.frame = frame;
}

-(void)scrollToY:(float)y
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    self.transform = CGAffineTransformMakeTranslation(0, y);
    [UIView commitAnimations];
}

-(void)scrollToView:(UIView *)view
{
    CGRect theFrame = view.frame;
    float y = theFrame.origin.y - 15;
    y -= (y/1.7);
    [self scrollToY:-y];
}


-(void)scrollElement:(UIView *)view toPoint:(float)y
{
    CGRect theFrame = view.frame;
    float orig_y = theFrame.origin.y;
    float diff = y - orig_y;
    if (diff < 0)
    {
        [self scrollToY:diff];
    }
    else
    {
        [self scrollToY:0];
    }
}

@end
