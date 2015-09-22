//
// SelectionCollectionViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-06-13.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SelectionCollectionViewCell.h"

@implementation SelectionCollectionViewCell

- (void) awakeFromNib
{
    // Initialization code
    self.shadowbackground.shadowRadius = 2;
    self.shadowbackground.shadowMask = YIInnerShadowMaskNone;
}

@end