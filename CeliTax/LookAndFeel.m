//
// LookAndFeel.m
// CeliTax
//
// Created by Leon Chen on 2015-06-09.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "LookAndFeel.h"

@implementation LookAndFeel

- (UIColor *) navBarColor
{
    return [UIColor colorWithRed: 116.0f/255.0f green: 191.0f/255.0f blue: 81.0f/255.0f alpha: 1];
}

- (UIColor *) appGreenColor
{
    return [UIColor colorWithRed: 158.0f/255.0f green: 216.0f/255.0f blue: 113.0f/255.0f alpha: 1];
}

- (void) addLeftInsetToTextField: (UITextField *) textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 12, 12)];
    paddingView.backgroundColor = [UIColor clearColor];

    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = paddingView;
}

- (void) removeBorderFor: (UIView *) view
{
    view.layer.borderWidth = 0;
    [view setClipsToBounds: YES];
}

- (void) applyWhiteBorderTo: (UIView *) view
{
    view.layer.cornerRadius = 2.0f;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 1.0f;
    [view setClipsToBounds: YES];
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


- (UIColor *)darkerColorFrom:(UIColor *)originalColor
{
    CGFloat h, s, b, a;
    
    if ([originalColor getHue:&h saturation:&s brightness:&b alpha:&a])
    {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    }
    
    return nil;
}
- (void) applySlightlyDarkerBorderTo: (UIView *) view
{
    UIColor *viewColor = view.backgroundColor;
    
    view.layer.cornerRadius = 2.0f;
    view.layer.borderColor = [self darkerColorFrom:viewColor].CGColor;
    view.layer.borderWidth = 1.0f;
    [view setClipsToBounds: YES];
}

- (void) applyNormalButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self applyGreenBorderTo:button];
}

- (void) applyHollowGreenButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [UIColor whiteColor];
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

- (void) applyHollowWhiteButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [self appGreenColor];
    button.layer.cornerRadius = 3.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.layer.shadowColor = [UIColor whiteColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1.5);
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 0;
    [button setClipsToBounds: NO];
    
    [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
}

- (void) applySolidGreenButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [self appGreenColor];
    button.layer.cornerRadius = 3.0f;
    [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button setClipsToBounds: YES];
    button.layer.borderWidth = 0;
}

- (void) applyTransperantWhiteTextButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button setClipsToBounds: YES];
}


- (void) applyDisabledButtonStyleTo: (UIButton *) button
{
    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = 3.0f;
    [button setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button setClipsToBounds: YES];
    
    [self applySlightlyDarkerBorderTo:button];
}

@end