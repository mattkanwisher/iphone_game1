//
//  ImageLayer.h
//  Quartzeroids2
//
//  Created by Matt Gallagher on 13/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import <QuartzCore/QuartzCore.h>

@interface ImageLayer : CALayer
{
	NSString *imageName;
}

@property (nonatomic, retain) NSString *imageName;

- (id)initWithImageNamed:(NSString *)newImageName
	frame:(CGRect)newFrame;

@end

