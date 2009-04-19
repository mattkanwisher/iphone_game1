//
//  LittleDudeObject.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "LittleDudeObject.h"
#import "GameData.h"

const double ASTEROID_LARGE_SIZE = 0.1;
const double ASTEROID_MAX_SPEED = 0.166;
const double ASTEROID_MEDIUM_SIZE = 0.065;
const double ASTEROID_MIN_SPEED = 0.033;
const double ASTEROID_SMALL_SIZE = 0.04;
const double ASTEROID_START_RADIUS = 0.40;
const NSInteger ASTEROID_BASE_NUM = 3;

@implementation LittleDudeObject


+ (void)spawnNewAsteroids
{
	
	double x;
	double y;
	double size;
	
	double angle = 2.0 * M_PI * (double)random() / (double)INT_MAX;
	x = 0.5 * GAME_ASPECT + ASTEROID_START_RADIUS * cos(angle);
	y = 0.5 + ASTEROID_START_RADIUS * sin(angle);
	
	
	NSInteger newAsteroidIndex = [[[[GameData sharedGameData] gameData]
								   objectForKey:GAME_DATA_ASTEROIDS_CREATED_KEY] integerValue];
	[[GameData sharedGameData]
	 setGameDataObject:[NSNumber numberWithInteger:newAsteroidIndex + 1]
	 forKey:GAME_DATA_ASTEROIDS_CREATED_KEY];
	
	LittleDudeObject *asteroid = [[LittleDudeObject alloc]
								  initWithImageName:@"little-dude.png"//"little-dude"
								  x:x
								  y:y
								  width:size
								  height:size
								  visible:YES];
	[[GameData sharedGameData]
	 addGameObject:asteroid
	 forKey:[[GameData sharedGameData] keyForAsteroidAtIndex:newAsteroidIndex]];
	
	asteroid.trajectory = 2.0 * M_PI * (double)random() / (double)INT_MAX;
	asteroid.speed =
	ASTEROID_MIN_SPEED +
	(ASTEROID_MAX_SPEED - ASTEROID_MIN_SPEED) *
	(double)random() / (double)INT_MAX;

}
//
// spawnNewAsteroidsReplacing:
//
// Creates new asteroids. If existingAsteroidKey is nil, level + 1 asteroids
// are spawned randomly placed in a ring around the player. If existingAsteroidKey
// is not nil, 3 asteroids of 1 size smaller than the existing are spawned at
// the existing's location and the existing is removed.
//
+ (void)spawnNewAsteroidsReplacing:(NSString *)existingAsteroidKey
{
	double x;
	double y;
	double size;
	
	if (existingAsteroidKey)
	{
		NSInteger destroyedCount =
			[[[[GameData sharedGameData] gameData]
				objectForKey:GAME_DATA_ASTEROIDS_DESTROYED_KEY] integerValue];
		destroyedCount += 1;
		[[GameData sharedGameData]
			setGameDataObject:[NSNumber numberWithInteger:destroyedCount]
			forKey:GAME_DATA_ASTEROIDS_DESTROYED_KEY];

		GameObject *existing = [[[GameData sharedGameData] gameObjects] objectForKey:existingAsteroidKey];
		size = existing.width;
		x = existing.x;
		y = existing.y;
		
		[[GameData sharedGameData] removeGameObjectForKey:existingAsteroidKey];
		
		if (size - DBL_EPSILON < ASTEROID_SMALL_SIZE)
		{
			NSInteger createdCount =
				[[[[GameData sharedGameData] gameData]
					objectForKey:GAME_DATA_ASTEROIDS_CREATED_KEY] integerValue];
			
			if (destroyedCount == createdCount)
			{
				[[GameData sharedGameData] newLevel];
				return;
			}

			return;
		}
		else if (size - DBL_EPSILON < ASTEROID_MEDIUM_SIZE)
		{
			size = ASTEROID_SMALL_SIZE;
		}
		else
		{
			size = ASTEROID_MEDIUM_SIZE;
		}
	}
	else
	{
		size = ASTEROID_LARGE_SIZE;
	}
	
	NSInteger level = [[[[GameData sharedGameData] gameData] objectForKey:GAME_DATA_LEVEL_KEY] integerValue];
	NSInteger i;
	//ASTEROID_BASE_NUM
	for (i = 0; i < 2 + (existingAsteroidKey ? 0 : (level - 1)); i++)
	{
		if (!existingAsteroidKey)
		{
			double angle = 2.0 * M_PI * (double)random() / (double)INT_MAX;
			x = 0.5 * GAME_ASPECT + ASTEROID_START_RADIUS * cos(angle);
			y = 0.5 + ASTEROID_START_RADIUS * sin(angle);
		}
		
		NSInteger newAsteroidIndex = [[[[GameData sharedGameData] gameData]
			objectForKey:GAME_DATA_ASTEROIDS_CREATED_KEY] integerValue];
		[[GameData sharedGameData]
			setGameDataObject:[NSNumber numberWithInteger:newAsteroidIndex + 1]
			forKey:GAME_DATA_ASTEROIDS_CREATED_KEY];

		LittleDudeObject *asteroid = [[LittleDudeObject alloc]
			initWithImageName:@"little-dude.png"//"little-dude"
			x:x
			y:y
			width:size
			height:size
  		     visible:YES];//existingAsteroidKey ? YES : NO];
		[[GameData sharedGameData]
			addGameObject:asteroid
			forKey:[[GameData sharedGameData] keyForAsteroidAtIndex:newAsteroidIndex]];
		
		asteroid.trajectory = 2.0 * M_PI * (double)random() / (double)INT_MAX;
		asteroid.speed =
			ASTEROID_MIN_SPEED +
			(ASTEROID_MAX_SPEED - ASTEROID_MIN_SPEED) *
				(double)random() / (double)INT_MAX;
	}
}

@end
