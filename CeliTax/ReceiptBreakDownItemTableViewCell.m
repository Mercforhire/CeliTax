//
//  ReceiptBreakDownItemTableViewCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-31.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBreakDownItemTableViewCell.h"

@implementation ReceiptBreakDownItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
