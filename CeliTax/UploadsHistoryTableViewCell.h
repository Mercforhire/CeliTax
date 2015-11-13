//
// UploadsHistoryTableViewCell.h
// CeliTax
//
// Created by Leon Chen on 2015-06-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TriangleView.h"

@class LookAndFeel;

@interface UploadsHistoryTableViewCell : UITableViewCell

@property (nonatomic, weak) LookAndFeel *lookAndFeel;

@property (strong, nonatomic) UIColor *catagoryColor;

@property (weak, nonatomic) IBOutlet UILabel *recentUploadsLabel;
@property (weak, nonatomic) IBOutlet TriangleView *recentUploadsTriangle;

@property (weak, nonatomic) IBOutlet UILabel *previousWeekLabel;
@property (weak, nonatomic) IBOutlet TriangleView *previousWeekTriangle;

@property (weak, nonatomic) IBOutlet UILabel *previousMonthLabel;
@property (weak, nonatomic) IBOutlet TriangleView *previousMonthTriangle;

@property (weak, nonatomic) IBOutlet UILabel *viewAllLabel;
@property (weak, nonatomic) IBOutlet TriangleView *viewAllTriangle;

@property (nonatomic, strong) NSArray *recentUploadReceipts;
@property (nonatomic, strong) NSArray *previousWeekReceipts;
@property (nonatomic, strong) NSArray *previousMonthReceipts;
@property (nonatomic, strong) NSArray *viewAllReceipts;

- (void) setToDisplayItems;

- (void) setToDisplayWeight;

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