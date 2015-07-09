//
//  TutorialStep.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialStep : NSObject

@property (nonatomic) CGPoint origin;

@property (nonatomic) CGSize size;

@property (nonatomic, strong) NSString *text;

@property (nonatomic) BOOL pointsUp;

@end
