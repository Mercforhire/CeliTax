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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.totalQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.totalAmountLabel setText:NSLocalizedString(@"Total", nil)];
    [self.avgPriceLabel setText:NSLocalizedString(@"Avg $ / non-GF", nil)];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

-(void)makeCellAppearInactive
{
    (self.colorBox).backgroundColor = [UIColor lightGrayColor];
    (self.categoryNameLabel).textColor = [UIColor lightGrayColor];
    
    [self hideLabels];
    
    [self.totalQuantityField setHidden:YES];
    [self.totalAmountField setHidden:YES];
    [self.averageNationalPriceField setHidden:YES];
}

-(void)makeCellAppearActive
{
    (self.colorBox).backgroundColor = self.colorBoxColor;
    (self.categoryNameLabel).textColor = [UIColor blackColor];
    
    [self showLabels];
    
    [self.totalQuantityField setHidden:NO];
    [self.totalAmountField setHidden:NO];
    [self.averageNationalPriceField setHidden:NO];
}

-(void)showLabels
{
    [self.totalQtyLabel setHidden:NO];
    [self.totalAmountLabel setHidden:NO];
    [self.avgPriceLabel setHidden:NO];
    [self.totalAmountDollarSign setHidden:NO];
    [self.avgPriceDollarSign setHidden:NO];
}

-(void)hideLabels
{
    [self.totalQtyLabel setHidden:YES];
    [self.totalAmountLabel setHidden:YES];
    [self.avgPriceLabel setHidden:YES];
    [self.totalAmountDollarSign setHidden:YES];
    [self.avgPriceDollarSign setHidden:YES];
}

@end