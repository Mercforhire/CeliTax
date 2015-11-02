//
// ReceiptBreakDownItemTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBreakDownItemTableViewCell.h"

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

-(void)setToDisplayUnit:(UnitTypes)unitType
{
    NSString *unitSuffix = @"";
    
    switch (unitType)
    {
        case UnitTypesUnitML:
            unitSuffix = @"(mL)";
            break;
            
        case UnitTypesUnitL:
            unitSuffix = @"(L)";
            break;
            
        case UnitTypesUnitG:
            unitSuffix = @"(g)";
            break;
            
        case UnitTypesUnit100G:
            unitSuffix = @"(100g)";
            break;
            
        case UnitTypesUnitKG:
            unitSuffix = @"(kg)";
            break;
            
        case UnitTypesUnitFloz:
            unitSuffix = @"(lf oz)";
            break;
            
        case UnitTypesUnitQt:
            unitSuffix = @"(qt)";
            break;
            
        case UnitTypesUnitPt:
            unitSuffix = @"(pt)";
            break;
            
        case UnitTypesUnitGal:
            unitSuffix = @"(gal)";
            break;
            
        case UnitTypesUnitOz:
            unitSuffix = @"(oz)";
            break;
            
        case UnitTypesUnitLb:
            unitSuffix = @"(lb)";
            break;
            
        default:
            break;
    }
    
    switch (unitType)
    {
        case UnitTypesUnitML:
        case UnitTypesUnitL:
        case UnitTypesUnitFloz:
        case UnitTypesUnitPt:
        case UnitTypesUnitQt:
        case UnitTypesUnitGal:
            (self.quantityLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Volume-%@", nil), unitSuffix];
            break;
            
        case UnitTypesUnitG:
        case UnitTypesUnit100G:
        case UnitTypesUnitKG:
        case UnitTypesUnitOz:
        case UnitTypesUnitLb:
            (self.quantityLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Weight-%@", nil), unitSuffix];
            break;
            
        default:
            break;
    }
    
    [self.pricePerItemLabel setText:NSLocalizedString(@"Total Price", nil)];
}

@end