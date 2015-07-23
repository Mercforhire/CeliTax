//
//  ModifyCatagoryTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-10.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolidGreenButton.h"

//table cell height: 62

@interface ModifyCatagoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SolidGreenButton *editButton;

@property (weak, nonatomic) IBOutlet SolidGreenButton *transferButton;

@property (weak, nonatomic) IBOutlet SolidGreenButton *deleteButton;

@end
