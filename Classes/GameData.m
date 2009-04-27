//
//  GameData.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "GameData.h"
#import "PlayerObject.h"
#import "LittleDudeObject.h"
#import "SynthesizeSingleton.h"
#include <Foundation/Foundation.h>
#include <mach/mach_time.h>

NSString *GAME_OBJECT_NEW_NOTIFICATION = @"GameObjectNewNotification";
NSString *GAME_OVER_NOTIFICATION = @"GameOverNotification";


NSString *GAME_DATA_ASTEROIDS_CREATED_KEY = @"created";
NSString *GAME_DATA_ASTEROIDS_DESTROYED_KEY = @"destroyed";
NSString *GAME_DATA_LEVEL_KEY = @"level";
NSString *GAME_DATA_LIVES_KEY = @"lives";
NSString *GAME_DATA_NEXT_SHOT_INDEX_KEY = @"nextShot";
NSString *GAME_DATA_PREPARE_TIMER_KEY = @"prepareTimer";
NSString *GAME_DATA_SHOT_COOLDOWN_KEY = @"shotCooldown";
NSString *GAME_DATA_MESSAGE_KEY = @"message";

NSString *GAME_PLAYER_KEY = @"player";
NSString *GAME_SHOT_KEY_BASE = @"shot";
NSString *GAME_ASTEROID_KEY_BASE = @"asteroid";

@implementation GameData

@synthesize shootKeyDown;
@synthesize rightKeyDown;
@synthesize leftKeyDown;
@synthesize upKeyDown;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameData);

//
// init
//
// Init method for the object.
//
- (id)init
{
	self = [super init];
	if (self != nil)
	{
		gameObjects = [[NSMutableDictionary alloc] init];
		gameData = [[NSMutableDictionary alloc] init];
		
		[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_LIVES_KEY];
		[gameData setObject:[NSNumber numberWithInteger:-1] forKey:GAME_DATA_LEVEL_KEY];
		
		srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF));
	}
	return self;
}

//
// gameWidth
//
// Returns the width for the game area. Defaults to screen width.
//
- (double)gameWidth
{
	static double gameWidth = 320;
	
	if (gameWidth == 0)
	{
		CGSize screenSize = [[UIScreen mainScreen] bounds].size;
		if ((screenSize.width / screenSize.height) > GAME_ASPECT)
		{
			screenSize.width = screenSize.height * GAME_ASPECT;
		}
		gameWidth = screenSize.width;
	}
	
	return gameWidth;
}

//
// gameHeight
//
// Returns the height for the game area. Defaults to screen height.
//
- (double)gameHeight
{
	static double gameHeight = 480;
	
	if (gameHeight == 0)
	{
		CGSize screenSize = [[UIScreen mainScreen] bounds].size;
		if ((screenSize.width / screenSize.height) < GAME_ASPECT)
		{
			screenSize.height = screenSize.width / GAME_ASPECT;
		}
		gameHeight = screenSize.height;
	}
	
	return gameHeight;
}

#pragma mark gameObjects accessors

//
// gameObjects
//
// Accessor for the dictionary of game objects
//
- (NSDictionary *)gameObjects
{
	return gameObjects;
}

//
// gameData
//
// Accessor for the dictionary of game data
//
- (NSDictionary *)gameData
{
	return gameData;
}

//
// setGameDataObject:forKey:
//
// Accessor for setting a value in the gameData dictionary.
//
- (void)setGameDataObject:(id)object forKey:(NSString *)key
{
	[gameData setObject:object forKey:key];
}

//
// keyForShotAtIndex:
//
// Convenience accessor for a given shot index.
//
- (NSString *)keyForShotAtIndex:(NSInteger)shotIndex
{
	return [NSString stringWithFormat:@"%@%ld", GAME_SHOT_KEY_BASE, shotIndex];
}

//
// keyForAsteroidAtIndex:
//
// Convenience accessor for a given asteroid index.
//
- (NSString *)keyForAsteroidAtIndex:(NSInteger)asteroidIndex
{
	return [NSString stringWithFormat:@"%@%ld", GAME_ASTEROID_KEY_BASE, asteroidIndex];
}

#pragma mark gameObjects Management

//
// addGameObject:forKey:
//
// The object is added to the gameObjects dictionary
// using the "name" as a key and notification is sent.
//
- (void)addGameObject:(GameObject *)newGameObject forKey:(NSString *)gameObjectKey
{
	[gameObjects setObject:newGameObject forKey:gameObjectKey];
	newGameObject.keyInGameData = gameObjectKey;
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:GAME_OBJECT_NEW_NOTIFICATION object:gameObjectKey];
}

//
// removeGameObjectForKey:
//
// The object is removed from the gameObjects dictionary
// using the "name" as a key.
//
- (void)removeGameObjectForKey:(NSString *)gameObjectKey
{
	((GameObject *)[gameObjects objectForKey:gameObjectKey]).keyInGameData = nil;
	[gameObjects removeObjectForKey:gameObjectKey];
}

