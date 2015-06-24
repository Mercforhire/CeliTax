//
// LookAndFeel.h
// CeliTax
//
// Created by Leon Chen on 2015-06-09.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIFont+Lato.h"

@interface LookAndFeel : NSObject

- (UIColor *) appGreenColor;

- (void) addLeftInsetToTextField: (UITextField *) textField;

- (void) applyGrayBorderTo: (UIView *) view;

- (void) applyGreenBorderTo: (UIView *) view;

- (void) applyHollowGreenButtonStyleTo: (UIButton *) button;

- (void) applySolidGreenButtonStyleTo: (UIButton *) button;

- (void) applyDisabledButtonStyleTo: (UIButton *) button;

@end