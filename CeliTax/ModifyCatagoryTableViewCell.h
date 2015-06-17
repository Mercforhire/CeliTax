//
//  ModifyCatagoryTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-10.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

//table cell height: 62

@interface ModifyCatagoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UIButton *transferButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
