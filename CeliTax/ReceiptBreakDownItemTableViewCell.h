//
//  ReceiptBreakDownItemTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-31.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptBreakDownItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorBoxView;
@property (weak, nonatomic) IBOutlet UILabel *catagoryName;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemField;


@end
