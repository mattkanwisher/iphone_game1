//
//  GameData.h
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//


@class GameObject;

@interface GameData : NSObject
{
	NSMutableDictionary *gameObjects;
	NSMutableDictionary *gameData;
	SEL updateSelector;
	
	NSDate *lastUpdate;
	NSTimeInterval frameDuration;
	
	NSTimer *timer;
	
	bool upKeyDown;
	bool leftKeyDown;
	bool rightKeyDown;
	bool shootKeyDown;
}

@property bool shootKeyDown;
@property bool rightKeyDown;
@property bool leftKeyDown;
@property bool upKeyDown;

+ (GameData *)sharedGameData;
- (NSDictionary *)gameData;
- (void)setGameDataObject:(id)object forKey:(NSString *)key;
- (NSDictionary *)gameObjects;
- (double)gameWidth;
- (double)gameHeight;
- (void)newGame:(BOOL)spawnPlayer;
- (void)demoMode;
- (void)newLevel:(BOOL)spawnPlayer;
- (void)endGame;
- (void)startUpdates;
- (void)stopUpdates;
- (void)changeRunSelector:(SEL)newSelector;
- (void)addGameObject:(GameObject *)newGameObject forKey:(NSString *)gameObjectKey;
- (void)removeGameObjectForKey:(NSString *)gameObjectKey;
- (NSString *)keyForShotAtIndex:(NSInteger)shotIndex;
- (NSString *)keyForAsteroidAtIndex:(NSInteger)asteroidIndex;
- (NSSet *)collideObjectsWithKeyPrefix:(NSString *)prefix withObjectForKey:(NSString *)testObjectKey;
- (NSSet *)collideObjectsWithKeyPrefix:(NSString *)prefix withPoint:(CGPoint)testPoint;
- (NSSet *)collideObjectsWithKeyPrefixObject:(NSString *)prefix withObjectForKey:(NSString *)testObjectKey;
- (void)preparationDelayWithMessage:(NSString *)message;

@end

extern NSString *GAME_OBJECT_NEW_NOTIFICATION;
extern NSString *GAME_OVER_NOTIFICATION;

extern const double GAME_ASPECT;
extern const double GAME_PREPARE_DELAY;
extern const double GAME_UPDATE_DURATION;

extern const NSInteger GAME_LIVES;

extern NSString *GAME_DATA_KEY;
extern NSString *GAME_DATA_ASTEROIDS_CREATED_KEY;
extern NSString *GAME_DATA_ASTEROIDS_DESTROYED_KEY;
extern NSString *GAME_DATA_LEVEL_KEY;
extern NSString *GAME_DATA_LIVES_KEY;
extern NSString *GAME_DATA_NEXT_SHOT_INDEX_KEY;
extern NSString *GAME_DATA_PREPARE_TIMER_KEY;
extern NSString *GAME_DATA_SHOT_COOLDOWN_KEY;
extern NSString *GAME_DATA_MESSAGE_KEY;
extern NSString *GAME_PLAYER_KEY;
extern NSString *GAME_SHOT_KEY_BASE;
extern NSString *GAME_ASTEROID_KEY_BASE;



