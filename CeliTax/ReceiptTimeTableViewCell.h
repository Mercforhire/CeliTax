//
//  ReceiptTimeTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"

@interface ReceiptTimeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet M13Checkbox *checkBoxView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

@end
