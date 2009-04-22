//
//  AsteroidFrontLayer.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "AsteroidFrontLayer.h"
#import "GameData.h"
#import "GameObject.h"

@implementation AsteroidFrontLayer

//
// initWithGameObjectKey:
//
// Init method for the object.
//
- (id)initWithGameObjectKey:(NSString *)newGameObjectKey
{
	self = [super initWithGameObjectKey:newGameObjectKey];
	if (self != nil)
	{
		const double MAX_ANGULAR_VELOCITY = 1.4;

		angle = 2.0 * M_PI * (double)random() / (double)INT_MAX;
		angularVelocity = -MAX_ANGULAR_VELOCITY + 2.0 * MAX_ANGULAR_VELOCITY * (double)random() / (double)INT_MAX;
		
		self.imageName = @"";//bubble.png";
	}
	return self;
}

//
// update
//
// Updates the layer based on the elements in the dictionary
//
- (void)update
{
	GameObject *gameObject = [[[GameData sharedGameData] gameObjects] objectForKey:gameObjectKey];
	double gameHeight = [[GameData sharedGameData] gameHeight];

	double x = gameObject.x * gameHeight;
	double y = gameObject.y * gameHeight;
	double width = gameObject.width * gameHeight;
	double height = gameObject.height * gameHeight;
	BOOL visible = gameObject.visible;
	
	angle += angularVelocity * gameObject.lastUpdateInterval;
	if (angle > 2.0 * M_PI)
	{
		angle -= 2.0 * M_PI; 
	}

	self.bounds = CGRectMake(0, 0, width, height);
	self.position = CGPointMake(x, y);
	self.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0);
	self.hidden = !visible;
}

@end
