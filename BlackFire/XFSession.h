//
//  XFSession.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *XFFriendDidChangeNotification;
extern NSString *XFFriendChangeAttribute;

typedef enum
{
	XFLoginErrorVersionTooOld = 0,
	XFLoginErrorInvalidPassword,
	XFLoginErrorNetworkError
} XFLoginError;

typedef enum
{
	XFConnectionErrorOtherSession = 0,
	XFConnectionErrorHungUp,
	XFConnectionErrorStoppedResponding,
	XFConnectionErrorNormalDisconnect
} XFConnectionError;

typedef enum
{
	XFShowMyFriendsOption = 0,
	XFShowMyGameServerDataOption,
	XFShowOnMyProfileOption,
	XFShowChatTimeStampsOption,
	XFShowFriendsOfFriendsOption,
	XFShowMyOfflineFriendsOption,
	XFShowNicknamesOption,
	XFShowVoiceChatServerOption,
	XFShowWhenITypeOption
} XFPreferences;

typedef enum
{
	XFFriendNotificationOnlineStatusChanged = 0,
	XFFriendNotificationStatusChanged,
	XFFriendNotificationGameStatusChanged,
	XFFriendNotificationSessionChanged,
	XFFriendNotificationJoinedGameServer,
	XFFriendNotificationLeftGameServer,
	XFFriendNotificationFriendAdded,
	XFFriendNotificationFriendRemoved,
	XFFriendNotificationFriendWillComeOnline,
	XFFriendNotificationFriendWillGoOffline
} XFFriendNotification;

typedef enum{
	XFSessionStatusOffline			= 0,
	XFSessionStatusConnecting,
	XFSessionStatusWaiting,
	XFSessionStatusOnline,
	XFSessionStatusDisconnecting
} XFSessionStatus;

@class XFConnection, XFFriend, XFGroup, XFSession, XFGroupController, XFChat;

@protocol XFSessionDelegate <NSObject>
- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason;
- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus;

- (void)session:(XFSession *)session nicknameChanged:(NSString *)newNickname;
- (void)session:(XFSession *)session userStatusChanged:(NSString *)newStatus;

- (void)session:(XFSession *)session receivedAvatarInformation:(unsigned int)userID getValue:(unsigned int)getValue type:(unsigned int)type;

- (void)session:(XFSession *)session chatDidStart:(XFChat *)chat;
- (void)session:(XFSession *)session chatDidEnd:(XFChat *)chat;

- (void)session:(XFSession *)session didReceiveFriendShipRequests:(NSArray *)requests;
- (void)session:(XFSession *)session didReceiveSearchResults:(NSArray *)results;

- (void)session:(XFSession *)session friendChanged:(XFFriend *)changedFriend type:(XFFriendNotification)notificationType;

- (void)session:(XFSession *)session willDisconnectWithReason:(XFConnectionError)reason;

- (NSString *)username;
- (NSString *)password;
@end

@interface XFSession : NSObject

@property (readonly) XFConnection *tcpConnection;
@property (nonatomic, strong) XFFriend *loginIdentity;
@property (nonatomic, unsafe_unretained) id <XFSessionDelegate> delegate;
@property (nonatomic, strong) XFGroupController *groupController;
@property (nonatomic, strong) NSMutableArray *serverList;

@property (readonly) XFSessionStatus status;

- (id)initWithDelegate:(id<XFSessionDelegate>)delegate;

- (void)setStatus:(XFSessionStatus)newStatus;

//--------------------------------------------------------------------------------
// Connecting to xfire
- (void)connect;
- (void)disconnect;
- (void)sendKeepAlive:(NSTimer *)timer;

//--------------------------------------------------------------------------------
// Handling messages from the connection

- (void)loginFailed:(XFLoginError)reason;
- (void)connection:(XFConnection *)connection willDisconnect:(XFConnectionError)connectionError;

//--------------------------------------------------------------------------------
// Managing friends

- (void)raiseFriendNotification:(XFFriendNotification)notification forFriend:(XFFriend *)fr;

- (XFFriend *)friendForUserID:(unsigned int)userID;
- (XFFriend *)friendForUsername:(NSString *)username;
- (XFFriend *)friendForSessionID:(NSData *)sessionID;


/*
 * Don't be confused by the naming of these methods: they do not send an invitation nor
 * send a remove of a friend, these methods are usedto remove friends from these arrays
 * and can be used in several situations
 * Note: they automatically find out to which array the XFFriend object belongs
 */
- (void)addFriend:(XFFriend *)newFriend;
- (void)removeFriend:(XFFriend *)oldFriend;

/*
 * Now these methods actually handle friends deletion
 */
- (void)friendWasDeleted:(unsigned int)userID;

//--------------------------------------------------------------------------------
// Managing chats

- (XFChat *)chatForSessionID:(NSData *)sessionID;

/*
 * Created a new XFChat object for the given friend. Either called
 * by the delegate or the XFConnection ( incoming chats ).
 */
- (XFChat *)beginNewChatForFriend:(XFFriend *)remoteFriend;
- (void)closeChat:(XFChat *)chat;



//--------------------------------------------------------------------------------
// Handling some misc socket responses

/*
 * This method is called by the XFConnection whenever we receive a packet
 * containing 1 or more friend requests. The XFSession delegate will be the
 * only object actually using this data for something.
 */
- (void)receivedFriendShipRequests:(NSArray *)requests;

/*
 * This method is called by the XFConnection whenever search results are
 * returned by the server. This includes empty arrays so we can notify
 * the user whenever the search query did not return any results ( rather than
 * showing infinite progress ).
 */
- (void)receivedSearchResults:(NSArray *)results;

- (void)receivedFriendInformation:(unsigned int)userID getValue:(unsigned int)value type:(unsigned int)type;


//--------------------------------------------------------------------------------
// User options

//- (BOOL)shouldShowFriendsOfFriends;
//- (BOOL)shouldShowOfflineFriends;

//--------------------------------------------------------------------------------
// User session

- (void)updateUserSettings;
- (void)acceptFriendRequest:(XFFriend *)fr;
- (void)declineFriendRequest:(XFFriend *)fr;
- (void)sendFriendRequest:(NSString *)username message:(NSString *)message;

- (void)enterGame:(unsigned int)gameID IP:(unsigned int)IPAddress port:(unsigned short)port;
- (void)exitGame;
- (void)setStatusString:(NSString *)text;
- (void)setNickname:(NSString *)text;
- (void)beginUserSearch:(NSString *)searchString;

- (void)sendRemoveFriend:(XFFriend *)remoteFriend;

- (void)requestFriendInformation:(XFFriend *)remoteFriend;

@end