//
// collideObjectsWithKeyPrefix:withObjectForKey:
//
// Basic bounding box collision routine. Tests all objects with keys beginning
// with "prefix" against the object specified by the testObjectKey.
//
- (NSSet *)collideObjectsWithKeyPrefix:(NSString *)prefix withObjectForKey:(NSString *)testObjectKey
{
	GameObject *testObject = [gameObjects objectForKey:testObjectKey];
	NSMutableSet *result = [NSMutableSet set];
/*	
	CGRect testRect = CGRectMake(
								 testObject.x - 0.5 * testObject.width,
								 testObject.y - 0.5 * testObject.height,
								 testObject.width,
								 testObject.height);
*/	
	CGRect testRect = [testObject.layer frame];

	for (NSString *gameObjectKey in gameObjects)
	{
		if ([gameObjectKey isEqualToString:testObjectKey] ||
			[gameObjectKey rangeOfString:prefix].location != 0)
		{
			continue;
		}
		
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
/*		CGRect gameRect = CGRectMake(
									 gameObject.x - 0.5 * gameObject.width,
									 gameObject.y - 0.5 * gameObject.height,
									 gameObject.width,
									 gameObject.height);
		
*/
	CGRect gameRect = [gameObject.layer frame];

	if (CGRectIntersectsRect(gameRect, testRect))
		{
			[result addObject:gameObjectKey];
		}
	}
	
	return result;
}


//
- (NSSet *)collideObjectsWithKeyPrefixObject:(NSString *)prefix withObjectForKey:(NSString *)testObjectKey
{
	GameObject *testObject = [gameObjects objectForKey:testObjectKey];
	NSMutableSet *result = [NSMutableSet set];
	
/*	CGRect testRect = CGRectMake(
								 testObject.x - 0.5 * testObject.width,
								 testObject.y - 0.5 * testObject.height,
								 testObject.width,
								 testObject.height);
 */
	CGRect testRect = [testObject.layer frame];

	
	for (NSString *gameObjectKey in gameObjects)
	{
		if ([gameObjectKey isEqualToString:testObjectKey] ||
			[gameObjectKey rangeOfString:prefix].location != 0)
		{
			continue;
		}
		
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
/*		CGRect gameRect = CGRectMake(
									 gameObject.x - 0.5 * gameObject.width,
									 gameObject.y - 0.5 * gameObject.height,
									 gameObject.width,
									 gameObject.height);
		
*/
		CGRect gameRect = [gameObject.layer frame];
		if (CGRectIntersectsRect(gameRect, testRect))
		{
			[result addObject:gameObject];
		//	return gameObject;
		}
	}
	
	return result;
}



- (NSSet *)collideObjectsWithKeyPrefix:(NSString *)prefix withPoint:(CGPoint)testPoint
{
	NSMutableSet *result = [NSMutableSet set];
	
	
	for (NSString *gameObjectKey in gameObjects)
	{
		if ([gameObjectKey rangeOfString:prefix].location != 0)
		{
			continue;
		}

		
		double gameHeight = [[GameData sharedGameData] gameHeight];
		
		
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
		double x = gameObject.x;
		double y = gameObject.y;
		double width = gameObject.width;// * gameHeight;
		double height = gameObject.height;// * gameHeight;
		
//		CGRect gameRect = CGRectMake(	 x,			 y,								 width,									 height);
		
		CALayer* layer = gameObject.layer;
		CGRect frame = [layer frame];
		
		if (CGRectContainsPoint(frame, testPoint))
		{
			[result addObject:gameObjectKey];
		}
	}
	
	return result;
}



#pragma mark Game Loops

//
// readyCountdown:
//
// Does nothing for GAME_PREPARE_DELAY seconds then shows the player and starts
// playing the level.
//
- (void)readyCountdown:(NSTimer *)aTimer
{
	double delay = [[gameData objectForKey:GAME_DATA_PREPARE_TIMER_KEY] doubleValue];
	delay -= GAME_UPDATE_DURATION;
	[gameData setObject:[NSNumber numberWithDouble:delay] forKey:GAME_DATA_PREPARE_TIMER_KEY];
	
	if (delay <= 0)
	{
		[gameData removeObjectForKey:GAME_DATA_MESSAGE_KEY];
		
		for (NSString *gameObjectKey in gameObjects)
		{
			GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
			
			[gameObjects willChangeValueForKey:gameObjectKey];
			gameObject.visible = YES;
			[gameObjects didChangeValueForKey:gameObjectKey];
		}
		
		[self stopUpdates];
		updateSelector = @selector(updateLevel:);
		NSLog(@"Starting updatelevel timer in game data");
		[self startUpdates];
	}
}

