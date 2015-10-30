//
//  ReceiptItemCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptItemCell.h"
#import "Record.h"

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

-(void)setUnitTypeTo:(NSInteger)unitType
{
    switch (unitType)
    {
        case UnitItem:
            [self.qtyLabel setText:NSLocalizedString(@"Qty", nil)];
            [self.priceUnitLabel setText:NSLocalizedString(@"Price/Item", nil)];
            [self.totalLabel setText:NSLocalizedString(@"Total", nil)];
            
            [self.priceField setUserInteractionEnabled:YES];
            [self.totalField setUserInteractionEnabled:NO];
            
            [self.priceUnitFieldDollarSign setHidden:NO];
            
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
        case UnitItem:
            
            break;
            
        case UnitML:
            (self.priceField).text = @"(mL)";
            
            break;
            
        case UnitL:
            (self.priceField).text = @"(L)";
            
            break;
            
        case UnitG:
            (self.priceField).text = @"(g)";
            
            break;
            
        case Unit100G:
            (self.priceField).text = @"(100g)";
            
            break;
            
        case UnitKG:
            (self.priceField).text = @"(kg)";
            
            break;
            
        case UnitFloz:
            (self.priceField).text = @"(fl oz)";
            
            break;
            
        case UnitPt:
            (self.priceField).text = @"(pt)";
            
            break;
        
        case UnitQt:
            (self.priceField).text = @"(qt)";
            
            break;
            
        case UnitGal:
            (self.priceField).text = @"(gal)";
            
            break;
            
        case UnitOz:
            (self.priceField).text = @"(oz)";
            
            break;
            
        case UnitLb:
            (self.priceField).text = @"(lb)";
            
            break;
            
        default:
            break;
    }
}

@end
