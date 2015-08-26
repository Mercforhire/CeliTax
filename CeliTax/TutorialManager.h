//
//  TutorialManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewControllerFactory, LookAndFeel, TutorialStep;

@protocol TutorialManagerDelegate <NSObject>

- (void) tutorialLeftSideButtonPressed;

- (void) tutorialRightSideButtonPressed;

@end

@interface TutorialManager : NSObject

typedef void (^TutorialDismissedBlock) ();

@property (nonatomic, weak) id<TutorialManagerDelegate> delegate;

- (instancetype) initWithViewControllerFactory: (ViewControllerFactory *)factory
                                andLookAndFeel: (LookAndFeel *)lookAndFeel;

-(void)displayTutorialInViewController: (UIViewController *) viewController andTutorial:(TutorialStep *)tutorial;

-(void)dismissTutorial:(TutorialDismissedBlock) dismissBlock;

// after all Tutorials has been show, or skip was clicked, call this function
-(void)setTutorialsAsShown;

// unset the Tutorial Shown flag
-(void)setTutorialsAsNotShown;

// returns True if tutorials have been shown, false otherwise
-(BOOL)hasTutorialBeenShown;

// before we push a new view to continue the tutorial, we want to set this,
// so when the next view is pushed, it will know to automatically start its tutorial
-(void)setAutomaticallyShowTutorialNextTime;

-(BOOL)automaticallyShowTutorialNextTime;

@end
