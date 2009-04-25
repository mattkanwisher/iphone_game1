//
//  ianimateViewController.m
//  ianimate
//
//  Created by Shannon Appelcline on 10/17/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "ianimateViewController.h"
#import "AccelerometerSimulation.h"
#import "GameObject.h"
#import "GameData.h"
#import "LittleDudeObject.h"
#import "GameObjectLayer.h"
#import "AsteroidFrontLayer.h"
#import	"QuartzUtils.h"
#import "GGBUtils.h"
#import "GGBTextLayer.h"

@implementation ianimateViewController

#define kAccelerometerFrequency     40

// Constant for maximum acceleration.
#define kMaxAcceleration 3.0
// Constant for the high-pass filter.
#define kFilteringFactor 0.1

const double GAME_UPDATE_DURATION2 = 0.03;
const double GAME_UPDATE_DURATION3 = 4.0;

const double GAME_ASPECT2 = 16.0 / 10.0;
const double GAME_OBJECT_BOUNDARY_EXCESS2 = 0.1;
const double PLAYER_ACCELERATION2 = 0.25;
const double PLAYER_MAX_SPEED2 = 0.333;




- (void)viewDidLoad {
	// Configure and start the accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(createImageLayerForGameObject:)
	 name:GAME_OBJECT_NEW_NOTIFICATION
	 object:nil];

	
	curloc =  0;

	x = 0;
	y = 0;
	height = 320;
	width = 480;
	speed = 0;
	trajectory = 0;
	bdone = false;
	spawnCouner = 0;
	
	
	updateSelector = @selector(updateLevel:);

	timer =
	[NSTimer
	 scheduledTimerWithTimeInterval:GAME_UPDATE_DURATION2
	 target:self
	 selector:updateSelector
	 userInfo:nil
	 repeats:YES];

	

	
	updateSelector2 = @selector(updateLevel2:);
	
	timer2 =
	[NSTimer
	 scheduledTimerWithTimeInterval:GAME_UPDATE_DURATION3
	 target:self
	 selector:updateSelector2
	 userInfo:nil
	 repeats:YES];

	NSError *err;
	
	player = [ [ AVAudioPlayer alloc ]
			  initWithContentsOfURL: [ NSURL fileURLWithPath: [ [ NSBundle mainBundle ] pathForResource: @"sample" ofType:@"mp3" ] ]
			  error: &err
			  ];		
	
	if (err)
		NSLog(@"Failed to initialize AVAudioPlayer: %@\n", err);
	
//	[ self setNavProperties ];
	player.delegate = self;
	[ player prepareToPlay ];
	
	
	//[ player play ];

	
	[[GameData sharedGameData] newGame];

	angle = 45;
	
	[CATransaction begin];
	[CATransaction
	 setValue:[NSNumber numberWithBool:YES]
	 forKey:kCATransactionDisableActions];
	
	

	
	CALayer *rootLayer = self.view.layer;

	backgroundLayer = rootLayer;
	
	[self drawBackground];
	
	[CATransaction commit];
	
	[self DrawTransparentCover];

	[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];

	
    [super viewDidLoad];
	
}



- (void)DrawTransparentCover
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	
	CALayer* backgroundLayer2  = nil;
	for(int i = 0; i< 6; i ++ ) {
	backgroundLayer2 = [CALayer layer];
	
	backgroundLayer2.backgroundColor = GetCGPatternNamed(@"back2.png");
	//backgroundLayer2.backgroundColor   = [CGColor blackColor].CGColor;
	backgroundLayer2.bounds        = CGRectMake( 0 + (i*50), 0+ (i*50), 200, 200 );//backgroundLayer.bounds;
	backgroundLayer2.position      = CGPointMake( 0 + (i*50), 100 + (i*50));
	backgroundLayer2.anchorPoint         = CGPointMake( 0.5, 0.5 );
	backgroundLayer2.borderColor = GetCGPatternNamed(@"back2.png");//CGColorCreateGenericRGB(b,r,g,1.0f); 
	backgroundLayer2.name = @"Mask";
	backgroundLayer2.opacity = 0.98;
	backgroundLayer2.masksToBounds   = YES;
	[backgroundLayer addSublayer:backgroundLayer2];
	
	}

	/*CALayer* backgroundLayer3 =[CALayer layer];
	
	backgroundLayer3.backgroundColor = GetCGPatternNamed(@"back2.png");
	//backgroundLayer2.backgroundColor   = [CGColor blackColor].CGColor;
	backgroundLayer3.bounds        = CGRectMake( 0, 0, 100, 100 );//backgroundLayer.bounds;
	backgroundLayer3.position      = CGPointMake( 200, 200 );
	backgroundLayer3.anchorPoint         = CGPointMake( 0.5, 0.5 );
	backgroundLayer3.borderColor = GetCGPatternNamed(@"back2.png");//CGColorCreateGenericRGB(b,r,g,1.0f); 
	backgroundLayer3.borderWidth=1.0;
	backgroundLayer3.name = @"Mask";
	backgroundLayer3.opacity = 0.98;
	backgroundLayer3.masksToBounds   = YES;
	[backgroundLayer addSublayer:backgroundLayer3];
	 */
	[CATransaction commit];
	
}

