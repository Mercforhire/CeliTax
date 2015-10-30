//
// SelectionsPickerTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-06-14.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SelectionsPickerTableViewCell.h"

@implementation SelectionsPickerTableViewCell

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

@end