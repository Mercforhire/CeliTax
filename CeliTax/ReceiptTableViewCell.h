//
//  ReceiptTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

//table height: 35

@interface ReceiptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;


@end
