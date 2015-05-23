//
//  NamesPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NamesPickerPopUpDelegate <NSObject>

@required

-(void)selectedName:(NSString *)name;

@end

@interface NamesPickerViewController : UIViewController

@property CGSize viewSize;

@property (nonatomic, strong) NSArray *names;

@property (nonatomic, weak) id <NamesPickerPopUpDelegate> delegate;

@end
