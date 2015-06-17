//
//  MainViewTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *selectedColorBoxColor;
@property (weak, nonatomic) IBOutlet UIView *colorBoxView;
@property (weak, nonatomic) IBOutlet UILabel *calenderDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeOfDayLabel;

@end
