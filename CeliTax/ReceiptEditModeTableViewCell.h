//
//  ReceiptEditModeTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-21.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptEditModeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *receiptImageView;
@property (nonatomic) BOOL addPhotoButtonShouldBeVisible;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBar; // -10 normal state
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBar; // -10 normal state

@end
