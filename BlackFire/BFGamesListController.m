//
//  BFServerListController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 7/22/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "BFGamesListController.h"
#import "BFGamesManager.h"
#import "BFGamesGroup.h"
#import "BFImageAndTextCell.h"


@implementation BFGamesListController

@synthesize tableView;

- (id)init
{
  if( (self = [super init]) )
  {
      [NSBundle loadNibNamed:@"GamesList" owner:self];
      
      NSTableColumn *col = [tableView tableColumnWithIdentifier:@"column1"];
      BFImageAndTextCell *cell = [[BFImageAndTextCell alloc] init];
      [cell setEditable:NO];
      [cell setDisplayImageSize:NSMakeSize(18.0f,18.0f)];
      [col  setDataCell:cell];
      [cell release];
      
      [tableView setDoubleAction:@selector(doubleClicked:)];
      [tableView setTarget:self];
      
      undetectedGamesGroup = [[BFGamesGroup alloc] init];
      undetectedGamesGroup.name = @"Undetected games";
	  NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[[[BFGamesManager sharedGamesManager] xfireGames] allValues]];
	  [arr sortUsingSelector:@selector(compareXfireGame:)];
	  undetectedGamesGroup.members = arr;
	  [arr release];
	  
      detectedGamesGroup = [[BFGamesGroup alloc] init];
      detectedGamesGroup.members = [[[NSMutableArray alloc] init] autorelease];
      detectedGamesGroup.name = @"Detected games";
      
      NSMutableArray *knownID = [[NSMutableArray alloc] init];
      NSMutableDictionary *macGames = [[BFGamesManager sharedGamesManager] macGames];
	  NSArray *macG = [macGames allValues];
      for(NSDictionary *macGame in macG)
      {
          if( [macGame isKindOfClass:[NSDictionary class]] )
          {
              NSString *appName = [macGame objectForKey:@"AppName"];
              if( appName && [appName length] > 0 )
              {
                  if( [[[NSWorkspace sharedWorkspace] fullPathForApplication:appName] length] > 1 )
                  {
                      BOOL found = NO;
                      for(NSString *name in knownID)
                      {
                          if( [name isEqualToString:appName] )
                          {
                              found = YES;
                          }
                      }
                      if( ! found )
                      {
                          [knownID addObject:appName];
                          [detectedGamesGroup.members addObject:macGame];
                      }
                  }
              }
          }
      }
      [knownID release];
  }
  return self;
}


- (void)dealloc
{
    [detectedGamesGroup release];
    detectedGamesGroup = nil;
    [undetectedGamesGroup release];
    undetectedGamesGroup = nil;
    [super dealloc];
}

- (void)reloadData
{
	[tableView reloadData];
}

- (void)expandItem
{
    [tableView expandItem:detectedGamesGroup];
}

/*
 * Launches the current selected game
 */
- (IBAction)doubleClicked:(id)sender
{    
    NSInteger row = [tableView selectedRow];
    id item = [tableView itemAtRow:row];
    if( [item isKindOfClass:[NSDictionary class]] )
    {
        NSString *appName = [item objectForKey:@"AppName"];
        if( [appName length] > 0 )
        {
            [[NSWorkspace sharedWorkspace] launchApplication:appName];
        }
    }
}

- (IBAction)removeSelected:(id)sender
{
    NSLog(@"-removeSelected is not implemented anymore");
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if( item == undetectedGamesGroup || item == detectedGamesGroup )
    {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if( [item isKindOfClass:[BFGamesGroup class]] )
    {
        BFGamesGroup *real = item;
        return real.name;
    }
    else if( [item isKindOfClass:[NSDictionary class]] )
    {
        NSString *name = [item objectForKey:@"LongName"];
        if( ! name )
        {
            unsigned int gameID = [[item objectForKey:@"gameID"] intValue];
            if( gameID != 0 )
            {
                // mac game
				name = [[BFGamesManager sharedGamesManager] longNameForGameID:gameID];
               // name = [[[BFGamesManager sharedManager] gameInfo:gameID] objectForKey:@"LongName"];
            }
        }
        return name;
    }
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    if( item == detectedGamesGroup || item == undetectedGamesGroup )
    {
        return 18.0f;
    }
    return 24.0f;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if( item == detectedGamesGroup )
    {
        return YES;
    }
    else if( item == undetectedGamesGroup )
    {
        return YES;
    }
    return NO;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    BFImageAndTextCell *newcell = (BFImageAndTextCell*)cell;
    [newcell setShowsStatus:NO];
    
    if( item == detectedGamesGroup || item == undetectedGamesGroup )
    {
        [newcell setImage:nil];
		[newcell setStatusImage:nil];
		[newcell setGroupRow:true];
    }
    else
    {
        if( [item isKindOfClass:[NSDictionary class]] )
        {
            unsigned int gameID = [[item objectForKey:@"ID"] intValue];
            if( gameID == 0 )
            {
                gameID = [[item objectForKey:@"gameID"] intValue];
            }
            if( gameID == 0 )
            {
                [newcell setImage:nil];
            }
			NSImage *img = [[BFGamesManager sharedGamesManager] imageForGame:gameID];
            [newcell setImage:img];
			[(BFImageAndTextCell *)cell setGroupRow:false];
        }
        else
        {
            [newcell setImage:nil];
			[newcell setStatusImage:nil];
			[(BFImageAndTextCell *)cell setGroupRow:false];
        }
        
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if( ! item )
    {
        if( index == 0 )
            return detectedGamesGroup;
        else if( index == 1 )
            return undetectedGamesGroup;
    }
    else if( item == detectedGamesGroup )
    {
        return [detectedGamesGroup.members objectAtIndex:index];
    }
    else if( item == undetectedGamesGroup )
    {
        return [undetectedGamesGroup.members objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if( ! item )
    {
        return 2; // 
    }
    else if( item == undetectedGamesGroup )
    {
        return [undetectedGamesGroup.members count];
    }
    else if( item == detectedGamesGroup )
    {
        return [detectedGamesGroup.members count];
    }
    return 0;
}

@end

@implementation NSDictionary (Utilities)

- (NSComparisonResult)compareMacGame:(id)game
{
    if( [game isKindOfClass:[NSDictionary class]]  )
    {
        return [[self objectForKey:@"AppName"] caseInsensitiveCompare:[game objectForKey:@"AppName"]];
    }
    
	return NSOrderedSame;
}

- (NSComparisonResult)compareXfireGame:(id)game
{
    if( game && [game isKindOfClass:[NSDictionary class]] )
    {
        return [[self objectForKey:@"LongName"] caseInsensitiveCompare:[game objectForKey:@"LongName"]];
    }
    return NSOrderedSame;
}
@end

@implementation NSNumber (Utilities)
- (NSComparisonResult)compareXfireGame:(id)game
{
	return NSOrderedDescending;
}

- (NSComparisonResult)compareMacGame:(id)game
{
	return NSOrderedDescending;
}
@end
