//
//  GameObject.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "GameObject.h"
#import "GameData.h"

const double GAME_OBJECT_BOUNDARY_EXCESS = 0.1;

@implementation GameObject

@synthesize keyInGameData;
@synthesize angle;
@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize speed;
@synthesize trajectory;
@synthesize lastUpdateInterval;
@synthesize visible;
@synthesize imageName;
@synthesize lastCollision;
@synthesize layer;

const NSInteger GAME_LIVES = 3;
const double GAME_ASPECT = 16.0 / 10.0;
const double GAME_PREPARE_DELAY = 1.5;
const double GAME_UPDATE_DURATION = 0.03;
const double GAME_WIDTH=320;
const double GAME_HEIGHT=480;

//
// initWithImageName:xFraction:yFraction:widthFraction:heightFraction:visible:
//
// Creates a new game object. The object is added to the gameObjects dictionary
// using the "name" as a key but is also returned for convenience.
//
- (id)initWithImageName:(NSString *)newImageName
	x:(double)newX
	y:(double)newY
	width:(double)newWidth
	height:(double)newHeight
	visible:(BOOL)newVisible
{
	self = [super init];
	if (self)
	{
		self.imageName = newImageName;
		angle = 0;
		x = newX;
		y = newY;
		width = newWidth;
		height = newHeight;
		visible = newVisible;
		speed = 0;
		trajectory = 0;
		lastUpdateInterval = 0;
		lastCollision = 0;
	}

	return self;
}

//
// updateWithTimeInterval:
//
// Updates the object's properties given the elapsed time.
// This method should not interact with existing GameObjects (that should be
// done in -(void)collide).
//
// Returns YES if object data should be removed. NO otherwise.
//
- (BOOL)updateWithTimeInterval:(NSTimeInterval)timeInterval
{
//	double bangle = 70;
	trajectory = angle * M_PI / 180; 
	double xchange = timeInterval * speed * cos(trajectory);
	double ychange = timeInterval * speed * sin(trajectory);
	x += xchange;
	y += ychange;
	
	if (x > GAME_WIDTH)//GAME_ASPECT + (0.5 + GAME_OBJECT_BOUNDARY_EXCESS) * width)
	{
		//x = -0.5 * width;
		angle = angle + 180;
	}
	else if (x < 0)//(0.5 + GAME_OBJECT_BOUNDARY_EXCESS) * width)
	{
		//x = GAME_ASPECT + width;
		angle = angle + 180;
	}
	
	if (y > 1.0 + GAME_HEIGHT)//(0.5 + GAME_OBJECT_BOUNDARY_EXCESS) * height)
	{
		//y = -0.5 * height;
		angle = angle + 180;
	}
	else if (y < 0)//(0.5 + GAME_OBJECT_BOUNDARY_EXCESS) * height)
	{
//		y = 1.0 + 0.5 * height;
		angle = angle + 180;
		//if(lastCollision > 0) {
		//	angle = angle -180;
		//	lastCollision = 1;
	//	}
	}
	
	if(lastCollision > 0) {
		lastCollision += lastUpdateInterval;
	}
	if( lastCollision > 1.4 ) {
		lastCollision = 0;
	}
	
	lastUpdateInterval = timeInterval;
	return NO;
}

//
// collide
//
// Performs interaction with other game objects (by default, does nothing).
// This method should update the object's frame (that should be
// done in -(void)updateWithTimeInterval:).
//
// Returns YES if object data should be removed. NO otherwise.
//
- (BOOL)collide
{
	return NO;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[imageName release];
	[super dealloc];
}

@end



