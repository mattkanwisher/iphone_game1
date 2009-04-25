//
//  ShotObject.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "ShotObject.h"
#import "GameData.h"
#import "LittleDudeObject.h"

const double SHOT_DURATION = 1.0;
const double SHOT_FRAME_DURATION = 0.075;
const double SHOT_SIZE = 15;
const NSInteger SHOT_NUM_FRAMES = 5;

@implementation ShotObject

//
// initWithImageName:xFraction:yFraction:widthFraction:heightFraction:visible:
//
// Creates a new game object. The object is added to the gameObjects dictionary
// using the "name" as a key but is also returned for convenience.
//
- (id)initWithX:(double)newX
	y:(double)newY
{
	self = [super
		initWithImageName:@"bullet.png"
		x:newX
		y:newY
		width:SHOT_SIZE
		height:SHOT_SIZE
		visible:YES];
	if (self)
	{
		age = 0;
		frameIndex = 0;
	}

	return self;
}

//
// updateWithTimeInterval:
//
// Ages and expires shots.
//
- (BOOL)updateWithTimeInterval:(NSTimeInterval)timeInterval
{
	age += timeInterval;
	
	if (age > SHOT_DURATION)
	{
		return YES;
	}
	
	if (age > (frameIndex + 1) * SHOT_FRAME_DURATION)
	{
		frameIndex = (frameIndex + 1) % SHOT_NUM_FRAMES;
		//self.imageName = [NSString stringWithFormat:@"shot-frame%ld", frameIndex + 1];
	}
	
	return [super updateWithTimeInterval:timeInterval];
}

//
// collide
//
// Collides shot with asteroids.
//
- (BOOL)collide
{
	NSString *collision = [[[GameData sharedGameData]
			collideObjectsWithKeyPrefix:GAME_ASTEROID_KEY_BASE
			withObjectForKey:keyInGameData]
		anyObject];
	if (collision)
	{
		[LittleDudeObject blowup:collision];
		return YES;
	}
	return NO;
}

@end
