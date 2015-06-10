//
//  ReceiptTableViewCell.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptTableViewCell.h"

@implementation ReceiptTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
