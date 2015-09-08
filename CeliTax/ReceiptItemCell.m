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
            [self.priceField setText:@"(mL)"];
            
            break;
            
        case UnitL:
            [self.priceField setText:@"(L)"];
            
            break;
            
        case UnitG:
            [self.priceField setText:@"(g)"];
            
            break;
            
        case Unit100G:
            [self.priceField setText:@"(100g)"];
            
            break;
            
        case UnitKG:
            [self.priceField setText:@"(kg)"];
            
            break;
            
        case UnitFloz:
            [self.priceField setText:@"(fl oz)"];
            
            break;
            
        case UnitPt:
            [self.priceField setText:@"(pt)"];
            
            break;
        
        case UnitQt:
            [self.priceField setText:@"(qt)"];
            
            break;
            
        case UnitGal:
            [self.priceField setText:@"(gal)"];
            
            break;
            
        case UnitOz:
            [self.priceField setText:@"(oz)"];
            
            break;
            
        case UnitLb:
            [self.priceField setText:@"(lb)"];
            
            break;
            
        default:
            break;
    }
}

@end
