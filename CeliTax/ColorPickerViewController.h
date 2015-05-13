//
//  ColorPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-11.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerViewPopUpDelegate <NSObject>

-(void)selectedColor:(UIColor *)color;

-(void)customColorPressed;

@end

@interface ColorPickerViewController : UIViewController

@property (nonatomic, weak) id <ColorPickerViewPopUpDelegate> delegate;

@end