//
// createImageLayerForGameObject:
//
// The game data sends a notification when a new game object is created. We
// create a layer to display that object here. The layer will maintain
// its own observations of further changes.
//
- (void)createImageLayerForGameObject:(NSNotification *)notification
{
	NSString *gameObjectKey = [notification object];	
	CALayer *rootLayer = self.view.layer;

	GameObjectLayer *newLayer =
	[[[GameObjectLayer alloc]
	  initWithGameObjectKey:gameObjectKey]
	 autorelease];
	
	[CATransaction begin];
	[CATransaction
	 setValue:[NSNumber numberWithBool:YES]
	 forKey:kCATransactionDisableActions];
	[backgroundLayer addSublayer:newLayer];

	[CATransaction commit];
	
	if ([gameObjectKey rangeOfString:GAME_ASTEROID_KEY_BASE].location == 0)
	{
		AsteroidFrontLayer *asteroidFrontLayer =
		[[[AsteroidFrontLayer alloc]
		  initWithGameObjectKey:gameObjectKey]
		 autorelease];
		
		[CATransaction begin];
		[CATransaction
		 setValue:[NSNumber numberWithBool:YES]
		 forKey:kCATransactionDisableActions];
		[backgroundLayer addSublayer:asteroidFrontLayer];
		[CATransaction commit];
	}	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// If filtering is active, apply a basic high-pass filter to remove the gravity influence from the accelerometer values
    if (filteringIsEnabled) {
        accelerationlist[0] = (float)acceleration.x * kFilteringFactor + accelerationlist[0] * (1.0 - kFilteringFactor);
        history[nextIndex][0] = (float)acceleration.x - accelerationlist[0];
        accelerationlist[1] = (float)acceleration.y * kFilteringFactor + accelerationlist[1] * (1.0 - kFilteringFactor);
        history[nextIndex][1] = acceleration.y - accelerationlist[1];
        accelerationlist[2] = (float)acceleration.z * kFilteringFactor + accelerationlist[2] * (1.0 - kFilteringFactor);
        history[nextIndex][2] = (float)acceleration.z - accelerationlist[2];
    } else {
        history[nextIndex][0] = (float)acceleration.x;
        history[nextIndex][1] = (float)acceleration.y;
        history[nextIndex][2] = (float)acceleration.z;
    }
	
//	if( acceleration.y != 0  ) {
	speed = acceleration.y;
	
//	}
	
    // Advance buffer pointer to next position or reset to zero.
    nextIndex = (nextIndex + 1) % kHistorySize;
}	


- (void)updateLevel2:(NSTimer *)aTimer
{
	NSLog(@"updateLevel2");
	if(spawnCouner < 4) {
		[LittleDudeObject spawnNewAsteroidsReplacing:nil];
		spawnCouner++;
	}	
	
}	

- (void)drawBackground
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	
	backgroundLayer = 	[[[ImageLayer alloc]
						  initWithImageNamed:@"girl.png"
						  frame:CGRectZero]
						 autorelease];
	
	//[[GGBLayer alloc] init];
	CGRect frame = self.view.frame;
	backgroundLayer.frame = frame;
	backgroundLayer.masksToBounds = YES;
	//    [rootLayer addSublayer: backgroundLayer];
	[self.view.layer insertSublayer:backgroundLayer atIndex:0];
	bdone = true;
	
	[CATransaction commit];
	
}
	
- (void)updateLevel:(NSTimer *)aTimer
{
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
	CGPoint startPos = [touch locationInView: self.view];

	NSString *collision = [[[GameData sharedGameData]
							collideObjectsWithKeyPrefix:GAME_ASTEROID_KEY_BASE
							withPoint:startPos]
						   anyObject];
	if (collision)
	{
		NSLog(@"Collision %@", collision);
		[[GameData sharedGameData]  removeGameObjectForKey:collision];
		PlaySound(@"Pop");

		for (int i = 0; i < backgroundLayer.sublayers.count; i++) {
			CALayer* layer = [backgroundLayer.sublayers objectAtIndex:i];
			NSLog(@"Layer-%@-%@", layer, layer.name);
			if( [layer.name isEqualToString:@"Mask"] ) {
				if( layer.hidden != YES ) {
					layer.hidden = YES;
					return;
				}
			}
		}
					NSLog(@"Level Complete!");

//					GGBLayer *front = [super createFront];
					NSString *name = [NSString stringWithFormat: @"Level complete!"];
					
					
#if TARGET_OS_IPHONE
					UIFont *cornerFont = [UIFont boldSystemFontOfSize: 24];
#else
					NSFont *cornerFont = [NSFont boldSystemFontOfSize: 24];
#endif
					GGBTextLayer *label;
					label = [GGBTextLayer textLayerInSuperlayer: backgroundLayer
													   withText: name
														   font: cornerFont
													  alignment: kCALayerMaxXMargin | kCALayerBottomMargin];
				
	}			
}




- (void)dealloc {
    [super dealloc];
}

@end
