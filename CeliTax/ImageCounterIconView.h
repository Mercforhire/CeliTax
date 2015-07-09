//
// ImageCounterIconView.h
// CeliTax
//
// Created by Leon Chen on 2015-05-16.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageCounterIconViewProtocol <NSObject>

- (void) imageCounterIconClicked;

@end

@interface ImageCounterIconView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic) NSInteger counter;

@property (nonatomic, weak) id <ImageCounterIconViewProtocol> delegate;

@end