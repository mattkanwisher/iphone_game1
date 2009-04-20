//
//  ianimateViewController.h
//  ianimate
//
//  Created by Shannon Appelcline on 10/17/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>


// Constant for the number of acceleration samples kept in history.
#define kHistorySize 150

@interface ianimateViewController : UIViewController <UIAccelerometerDelegate,AVAudioPlayerDelegate> {

	IBOutlet UIImageView *plane;
	IBOutlet UIImageView *plane2;
	IBOutlet UIImageView *background;
	IBOutlet UIView *backgroundView;

	CALayer *backgroundLayer;
	
	NSUInteger nextIndex;
    UIAccelerationValue accelerationlist[3];
    // Two dimensional array of acceleration data.
    UIAccelerationValue history[kHistorySize][3];
    BOOL filteringIsEnabled;
    BOOL updatingIsEnabled;
	BOOL bdone;
	int curloc;
	NSTimer *timer;
	NSTimer *timer2;
	NSDate *lastUpdate;
	SEL updateSelector;
	SEL updateSelector2;

	double x;
	double y;
	double height;
	double width;
	double trajectory;
	double speed;
	double angle;
	
	
	NSTimeInterval frameDuration;
	AVAudioPlayer *player;
}



-(IBAction)movePlane:(id)sender;
- (void)drawBackground;
- (void)DrawTransparentCover;

@end

  