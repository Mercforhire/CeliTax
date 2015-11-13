//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Additions to the UIView class
 */
@interface UIView (Helper)

/**
 Centers self's frame based on the provided view
 
 @param view UIView in which to center self
 */
- (void) centerInView: (UIView *) view;

/**
 Centers self's frame horizontally based on the provided view
 
 @param view UIView in which to center self
 */
- (void) centerHorizontallyInView: (UIView *) view;

/**
 Centers self's frame vertically based on the provided view
 
 @param view UIView in which to center self
 */
- (void) centerVerticallyInView: (UIView *) view;

- (void) scrollToY:(float)y;

- (void) scrollToView:(UIView *)view;

- (void) scrollElement:(UIView *)view toPoint:(float)y;

@end
