//
//  BFChatLog.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/12/11.
//  Copyright 2011 Exurion. All rights reserved.
//

#import "BFChatLog.h"
#import "BFMessage.h"
#import <sqlite3.h>

/*
 *
 ** database layout
 sqlite> create table chats (id INTEGER PRIMARY KEY AUTOINCREMENT,timestamp BIG INT);
 sqlite> create table messages (id INTEGER PRIMARY KEY AUTOINCREMENT,chatID INTEGER,user INTEGER,timestamp BIG INT,message TEXT);

 */

@implementation BFChatLog

@synthesize friendUsername;
@synthesize date;

- (id)init
{
    if( (self = [super init]) )
    {
    }
    return self;
}

- (void)dealloc
{
    [date release];
    date = nil;
    [friendUsername release];
    friendUsername = nil;
    [super dealloc];
}

- (NSString *)getDatabasePath
{
	NSString *path2 = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [[NSString alloc] initWithFormat:@"%@/BlackFire/ChatLogs/%@.xfl",path2,friendUsername];
    return [path autorelease];
}

/*
 * Adds the messages of the array to the database
 */
- (void)addMessages:(NSMutableArray *)array
{
    if( ! array )
        return;
    if( [array count] < 1 )
        return;
    if( ! friendUsername )
        return;
    
    // the messages array is filled like with BFMessage objects
    // or better, it SHOULD be filled with BFMessage objects
    
    NSString *path = [self getDatabasePath];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path] )
    {
		NSString *appSupport = [NSString stringWithFormat:@"%@/BlackFire/ChatLogs",[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]];
		if( ! [[NSFileManager defaultManager] fileExistsAtPath:appSupport isDirectory:nil] )
		{
			NSLog(@"Creating appsupport ChatLogs directory");
			[[NSFileManager defaultManager] createDirectoryAtPath:appSupport withIntermediateDirectories:true attributes:nil error:nil];
		}
        NSLog(@"Creating new chatlog at path: %@",path);
        // create the database from template
        NSError *error = nil;
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"chatLogTemplate" ofType:@"db"];
        if( ! sourcePath )
        {
            NSLog(@"Chatlogtemplate file is missing!!");
            return;
        }
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:path error:&error];
        if( error )
        {
            // something weird happened
            NSLog(@"An error occured while trying to create a chatlog from the chatlog template %@",error);
            return;
        }
    }
    
    sqlite3 *database = nil;
    sqlite3_open([path UTF8String], &database);
    if( database )
    {
        // we have a database, so we insert a new chat racket.
        sqlite3_stmt *statement = nil;
        NSString *query = [[NSString alloc] initWithFormat:@"insert into chats (timestamp) values (@B)"];
        if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
        {
            sqlite3_bind_int64(statement, 1, [date timeIntervalSince1970]);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            statement = nil;
            
            // now get the chat id, we need it in the following qeury
            unsigned int chatID = 0;
            [query release];
            query = [[NSString alloc] initWithFormat:@"select * from chats where timestamp=%lu",(unsigned long)[date timeIntervalSince1970]];
            if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
            {
                if( sqlite3_step(statement) == SQLITE_ROW )
                {
                    chatID = sqlite3_column_int(statement, 0);
                    if( chatID == 0 )
                    {
                        NSLog(@"Unable to fetch chat ID");
                        [query release];
                        sqlite3_finalize(statement);
                        sqlite3_close(database);
                        return;
                    }
                }
                sqlite3_finalize(statement);
            }
            else
            {
                NSLog(@"Unable to fetch chat ID");
                [query release];
                sqlite3_close(database);
                return;
            }
            statement = nil;
            
            
            [query release];
            query = [[NSString alloc] initWithFormat:@"insert into messages (chatID,user,timestamp,message) values (@A,@B,@C,@D);"];
            if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
            {
                // add all the messages in the array to the database
                sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
                
                for(BFMessage *message in array)
                {
                    sqlite3_bind_int(statement, 1, chatID);
                    sqlite3_bind_int(statement, 2, message.user);
                    sqlite3_bind_int64(statement, 3, message.timestamp);
                    sqlite3_bind_text(statement, 4, [message.message UTF8String], -1, SQLITE_TRANSIENT);
                    
                    sqlite3_step(statement);
                    sqlite3_clear_bindings(statement);
                    sqlite3_reset(statement);
                }
                
                sqlite3_exec(database, "END TRANSACTION", NULL, NULL, NULL);
                sqlite3_finalize(statement);
                // done modifying the database here.
            }
        }
        [query release];
    }
    else
    {
        NSLog(@"Unable to save the chatlog, null database");
        return;
    }
    
    // done here, cleanup
    
    sqlite3_close(database);
}

/*
 * Gets a certain amount of messages from the database
 */
- (NSArray *)getLastMessages:(unsigned int)amount
{
    if( amount > 100 )
        amount = 100;
    if( amount == 0 )
        amount = 5;
    
    NSString *path = [self getDatabasePath];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path] )
    {
        NSLog(@"Unable to open database for this chat, the database doesn't exist yet %@",path);
        return nil;
    }
    
    sqlite3 *database = nil;
    sqlite3_open([path UTF8String], &database);
    
    if( ! database )
    {
        NSLog(@"Unable to open database for this chat, it doesn't exist yet.");
        return nil;
    }
    
    sqlite3_stmt *statement = nil;
    
    /*
     * Gets the last 5 messages by ordering by timestamp
     */
    NSString *query = [[NSString alloc] initWithFormat:@"select * from messages order by timestamp desc limit 0,%u",amount];
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while(sqlite3_step(statement)==SQLITE_ROW)
        {
            BFMessage *message = [[BFMessage alloc] init];
            const char *msg = (const char*)sqlite3_column_text(statement, 4);
            if( msg )
                message.message = [NSString stringWithUTF8String:msg];
            message.timestamp = sqlite3_column_int64(statement, 3);
            message.user = sqlite3_column_int(statement, 2);
            [arr addObject:message];
            [message release];
        }
        
		sqlite3_finalize(statement);
        sqlite3_close(database);
        [query release];
        return [arr autorelease];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    [query release];
    return nil;
}

@end
