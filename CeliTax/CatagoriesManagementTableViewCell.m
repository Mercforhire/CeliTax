//
//  CatagoriesManagementTableViewCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesManagementTableViewCell.h"

@implementation CatagoriesManagementTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
