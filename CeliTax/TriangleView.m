//
// triangleView.m
// CeliTax
//
// Created by Leon Chen on 2015-06-10.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (void) baseInit
{
    self.backgroundColor = [UIColor clearColor];
    
    [self setGreenArrowDown];
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

- (void) setGreenArrowUp
{
    self.image = [UIImage imageNamed: @"greenTrianglePointUp"];
}

- (void) setGreenArrowDown
{
    self.image = [UIImage imageNamed: @"greenTrianglePointDown"];
}

@end