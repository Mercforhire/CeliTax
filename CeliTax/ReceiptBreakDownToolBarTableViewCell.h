//
//  ReceiptBreakDownToolBarTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolidGreenButton.h"

@interface ReceiptBreakDownToolBarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SolidGreenButton *transferButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *deleteButton;

@end
