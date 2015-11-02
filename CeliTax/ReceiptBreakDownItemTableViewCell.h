//
//  ReceiptBreakDownItemTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-31.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CeliTax-Swift.h"

@interface ReceiptBreakDownItemTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *catagoryColor;
@property (weak, nonatomic) IBOutlet UIView *colorBoxView;
@property (weak, nonatomic) IBOutlet UILabel *catagoryName;

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;

@property (weak, nonatomic) IBOutlet UILabel *pricePerItemLabel;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemField;
@property (weak, nonatomic) IBOutlet UILabel *dollarSignLabel;

-(void)makeCellAppearInactive;

-(void)makeCellAppearActive;

-(void)showLabels;

-(void)hideLabels;

-(void)setToDisplayItem;

-(void)setToDisplayUnit:(UnitTypes)unitType;

@end
