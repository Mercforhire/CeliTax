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
    
//    [self.quantityLabel setHidden:YES];
    [self.quantityField setHidden:YES];
    [self.pricePerItemLabel setHidden:YES];
    [self.pricePerItemField setHidden:YES];
    [self.dollarSignLabel setHidden:YES];
}

-(void)makeCellAppearActive
{
    [self.colorBoxView setBackgroundColor:self.catagoryColor];
    [self.catagoryName setTextColor:[UIColor blackColor]];
    
//    [self.quantityLabel setHidden:NO];
    [self.quantityField setHidden:NO];
    [self.pricePerItemLabel setHidden:NO];
    [self.pricePerItemField setHidden:NO];
    [self.dollarSignLabel setHidden:NO];
}

-(void)setToDisplayItem
{
    [self.quantityLabel setText:@"Qty"];
    
    [self.pricePerItemLabel setText:@"Price per Item"];
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
        case UnitKG:
            [self.quantityLabel setText:[NSString stringWithFormat:@"Weight-%@", unitSuffix]];
            break;
            
        default:
            break;
    }
    
    [self.pricePerItemLabel setText:@"Total Price"];
}

@end