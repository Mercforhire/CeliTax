//
// LeftSideMenuView.h
// CeliTax
//
// Created by Leon Chen on 2015-05-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookAndFeel.h"

@protocol SideMenuViewProtocol <NSObject>

- (void) selectedMenuIndex: (NSInteger) index;

@end

@interface SideMenuView : UIView

@property (nonatomic, strong) LookAndFeel *lookAndFeel;

@property (nonatomic, weak) id <SideMenuViewProtocol> delegate;

@property (nonatomic, strong) UIImage *profileImage;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic) NSInteger currentlySelectedIndex; // -1 if none

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@end