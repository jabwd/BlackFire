//
//  BFServerListController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 7/22/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "BFTabViewController.h"
#import "TaskWrapper.h"

@class XFSession;

@interface BFServerListController : BFTabViewController  <TaskWrapperController>
{
	NSOutlineView	*serverListView;
	NSArray			*serverList;
	
	TaskWrapper *task;
	unsigned int idx;
	
	NSMutableArray	*taskList;
	NSMutableString *serverInfoOutput;
}

@property (nonatomic, assign) IBOutlet NSOutlineView *serverListView;

- (id)initWithServerList:(NSArray *)newList;

/*
 * Will return a NSDictionary object containing the current selected xfire server.
 * Keys:	GameID,
 *				ServerIP,
 *				ServerPort
 *
 * Return NIL if no server is selected.
 */
- (NSDictionary *)selectedServer;

/*
 * Handy accessor method for getting the current selected row,
 * YES NSTableView has methods for this but this one is what we call *safe*
 */ 
- (int)activeRow;

- (IBAction)clicked:(id)sender;
- (IBAction)doubleClicked:(id)sender;

/*
 * Fetches (async, using TaskWrapper class) the server info for the given IP address (string)
 * Gamename: optional, it will provide qstat with the knowledge of which protocol to use. Default
 * is the q3 protocol which is supported by most games.
 */
- (void)getServerInfoWithIP:(NSString *)ip andGameName:(NSString *)gameName;

- (IBAction)refresh:(id)sender;
- (IBAction)refreshAll:(id)sender;

/*
 * This method should be called to "empty" the task list, after the delegate method of TaskWrapper
 * processFinished is called this method will be called again untill the tasklist is empty.
 * The tasklist will also be emptied once the user clicks on the server list.
 */
- (void)nextTask;
@end