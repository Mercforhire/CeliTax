//
// ReceiptBreakDownItemTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBreakDownItemTableViewCell.h"
#import "Record.h"

@interface ReceiptBreakDownItemTableViewCell ()

@end

@implementation ReceiptBreakDownItemTableViewCell

- (void) awakeFromNib
{
    // Initialization code

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.quantityLabel setText:NSLocalizedString(@"Qty.", nil)];
    [self.pricePerItemLabel setText:NSLocalizedString(@"Price/Item", nil)];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

-(void)makeCellAppearInactive
{
    (self.colorBoxView).backgroundColor = [UIColor lightGrayColor];
    (self.catagoryName).textColor = [UIColor lightGrayColor];
    
    [self hideLabels];
    [self.quantityField setHidden:YES];
    [self.pricePerItemField setHidden:YES];
}

-(void)makeCellAppearActive
{
    (self.colorBoxView).backgroundColor = self.catagoryColor;
    (self.catagoryName).textColor = [UIColor blackColor];
    
    [self showLabels];
    [self.quantityField setHidden:NO];
    [self.pricePerItemField setHidden:NO];
}

-(void)showLabels
{
    [self.quantityLabel setHidden:NO];
    [self.pricePerItemLabel setHidden:NO];
    [self.dollarSignLabel setHidden:NO];
}

-(void)hideLabels
{
    [self.quantityLabel setHidden:YES];
    [self.pricePerItemLabel setHidden:YES];
    [self.dollarSignLabel setHidden:YES];
}

-(void)setToDisplayItem
{
    [self.quantityLabel setText:NSLocalizedString(@"Qty.", nil)];
    
    [self.pricePerItemLabel setText:NSLocalizedString(@"Price/Item", nil)];
}

-(void)setToDisplayUnit:(NSInteger)unitType
{
    NSString *unitSuffix = @"";
    
    switch (unitType)
    {
        case UnitML:
            unitSuffix = @"(mL)";
            break;
            
        case UnitL:
            unitSuffix = @"(L)";
            break;
            
        case UnitG:
            unitSuffix = @"(g)";
            break;
            
        case Unit100G:
            unitSuffix = @"(100g)";
            break;
            
        case UnitKG:
            unitSuffix = @"(kg)";
            break;
            
        case UnitFloz:
            unitSuffix = @"(lf oz)";
            break;
            
        case UnitQt:
            unitSuffix = @"(qt)";
            break;
            
        case UnitPt:
            unitSuffix = @"(pt)";
            break;
            
        case UnitGal:
            unitSuffix = @"(gal)";
            break;
            
        case UnitOz:
            unitSuffix = @"(oz)";
            break;
            
        case UnitLb:
            unitSuffix = @"(lb)";
            break;
            
        default:
            break;
    }
    
    switch (unitType)
    {
        case UnitML:
        case UnitL:
        case UnitFloz:
        case UnitPt:
        case UnitQt:
        case UnitGal:
            (self.quantityLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Volume-%@", nil), unitSuffix];
            break;
            
        case UnitG:
        case Unit100G:
        case UnitKG:
        case UnitOz:
        case UnitLb:
            (self.quantityLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Weight-%@", nil), unitSuffix];
            break;
            
        default:
            break;
    }
    
    [self.pricePerItemLabel setText:NSLocalizedString(@"Total Price", nil)];
}

@end