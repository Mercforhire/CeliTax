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
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

-(void)makeCellAppearInactive
{
    [self.colorBox setBackgroundColor:[UIColor lightGrayColor]];
    [self.catagoryName setTextColor:[UIColor lightGrayColor]];
}

-(void)makeCellAppearActive
{
    [self.colorBox setBackgroundColor:self.catagoryColor];
    [self.catagoryName setTextColor:[UIColor blackColor]];
}

@end