//
// updateLevel
//
// Updates the game state
//
- (void)updateLevel:(NSTimer *)aTimer
{
//	NSLog(@"updateLevel-gd");
	if (lastUpdate)
	{
		frameDuration = [[NSDate date] timeIntervalSinceDate:lastUpdate];
		[lastUpdate release];
		lastUpdate = [[NSDate alloc] init];
	}
	else
	{
		frameDuration = GAME_UPDATE_DURATION;
	}
	
	NSArray *allKeys = [gameObjects allKeys];
	for (NSString *gameObjectKey in allKeys)
	{
		[gameObjects willChangeValueForKey:gameObjectKey];
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
		
		if ([gameObject collide])
		{
			[gameObjects removeObjectForKey:gameObjectKey];
		}
	}
	for (NSString *gameObjectKey in allKeys)
	{
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
		if (!gameObject)
		{
			[gameObjects didChangeValueForKey:gameObjectKey];
			continue;
		}
		
		if ([gameObject updateWithTimeInterval:frameDuration])
		{
			[gameObjects removeObjectForKey:gameObjectKey];
		}
		[gameObjects didChangeValueForKey:gameObjectKey];
	}
}

//
// startUpdates
//
// Starts the update timer.
//
- (void)startUpdates
{
	[lastUpdate release];
	lastUpdate = nil;
	
	timer =
	[NSTimer
	 scheduledTimerWithTimeInterval:GAME_UPDATE_DURATION
	 target:self
	 selector:updateSelector
	 userInfo:nil
	 repeats:YES];
}

//
// stopUpdates
//
// Removes the timer.
//
- (void)stopUpdates
{
	[timer invalidate];
	timer = nil;
}

#pragma mark Game and Level Management

//
// newGame
//
// Resets the game array, creates a new player object. Doesn't start a new
// level.
//
- (void)newGame:(BOOL)spawnPlayer
{
	[gameData setObject:[NSNumber numberWithInteger:GAME_LIVES] forKey:GAME_DATA_LIVES_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_LEVEL_KEY];
	
	[self newLevel:spawnPlayer];
}

//
// newLevel
//
// Resets the game array, creates a new player object. Doesn't start a new
// level.
//
- (void)newLevel:(BOOL)spawnPlayer
{
	[gameObjects removeAllObjects];
	
	NSInteger level = [[gameData objectForKey:GAME_DATA_LEVEL_KEY] integerValue];
	level += 1;
	
	[gameData setObject:[NSNumber numberWithInteger:level] forKey:GAME_DATA_LEVEL_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_NEXT_SHOT_INDEX_KEY];
	[gameData setObject:[NSNumber numberWithDouble:0] forKey:GAME_DATA_SHOT_COOLDOWN_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_ASTEROIDS_CREATED_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_ASTEROIDS_DESTROYED_KEY];
	
	if(spawnPlayer == YES) {
		[PlayerObject spawnPlayer];
	}
	
	for(int i = 0;i<level;i++) {
		[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	}
	
	[self preparationDelayWithMessage:[NSString stringWithFormat:@"Prepare for level %ld...", level]];


	
}


- (void)demoMode
{
	[gameData setObject:[NSNumber numberWithInteger:GAME_LIVES] forKey:GAME_DATA_LIVES_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_LEVEL_KEY];
	
	[gameObjects removeAllObjects];
	
	NSInteger level = [[gameData objectForKey:GAME_DATA_LEVEL_KEY] integerValue];
	level += 1;
	
	[gameData setObject:[NSNumber numberWithInteger:level] forKey:GAME_DATA_LEVEL_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_NEXT_SHOT_INDEX_KEY];
	[gameData setObject:[NSNumber numberWithDouble:0] forKey:GAME_DATA_SHOT_COOLDOWN_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_ASTEROIDS_CREATED_KEY];
	[gameData setObject:[NSNumber numberWithInteger:0] forKey:GAME_DATA_ASTEROIDS_DESTROYED_KEY];
	
	
	for(int i = 0;i<level;i++) {
		[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	}
		
}


//
// preparationDelayWithMessage:
//
// Sets the message, sets a delay timer and switches run loop to the readyCountdown.
//
- (void)preparationDelayWithMessage:(NSString *)message
{
	[gameData setObject:message forKey:GAME_DATA_MESSAGE_KEY];
	[gameData setObject:[NSNumber numberWithDouble:GAME_PREPARE_DELAY] forKey:GAME_DATA_PREPARE_TIMER_KEY];
	[self stopUpdates];
	updateSelector = @selector(readyCountdown:);
	[self startUpdates];
}

//
// endGame
//
// Stops updates and sends a game over notification.
//
- (void)endGame
{
	[self stopUpdates];
	[gameData setObject:@"Game Over" forKey:GAME_DATA_MESSAGE_KEY];
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:GAME_OVER_NOTIFICATION object:self];
	
	[gameData setObject:[NSNumber numberWithInteger:-1] forKey:GAME_DATA_LEVEL_KEY];
}

//
// changeRunSelector:
//
// Switches to a new run loop selector
//
- (void)changeRunSelector:(SEL)newSelector
{
	[self stopUpdates];
	updateSelector = newSelector;
	[self startUpdates];
}

@end
