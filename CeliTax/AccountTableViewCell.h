//
// AccountTableViewCell.h
// CeliTax
//
// Created by Leon Chen on 2015-05-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

// table cell height: 70

@interface AccountTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *colorBoxColor;
@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *catagoryNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *totalQuantityField;
@property (weak, nonatomic) IBOutlet UITextField *totalAmountField;
@property (weak, nonatomic) IBOutlet UITextField *averageNationalPriceField;

@property (weak, nonatomic) IBOutlet UILabel *totalQtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalAmountDollarSign;
@property (weak, nonatomic) IBOutlet UILabel *avgPriceDollarSign;

-(void)makeCellAppearInactive;

-(void)makeCellAppearActive;

@end