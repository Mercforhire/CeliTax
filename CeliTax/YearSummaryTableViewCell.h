//
//  YearSummaryTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-08-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearSummaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *catagoryNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *totalSpentField;
@property (weak, nonatomic) IBOutlet UITextField *totalAvgCostField;
@property (weak, nonatomic) IBOutlet UITextField *gfSavingsField;
@property (weak, nonatomic) IBOutlet UIButton *exclaimationButton;

-(void)showLabels;

-(void)hideLabels;

@end
