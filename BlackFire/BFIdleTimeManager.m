//
//  BFIdleTimeManager.m
//  BlackFire
//
//  Created by Mark Douma on 1/31/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "BFIdleTimeManager.h"
#import "BFDefaults.h"

static BFIdleTimeManager *sharedManager = nil;



@implementation BFIdleTimeManager


+ (BFIdleTimeManager *)defaultManager {
	if (sharedManager == nil) {
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (id)init {
	if( (self = [super init]) ) {
		setAwayStatusAutomatically = [[NSUserDefaults standardUserDefaults] boolForKey:BFAutomaticlyGoAFK];
		timer = nil;
		eventSourceRef = NULL;
		isIdle = NO;
		
		if (setAwayStatusAutomatically) {
			if (eventSourceRef == NULL) {
				eventSourceRef = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
			}
      unsigned short time = [[[NSUserDefaults standardUserDefaults] objectForKey:BFAutoAFKTime] intValue];
      //time = (time * 60.0);
			timer = [NSTimer scheduledTimerWithTimeInterval:time
													 target:self
												   selector:@selector(checkIdleState:)
												   userInfo:nil
													repeats:NO];
		}
	}
	return self;
}


- (void)dealloc {
	[timer invalidate];
	timer = nil;
	if (eventSourceRef != NULL) {
		CFRelease(eventSourceRef);
	}
	[super dealloc];
}

- (void)setDelegate:(id)delegate
{
  _delegate = delegate;
}

- (id)delegate
{ return _delegate; }


- (void)checkIdleState:(NSTimer *)aTimer {
	unsigned short time = [[[NSUserDefaults standardUserDefaults] objectForKey:BFAutoAFKTime] intValue];
  //time = (time * 60.0);
	NSTimeInterval seconds = (NSTimeInterval)CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType);
	
	
	if (isIdle) 
  {
		if (seconds <= time) {
			[timer invalidate];
			timer = nil;
			isIdle = NO;
		/*	[[NSNotificationCenter defaultCenter] postNotificationName:BFUserDidBecomeActiveNotification
																object:nil
															  userInfo:nil];*/
			
			timer = [NSTimer scheduledTimerWithTimeInterval:2.0
													 target:self
												   selector:@selector(checkIdleState:)
												   userInfo:nil
													repeats:NO];
		} else {
			
		}
		
		
	} else {
		if (seconds >= time) {
			isIdle = YES;
			/*[[NSNotificationCenter defaultCenter] postNotificationName:BFUserDidBecomeIdleNotification 
																object:nil
															  userInfo:nil];*/
			
			// previous non-repeating timer is invalidated automatically
			timer = [NSTimer scheduledTimerWithTimeInterval:2.0
													 target:self
												   selector:@selector(checkIdleState:)
												   userInfo:nil
													repeats:YES];
		} else {
			NSTimeInterval difference = (time - seconds);
			
//			NSLog(@"[%@ %@] difference == %f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), difference);
			
			timer = [NSTimer scheduledTimerWithTimeInterval:difference
													 target:self
												   selector:@selector(checkIdleState:)
												   userInfo:nil
													repeats:NO];
			
		}
		
	}
	
	
}




- (void)setSetAwayStatusAutomatically:(BOOL)shouldSetAutomatically {
	if (shouldSetAutomatically) {
		setAwayStatusAutomatically = YES;
		if (eventSourceRef == NULL) {
			eventSourceRef = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
		}
    unsigned short time = [[[NSUserDefaults standardUserDefaults] objectForKey:BFAutoAFKTime] intValue];
   // time = (time * 60.0);
		timer = [NSTimer scheduledTimerWithTimeInterval:time
												 target:self
											   selector:@selector(checkIdleState:)
											   userInfo:nil
												repeats:NO];
		isIdle = NO;
	} else {
		setAwayStatusAutomatically = NO;
		[timer invalidate];
		timer = nil;
		if (eventSourceRef != NULL) {
			CFRelease(eventSourceRef);
			eventSourceRef = NULL;
		}
	}
}


@end








