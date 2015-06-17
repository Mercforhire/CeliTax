//
// LookAndFeel.m
// CeliTax
//
// Created by Leon Chen on 2015-06-09.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LookAndFeel.h"

@implementation LookAndFeel

- (UIColor *) appGreenColor
{
    return [UIColor colorWithRed: 158.0f/255.0f green: 216.0f/255.0f blue: 113.0f/255.0f alpha: 1];
}

- (void) addLeftInsetToTextField: (UITextField *) textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 12, 12)];
    [paddingView setBackgroundColor: [UIColor clearColor]];

    textField.leftViewMode = UITextFieldViewModeAlways;
    [textField setLeftView: paddingView];
}

- (void) applyGrayBorderTo: (UIView *) view
{
    view.layer.cornerRadius = 2.0f;
    view.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    view.layer.borderWidth = 1.0f;
    [view setClipsToBounds: YES];
}

- (void) applyGreenBorderTo: (UIView *) view
{
    view.layer.cornerRadius = 2.0f;
    view.layer.borderColor = [self appGreenColor].CGColor;
    view.layer.borderWidth = 1.0f;
    [view setClipsToBounds: YES];
}

- (void) applyHollowGreenButtonStyleTo: (UIButton *) button
{
    [button setBackgroundColor: [UIColor whiteColor]];
    button.layer.cornerRadius = 3.0f;
    button.layer.borderColor = [self appGreenColor].CGColor;
    button.layer.borderWidth = 1.0f;

    button.layer.shadowColor = [self appGreenColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1.5);
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 0;
    [button setClipsToBounds: NO];

    [button setTitleColor: [self appGreenColor] forState: UIControlStateNormal];
}

- (void) applySolidGreenButtonStyleTo: (UIButton *) button
{
    [button setBackgroundColor: [self appGreenColor]];
    button.layer.cornerRadius = 3.0f;
    [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button setClipsToBounds: YES];
}

@end