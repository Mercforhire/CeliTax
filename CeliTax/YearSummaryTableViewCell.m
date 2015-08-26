//
//  YearSummaryTableViewCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "YearSummaryTableViewCell.h"

@interface YearSummaryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *totalSpentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAvgCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *gfSavingsLabel;

@end

@implementation YearSummaryTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.exclaimationButton.layer.cornerRadius = self.exclaimationButton.frame.size.height / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showLabels
{
    [self.totalSpentLabel setHidden:NO];
    [self.totalAvgCostLabel setHidden:NO];
    [self.gfSavingsLabel setHidden:NO];
}

-(void)hideLabels
{
    [self.totalSpentLabel setHidden:YES];
    [self.totalAvgCostLabel setHidden:YES];
    [self.gfSavingsLabel setHidden:YES];
}

@end
