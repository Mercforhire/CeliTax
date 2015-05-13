//
//  CatagoryTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

//table cell height: 70

@interface CatagoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *catagoryName;

@end
