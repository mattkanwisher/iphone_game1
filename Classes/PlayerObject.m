//
//  PlayerObject.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "PlayerObject.h"
#import "GameData.h"
#import "ShotObject.h"
#import "LittleDudeObject.h"

const double PLAYER_ACCELERATION = 0.25;
const double PLAYER_ANGULAR_SPEED = 1.25;
const double PLAYER_MAX_SPEED = 0.333;
const double PLAYER_SIZE = 45;
const double PLAYER_SHOT_COOLDOWN = 0.125;
const double PLAYER_SHOT_SPEED = 0.45;
const NSInteger PLAYER_MAX_SHOTS = 5;

@implementation PlayerObject

//
// spawnPlayer
//
// Creates a new PlayerObject and adds it to the game, replacing any existing
// PlayerObject.
//
+ (void)spawnPlayer
{
	[[GameData sharedGameData] removeGameObjectForKey:GAME_PLAYER_KEY];

	//
	// Create player
	//
	PlayerObject *player = [[PlayerObject alloc]
		initWithImageName:@"ship.png"
		x:100
		y:100
		width:PLAYER_SIZE
		height:PLAYER_SIZE
		visible:NO];

	[[GameData sharedGameData] addGameObject:player forKey:GAME_PLAYER_KEY];
}

//
// updateWithTimeInterval:
//
// Accelerates or rotates the player or fires shots in reaction to different
// key presses.
//
- (BOOL)updateWithTimeInterval:(NSTimeInterval)timeInterval
{
	if ([GameData sharedGameData].rightKeyDown)
	{
		angle -= timeInterval * M_PI * PLAYER_ANGULAR_SPEED;
		if (angle < -M_PI)
		{
			angle += 2 * M_PI;
		}
	}
	else if ([GameData sharedGameData].leftKeyDown)
	{
		angle += timeInterval * M_PI * PLAYER_ANGULAR_SPEED;
		if (angle > M_PI)
		{
			angle -= 2 * M_PI;
		}
	}
	
	if ([GameData sharedGameData].upKeyDown)
	{
		double scaledAcceleration = timeInterval * PLAYER_ACCELERATION;
		double dX = speed * cos(trajectory) + scaledAcceleration * cos(angle + M_PI_2);
		double dY = speed * sin(trajectory) + scaledAcceleration * sin(angle + M_PI_2);
		
		speed = sqrt(dX * dX + dY * dY);
		trajectory = acos(dX / speed);
		if (dY < 0)
		{
			trajectory *= -1;
		}
		
		if (speed > PLAYER_MAX_SPEED)
		{
			speed = PLAYER_MAX_SPEED;
		}
	}
	
	shotCooldown -= timeInterval;

	if ([GameData sharedGameData].shootKeyDown && shotCooldown < 0)
	{
		NSInteger nextShotIndex =
			[[[[GameData sharedGameData] gameData]
				objectForKey:GAME_DATA_NEXT_SHOT_INDEX_KEY] integerValue];
		NSDictionary *existingShot =
			[[[GameData sharedGameData] gameObjects]
				objectForKey:[[GameData sharedGameData] keyForShotAtIndex:nextShotIndex]];
		
		if (!existingShot)
		{
			//x + 0.5 * width * cos(angle + M_PI_2)
			//y + 0.5 * height * sin(angle + M_PI_2)
			ShotObject *newShot =
				[[ShotObject alloc]
					initWithX:200
					y:200];
			[[GameData sharedGameData]
				addGameObject:newShot
				forKey:[[GameData sharedGameData] keyForShotAtIndex:nextShotIndex]];

			nextShotIndex = (nextShotIndex + 1) % PLAYER_MAX_SHOTS;
			[[GameData sharedGameData]
				setGameDataObject:[NSNumber numberWithInteger:nextShotIndex]
				forKey:GAME_DATA_NEXT_SHOT_INDEX_KEY];
			
			double dX = speed * cos(trajectory) + PLAYER_SHOT_SPEED * cos(angle + M_PI_2);
			double dY = speed * sin(trajectory) + PLAYER_SHOT_SPEED * sin(angle + M_PI_2);
			double shotSpeed = sqrt(dX * dX + dY * dY);
			double shotTrajectory = acos(dX / shotSpeed);
			if (dY < 0)
			{
				shotTrajectory *= -1;
			}
			newShot.speed = shotSpeed;
			newShot.trajectory = shotTrajectory;
			
			shotCooldown = PLAYER_SHOT_COOLDOWN;
		}
		else
		{
			[GameData sharedGameData].shootKeyDown = NO;
		}
	}
	
	return [super updateWithTimeInterval:timeInterval];
}

//
// collide
//
// Detects collisions between the player and asteroids.
//
- (BOOL)collide
{
	return NO;
	NSString *collision = [[[GameData sharedGameData]
			collideObjectsWithKeyPrefix:GAME_ASTEROID_KEY_BASE
			withObjectForKey:GAME_PLAYER_KEY]
		anyObject];
	if (collision)
	{
		[LittleDudeObject blowup:collision];

		NSInteger lives =
			[[[[GameData sharedGameData] gameData]
				objectForKey:GAME_DATA_LIVES_KEY] integerValue];
		lives -= 1;
		[[GameData sharedGameData]
			setGameDataObject:[NSNumber numberWithInteger:lives]
			forKey:GAME_DATA_LIVES_KEY];
		
		if (lives == 0)
		{
			[[GameData sharedGameData] endGame];
			return NO;
		}
		
		[PlayerObject spawnPlayer];
		
		[[GameData sharedGameData] preparationDelayWithMessage:
			[NSString stringWithFormat:@"%ld ships remaining...", lives]];
	}
	
	return NO;
}

@end
