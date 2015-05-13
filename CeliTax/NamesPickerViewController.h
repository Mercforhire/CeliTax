//
//  NamesPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NamesPickerPopUpDelegate <NSObject>

-(void)selectedName:(NSString *)name;

@end

@interface NamesPickerViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *names;

@property (nonatomic, weak) id <NamesPickerPopUpDelegate> delegate;

@end
