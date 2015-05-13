//
//  AccountTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

//table cell height: 70

@interface AccountTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *catagoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageCostLabel;

@end
