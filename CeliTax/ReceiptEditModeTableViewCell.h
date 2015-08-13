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
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (nonatomic) BOOL addPhotoButtonShouldBeVisible;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBar; // -15 normal state
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBar; // -15 normal state

@end
