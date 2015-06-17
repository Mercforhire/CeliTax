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

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder
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
    [self setImage: [UIImage imageNamed: @"greenTrianglePointUp"]];
}

- (void) setGreenArrowDown
{
    [self setImage: [UIImage imageNamed: @"greenTrianglePointDown"]];
}

@end