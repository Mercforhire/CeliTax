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
}

-(void)setUnitTypeTo:(NSInteger)unitType
{
    switch (unitType)
    {
        case UnitItem:
            [self.qtyLabel setText:@"Qty"];
            [self.priceUnitLabel setText:@"Price/Item"];
            [self.totalLabel setText:@"Total"];
            
            [self.priceField setUserInteractionEnabled:YES];
            [self.totalField setUserInteractionEnabled:NO];
            
            [self.priceUnitFieldDollarSign setHidden:NO];
            
            break;
            
        case UnitML:
        case UnitL:
        case UnitG:
        case Unit100G:
        case UnitKG:
            [self.qtyLabel setText:@"Weight"];
            [self.priceUnitLabel setText:@"Unit"];
            [self.totalLabel setText:@"Total Cost"];
            
            [self.priceField setUserInteractionEnabled:NO];
            [self.totalField setUserInteractionEnabled:YES];
            
            [self.priceUnitFieldDollarSign setHidden:YES];
            
            break;
            
        default:
            break;
    }
    
    switch (unitType)
    {
        case UnitItem:
            
            break;
            
        case UnitML:
            [self.priceField setText:@"(ml)"];
            
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
            
        default:
            break;
    }
}

@end
