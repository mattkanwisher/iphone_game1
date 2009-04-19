//
//  ImageLayer.m
//  Quartzeroids2
//
//  Created by Matt Gallagher on 13/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Use of this file is subject to the BSD-style license in the license.txt file
//  distributed with the project.
//

#import "ImageLayer.h"
#import "QuartzUtils.h"

@implementation ImageLayer

@synthesize imageName;

//
// initWithImageNamed
//
// Init method for the object.
//
- (id)initWithImageNamed:(NSString *)newImageName
	frame:(CGRect)newFrame
{
	UIImage *uiImage = [UIImage imageNamed:newImageName];

    if(!uiImage) {
		NSLog(@"UIImage imageWithContentsOfFile failed on file %@",newImageName);
	}

	self = [super init];
	if (self != nil)
	{
		self.anchorPoint = CGPointMake(0, 0);//CGPointMake(0.5, 0.5);
		imageName = [newImageName retain];
		[self setNeedsDisplay];
		[self setFrame:newFrame];
	}
	return self;
}

- (id<CAAction>)actionForKey:(NSString *)aKey
{
	return nil;
}

//
// setImageName:
//
// Override of accessor to ensure layer is redraw when change occurs.
//
- (void)setImageName:(NSString *)newImageName
{
	if (newImageName != imageName)
	{
		[imageName release];
		imageName = [newImageName retain];
		[self setNeedsDisplay];
	} 
}

//
// drawInContext
//
// Draws the selected image in the layer.
//
- (void)drawInContext:(CGContextRef)ctx
{
	
	[super drawInContext: ctx];    
    CGContextSaveGState(ctx);
	
	/*
	CGGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	NSGraphicsContext *context =
		[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
	*/
/*
 UIImage *image = [UIImage imageNamed:imageName];
	[image
	 drawInRect:[self bounds] ];
 */
	CGImageRef _image = GetCGImageNamed(imageName);
	CGContextDrawImage(ctx, [self bounds], _image);

	/*
//		fromRect:[image alignmentRect]
		//operation:CGCompositeSourceOver
		fraction:1.0];
	 */
	
	CGContextRestoreGState(ctx);
	//[NSGraphicsContext setCurrentContext:oldContext];
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

