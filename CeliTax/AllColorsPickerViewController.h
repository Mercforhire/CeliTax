//
//  AllColorsPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol AllColorsPickerViewPopUpDelegate <NSObject>

@required

-(void)selectedColor:(UIColor *)color;

-(void)doneButtonPressed;

@end

@interface AllColorsPickerViewController : BaseViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <AllColorsPickerViewPopUpDelegate> delegate;

@end
