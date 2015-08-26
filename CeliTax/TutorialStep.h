//
//  TutorialStep.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialStep : NSObject

@property (nonatomic) CGRect highlightedItemRect;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *leftButtonTitle;

@property (nonatomic, strong) NSString *rightButtonTitle;

@property (nonatomic) BOOL pointsUp;

@end
