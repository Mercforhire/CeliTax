//
// CatagoryTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoryTableViewCell.h"

@implementation CatagoryTableViewCell

- (void) awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

-(void)makeCellAppearInactive
{
    (self.colorBox).backgroundColor = [UIColor lightGrayColor];
    (self.catagoryName).textColor = [UIColor lightGrayColor];
}

-(void)makeCellAppearActive
{
    (self.colorBox).backgroundColor = self.catagoryColor;
    (self.catagoryName).textColor = [UIColor blackColor];
}

@end