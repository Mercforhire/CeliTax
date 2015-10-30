//
//  NoItemsTableViewCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "NoItemsTableViewCell.h"

@implementation NoItemsTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.label setText:NSLocalizedString(@"No receipt", nil)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
