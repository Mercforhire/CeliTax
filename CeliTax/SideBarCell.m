//
//  SideBarCell.m
//  Crave
//
//  Created by Leon Chen on 2/27/2014.
//  Copyright (c) 2014 CraveNSave. All rights reserved.
//

#import "SideBarCell.h"

@implementation SideBarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.mainColor = [UIColor whiteColor];
        self.darkColor = [UIColor grayColor];
        
        [self setBackgroundColor:self.mainColor];
        self.contentView.backgroundColor = self.darkColor;
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 13, 20, 20)];
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 12, 132, 21)];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
