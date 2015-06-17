//
// NamesPickerViewController.h
// CeliTax
//
// Created by Leon Chen on 2015-05-12.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class SelectionsPickerViewController;

@protocol SelectionsPickerPopUpDelegate <NSObject>

@required

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController;

@end

@interface SelectionsPickerViewController : BaseViewController

@property (nonatomic, strong) NSArray *selections;

@property (nonatomic) NSInteger highlightedSelectionIndex;

@property (nonatomic, weak) id <SelectionsPickerPopUpDelegate> delegate;

@end