//
//  LeftSideMenuView.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-28.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftSideMenuViewProtocol <NSObject>

- (void)selectedMenuIndex:(NSInteger)index;

@end

@interface LeftSideMenuView : UIView

@property (nonatomic, weak) id <LeftSideMenuViewProtocol> delegate;

@property (nonatomic, strong) UIImage *profileImage;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSArray *menuSelections; //of NSString

@property (nonatomic) NSInteger currentlySelectedIndex; //-1 if none

@end
