//
//  GameObject.h
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

//#import <Cocoa/Cocoa.h>



@interface GameObject : NSObject
{
	NSString *keyInGameData;
	NSString *imageName;
	double angle;
	double x;
	double y;
	double width;
	double height;
	double speed;
	double trajectory;
	double lastCollision;
	double lastUpdateInterval;
	BOOL visible;
	CALayer* layer;
}

@property (nonatomic, retain) NSString *keyInGameData;
@property double angle;
@property double x;
@property double y;
@property double width;
@property double height;
@property double speed;
@property double lastCollision;
@property double trajectory;
@property double lastUpdateInterval;
@property BOOL visible;
@property (nonatomic, retain) CALayer* layer;
@property (nonatomic, retain) NSString *imageName;

- (id)initWithImageName:(NSString *)newImageName
	x:(double)newX
	y:(double)newY
	width:(double)newWidth
	height:(double)newHeight
	visible:(BOOL)newVisible;
- (BOOL)updateWithTimeInterval:(NSTimeInterval)timeInterval;
- (BOOL)collide;

@end



