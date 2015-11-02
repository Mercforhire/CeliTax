//
//  ReceiptItemCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CeliTax-Swift.h"

@interface ReceiptItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UITextField *qtyField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *totalField;

-(void)setUnitTypeTo:(UnitTypes)unitType;

@end
