//
//  WhiteBorderView.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-19.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhiteBorderView : UIView

@property (nonatomic) float borderThickness;
@property (nonatomic) float margin;

@property (nonatomic) BOOL topBorder;
@property (nonatomic) BOOL bottomBorder;
@property (nonatomic) BOOL leftBorder;
@property (nonatomic) BOOL rightBorder;

@end
