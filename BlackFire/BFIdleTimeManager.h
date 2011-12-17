//
//  BFIdleTimeManager.h
//  BlackFire
//
//  Created by Mark Douma on 1/31/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>

@interface BFIdleTimeManager : NSObject 
{
	NSTimer				*timer;
	CGEventSourceRef	eventSourceRef;
    id					_delegate;
	
	BOOL              isIdle;
	BOOL              setAwayStatusAutomatically;

}
+ (BFIdleTimeManager *)defaultManager;
- (void)setSetAwayStatusAutomatically:(BOOL)shouldSetAutomatically;
- (void)setDelegate:(id)delegate;
- (id)delegate;

@end
