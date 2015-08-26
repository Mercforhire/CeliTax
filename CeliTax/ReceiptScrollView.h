//
//  ReceiptScrollView.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookAndFeel.h"

@interface ReceiptScrollView : UIView

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSMutableDictionary *selectedImageIndices;

@property (nonatomic, strong) LookAndFeel *lookAndFeel;

@property (nonatomic) UIEdgeInsets insets;

@end
