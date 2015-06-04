//
// AccountTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-05-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AccountTableViewCell.h"

@implementation AccountTableViewCell

- (void) awakeFromNib
{
    // Initialization code
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

- (void) setTableCellToSelectedMode
{
    self.leftSideConstraint.constant = 0;
    [self.colorBox setBackgroundColor: self.colorBoxColor];
    [self.catagoryNameLabel setTextColor: [UIColor blackColor]];

    [self.totalQuantityField setHidden: NO];
    [self.totalAmountField setHidden: NO];
    [self.averageNationalPriceField setHidden: NO];
    [self.totalQtyLabel setHidden: NO];
    [self.totalAmountLabel setHidden: NO];
    [self.avgPriceLabel setHidden: NO];
}

- (void) setTableCellToDeselectedMode
{
    self.leftSideConstraint.constant = 15;
    [self.colorBox setBackgroundColor: [UIColor lightGrayColor]];
    [self.catagoryNameLabel setTextColor: [UIColor lightGrayColor]];

    [self.totalQuantityField setHidden: YES];
    [self.totalAmountField setHidden: YES];
    [self.averageNationalPriceField setHidden: YES];
    [self.totalQtyLabel setHidden: YES];
    [self.totalAmountLabel setHidden: YES];
    [self.avgPriceLabel setHidden: YES];
}

@end