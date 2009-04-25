//
//  ShotObject.h
//  Quartzeroids2
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "GameObject.h"

@interface ShotObject : GameObject
{
	double age;
	NSInteger frameIndex;
}

- (id)initWithX:(double)newX
	y:(double)newY;

@end
