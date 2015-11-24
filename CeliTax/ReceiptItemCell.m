//
//  ReceiptItemCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptItemCell.h"

@interface ReceiptItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceUnitFieldDollarSign;
@property (weak, nonatomic) IBOutlet UILabel *priceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end

@implementation ReceiptItemCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    [self.qtyLabel setText:NSLocalizedString(@"Qty", nil)];
    [self.priceUnitLabel setText:NSLocalizedString(@"Price/Item", nil)];
    [self.totalLabel setText:NSLocalizedString(@"Total", nil)];
}

-(void)setUnitTypeTo:(UnitTypes)unitType
{
    switch (unitType)
    {
        case UnitTypesUnitItem:
            [self.qtyLabel setText:NSLocalizedString(@"Qty", nil)];
            [self.priceUnitLabel setText:NSLocalizedString(@"Price/Item", nil)];
            [self.totalLabel setText:NSLocalizedString(@"Total", nil)];
            
            [self.priceField setUserInteractionEnabled:YES];
            [self.totalField setUserInteractionEnabled:NO];
            
            [self.priceUnitFieldDollarSign setHidden:NO];
            
            break;
            
        case UnitTypesUnitML:
        case UnitTypesUnitL:
        case UnitTypesUnitFloz:
        case UnitTypesUnitPt:
        case UnitTypesUnitQt:
        case UnitTypesUnitGal:
            
            [self.qtyLabel setText:NSLocalizedString(@"Volume", nil)];
            [self.priceUnitLabel setText:NSLocalizedString(@"Unit", nil)];
            [self.totalLabel setText:NSLocalizedString(@"Total Cost", nil)];
            
            [self.priceField setUserInteractionEnabled:NO];
            [self.totalField setUserInteractionEnabled:YES];
            
            [self.priceUnitFieldDollarSign setHidden:YES];
            
            break;
            
        default:
            
            [self.qtyLabel setText:NSLocalizedString(@"Weight", nil)];
            [self.priceUnitLabel setText:NSLocalizedString(@"Unit", nil)];
            [self.totalLabel setText:NSLocalizedString(@"Total Cost", nil)];
            
            [self.priceField setUserInteractionEnabled:NO];
            [self.totalField setUserInteractionEnabled:YES];
            
            [self.priceUnitFieldDollarSign setHidden:YES];
            
            break;
    }
    
    switch (unitType)
    {
        case UnitTypesUnitItem:
            
            break;
            
        case UnitTypesUnitML:
            (self.priceField).text = @"(mL)";
            
            break;
            
        case UnitTypesUnitL:
            (self.priceField).text = @"(L)";
            
            break;
            
        case UnitTypesUnitG:
            (self.priceField).text = @"(g)";
            
            break;
            
        case UnitTypesUnit100G:
            (self.priceField).text = @"(100g)";
            
            break;
            
        case UnitTypesUnitKG:
            (self.priceField).text = @"(kg)";
            
            break;
            
        case UnitTypesUnitFloz:
            (self.priceField).text = @"(fl oz)";
            
            break;
            
        case UnitTypesUnitPt:
            (self.priceField).text = @"(pt)";
            
            break;
        
        case UnitTypesUnitQt:
            (self.priceField).text = @"(qt)";
            
            break;
            
        case UnitTypesUnitGal:
            (self.priceField).text = @"(gal)";
            
            break;
            
        case UnitTypesUnitOz:
            (self.priceField).text = @"(oz)";
            
            break;
            
        case UnitTypesUnitLb:
            (self.priceField).text = @"(lb)";
            
            break;
            
        default:
            break;
    }
}

@end
