//
//  Triangle.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-07.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LookAndFeel;

@interface Triangle : UIView

@property (weak, nonatomic) LookAndFeel *lookAndFeel;

@property (nonatomic) BOOL pointsUp;

@end
