//
// NamesPickerViewController.h
// CeliTax
//
// Created by Leon Chen on 2015-05-12.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionsPickerPopUpDelegate <NSObject>

@required

- (void) selectedSelectionAtIndex: (NSInteger) index;

@end

@interface SelectionsPickerViewController : UIViewController

@property CGSize viewSize;

@property (nonatomic, strong) NSArray *names;

@property (nonatomic, weak) id <SelectionsPickerPopUpDelegate> delegate;

@end