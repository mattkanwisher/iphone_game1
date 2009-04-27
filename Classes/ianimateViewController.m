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
#import "PlayerObject.h"

@implementation ianimateViewController

#define kAccelerometerFrequency     40

// Constant for maximum acceleration.
#define kMaxAcceleration 3.0
// Constant for the high-pass filter.
#define kFilteringFactor 0.1

const double LOGO_CLEAR_DURATION = 4.00;
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
	
	
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(gameEnded:)
	 name:GAME_OVER_NOTIFICATION
	 object:nil];
	
	
	clearlogoSelector = @selector(clearLogo:);

	timer =
	[NSTimer
	 scheduledTimerWithTimeInterval:LOGO_CLEAR_DURATION
	 target:self
	 selector:clearlogoSelector
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
	
	//Annoying crap for debugging
	//[ player play ];
	//[logo setHidden:YES];


	is_gameRunning = NO;
	
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
	

	[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];

	//[PlayerObject spawnPlayer];

	
	
    [super viewDidLoad];
	
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

- (void)clearLogo:(NSTimer *)aTimer
{
	[logo setHidden:YES];
}

- (void)updateLevel2:(NSTimer *)aTimer
{
//	NSLog(@"updateLevel2");
	if(spawnCouner < 4) {
//		[LittleDudeObject spawnNewAsteroidsReplacing:nil];
		spawnCouner++;
	}	
	
}	

- (void)drawBackground
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	
	backgroundLayer = 	[[[ImageLayer alloc]
						  initWithImageNamed:@"space_back.png"
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
	

- (void)MoveShipFromTouch:(CGPoint)startPos
{
 	PlayerObject* ship = [[[GameData sharedGameData] gameObjects] objectForKey:GAME_PLAYER_KEY];
	
	
	//	NSLog(@"Start point x- %f, y- %f", startPos.x, startPos.y);
	//	NSLog(@"End point x- %f, y- %f", ship.x, ship.y);
	//double line_angle  = atan2(ship.y - startPos.y, ship.x - startPos.x) *  180/ M_PI;
	double line_angle  = atan2(startPos.y - ship.y,startPos.x -  ship.x) *  180/ M_PI;
	double radians = atan2(ship.y - startPos.y, ship.x - startPos.x);//atan2(startPos.y - ship.y,startPos.x -  ship.x);
	NSLog(@"Angle - %f", line_angle);
	NSLog(@"radians - %f", radians);
	
	radians= radians - (M_PI /2);
	[GameData sharedGameData].upKeyDown = YES;
	ship.angle = line_angle;
	//ship.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1.0);
	ship.layer.transform = CATransform3DMakeRotation(ship.angle, 0, 0, 1.0);
		
}	

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( is_gameRunning == NO) 
		return;
	
    UITouch *touch = touches.anyObject;
	CGPoint startPos = [touch locationInView: self.view];
	
	[self MoveShipFromTouch:startPos];
	
	if([touch tapCount] > 1 ) {
		[[GameData sharedGameData] setShootKeyDown:YES];
	}
	//	PlaySound(@"Pop");

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if( is_gameRunning == NO) 
		return;

	UITouch *touch = [touches anyObject];
	CGPoint startPos = [touch locationInView: self.view];
	
	[self MoveShipFromTouch:startPos];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if( is_gameRunning == NO) 
		return;

	UITouch *touch = [touches anyObject];
}	


- (IBAction)newGame:(id)sender
{
	NSLog(@"new game !");
	[buttonContainerView setHidden:YES];
//	[contentView becomeFirstResponder];
	
	[[GameData sharedGameData] newGame];
	is_gameRunning = YES;
}


//
// gameEnded:
//
// Updates the UI for the out-of-game state.
//
- (IBAction)gameEnded:(id)sender
{
	[buttonContainerView setHidden:NO];
	is_gameRunning = NO;
}

- (IBAction)launchWebsite:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hyperworks.nu"]];
}

- (IBAction)showHighscore:(id)sender
{
	[highscoreView setHidden:NO];
	[buttonContainerView setHidden:YES];
	//Populate it here ;), i know its ghetto but i dont feel like breaking out a seperate controller yer
}

- (IBAction)hideHighscore:(id)sender
{
	[highscoreView setHidden:YES];
	[buttonContainerView setHidden:NO];
}


- (void)dealloc {
    [super dealloc];
}

@end
