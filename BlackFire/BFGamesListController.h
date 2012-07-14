//
//  BFGamesListController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/15/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "BFTabViewController.h"

@class BFStringPromptController, BFGamesGroup;

@interface BFGamesListController : BFTabViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (unsafe_unretained) IBOutlet NSOutlineView *tableView;

- (void)reloadMacGames;
- (void)reloadData;
- (void)expandItem;

- (IBAction)doubleClicked:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (NSUInteger)selectedGameID;

@end

@interface NSDictionary (Utilities)
- (NSComparisonResult)compareMacGame:(id)game;
- (NSComparisonResult)compareXfireGame:(id)game;
@end

@interface NSNumber (Utilities)
- (NSComparisonResult)compareMacGame:(id)game;
- (NSComparisonResult)compareXfireGame:(id)game;
@end
