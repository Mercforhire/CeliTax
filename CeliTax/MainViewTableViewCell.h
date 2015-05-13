//
//  MainViewTableViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieView.h"

//table cell height: 70

@interface MainViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PieView *colorBox;
@property (weak, nonatomic) IBOutlet UILabel *timeUploadedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalRecordedLabel;

@end
