//
//  MenuSelectionTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *selectionIndicator;
@property (weak, nonatomic) IBOutlet UILabel *selectionName;

@end
