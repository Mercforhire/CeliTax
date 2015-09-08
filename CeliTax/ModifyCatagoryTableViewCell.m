//
// ModifyCatagoryTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-06-10.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ModifyCatagoryTableViewCell.h"

@implementation ModifyCatagoryTableViewCell

- (void) awakeFromNib
{
    // Initialization code
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    [self.editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [self.transferButton setTitle:NSLocalizedString(@"Transfer", nil) forState:UIControlStateNormal];
    [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

@end