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

    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

-(void)makeCellAppearInactive
{
    [self.colorBoxView setBackgroundColor:[UIColor lightGrayColor]];
    [self.catagoryName setTextColor:[UIColor lightGrayColor]];
    
    [self hideLabels];
    [self.quantityField setHidden:YES];
    [self.pricePerItemField setHidden:YES];
}

-(void)makeCellAppearActive
{
    [self.colorBoxView setBackgroundColor:self.catagoryColor];
    [self.catagoryName setTextColor:[UIColor blackColor]];
    
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
    [self.quantityLabel setText:@"Qty."];
    
    [self.pricePerItemLabel setText:@"Price/Item"];
}

-(void)setToDisplayUnit:(NSInteger)unitType
{
    NSString *unitSuffix = @"";
    
    switch (unitType)
    {
        case UnitML:
            unitSuffix = @"(ml)";
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
            
        default:
            break;
    }
    
    switch (unitType)
    {
        case UnitML:
        case UnitL:
            [self.quantityLabel setText:[NSString stringWithFormat:@"Volume-%@", unitSuffix]];
            break;
            
        case UnitG:
        case Unit100G:
        case UnitKG:
            [self.quantityLabel setText:[NSString stringWithFormat:@"Weight-%@", unitSuffix]];
            break;
            
        default:
            break;
    }
    
    [self.pricePerItemLabel setText:@"Total Price"];
}

@end