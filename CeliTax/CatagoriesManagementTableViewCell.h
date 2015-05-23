//
//  CatagoriesManagementTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatagoriesManagementTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;

@end
