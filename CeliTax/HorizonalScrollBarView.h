//
//  HorizonalScrollBarView.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookAndFeel.h"

@protocol HorizonalScrollBarViewProtocol <NSObject>

@optional

- (void) buttonUnselected;

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name;

- (void) buttonLongPressedWithIndex:(NSInteger)index andName:(NSString *)name atPoint:(CGPoint)point;

@end

@interface HorizonalScrollBarView : UIView

-(void)setButtonNames:(NSArray *)buttonNames andColors:(NSArray *)buttonColors;

-(void)deselectAnyCategory;

-(void)simulateLongPressedOnFirstButton;

-(void)simulateNormalPressOnButton: (NSInteger) index;

@property (nonatomic, strong) LookAndFeel *lookAndFeel;

@property (nonatomic, weak) id <HorizonalScrollBarViewProtocol> delegate;

@property BOOL unselectable;

@end
