//
//  SyncManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncManager : NSObject

/**
 Designated intializer
 
 @param delegate Notified of the sync progress
 @param auctionService Used to download auction locations
 @param assignmentService Used to download assignments
 @param definitionService Used to download definitions
 */
//- (id) initWithDelegate: (id<SyncManagerDelegate>) delegate
//         auctionService: (id<OLAuctionService>) auctionService
//      assignmentService: (id<OLAssignmentService>) assignmentService
//      definitionService: (id<OLDefinitionService>) definitionService;

/**
 Runs the entire sync process (checking/upload data/upload)
 */
//- (void) sync;

/**
 Cancels the sync process
 */
//- (void) cancel;

@end
