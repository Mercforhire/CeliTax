//
//  CatagoryTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

//table cell height: 45

@interface CatagoryTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *catagoryColor;
@property (weak, nonatomic) IBOutlet UIView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *catagoryName;

-(void)makeCellAppearInactive;

-(void)makeCellAppearActive;

@end
