//
// TimePeriodSelectionTableViewCell.h
// CeliTax
//
// Created by Leon Chen on 2015-06-08.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TriangleView.h"

@interface TimePeriodSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet TriangleView *triangle;

@end