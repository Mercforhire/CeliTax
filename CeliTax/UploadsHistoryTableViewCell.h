//
// UploadsHistoryTableViewCell.h
// CeliTax
//
// Created by Leon Chen on 2015-06-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadsHistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *catagoryColor;

@property (weak, nonatomic) IBOutlet UILabel *recentUploadsLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewAllLabel;

@property (nonatomic, strong) NSArray *recentUploadReceipts;
@property (nonatomic, strong) NSArray *previousWeekReceipts;
@property (nonatomic, strong) NSArray *previousMonthReceipts;
@property (nonatomic, strong) NSArray *viewAllReceipts;

// shrink all tables
- (void) selectNothing;

// show Recent Uploads table, hide others
- (void) selectRecentUpload;

// show Previous Week table, hide others
- (void) selectPreviousWeek;

// show Previous Month table, hide others
- (void) selectPreviousMonth;

// show View All table, hide others
- (void) selectViewAll;

@end