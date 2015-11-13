//
//  TutorialBubbleUp.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LookAndFeel;

typedef NS_ENUM(NSUInteger, ArrowDirection) {
    ArrowDirectionNone,
    ArrowDirectionUp,
    ArrowDirectionDown,
};

@interface TutorialBubble : UIView

@property (weak, nonatomic) LookAndFeel *lookAndFeel;

@property (nonatomic) CGPoint originOfArrow;

@property (nonatomic, strong) NSString *tutorialText;

@property (nonatomic) NSUInteger arrowDirection;

@property (nonatomic, strong) NSString *leftButtonTitle;

@property (nonatomic, strong) NSString *rightButtonTitle;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

//Run this once after all properties have been set
-(void)setupUI;

@end
