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




/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


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
	height = 400;
	width = 320;
	speed = 0;
	trajectory = 0;
	bdone = false;
	
	
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

	
	[[GameData sharedGameData] newGame];

	angle = 45;
	
	[CATransaction begin];
	[CATransaction
	 setValue:[NSNumber numberWithBool:YES]
	 forKey:kCATransactionDisableActions];
	
	
	
	CALayer *rootLayer = self.view.layer;
	//backgroundLayer = backgroundView.layer;
/*
    rootLayer.affineTransform = CGAffineTransformIdentity;
    CGRect frame = rootLayer.frame;
    frame.origin.x = frame.origin.y = 0;
    rootLayer.bounds = frame;
	
//    if( [gameClass landscapeOriented] && frame.size.height > frame.size.width ) {
        rootLayer.affineTransform = CGAffineTransformMakeRotation(M_PI/2);
        frame = CGRectMake(0,0,frame.size.height,frame.size.width);
        rootLayer.bounds = frame;
 //   }
    */
/*    backgroundLayer = 	[[[ImageLayer alloc]
					  initWithImageNamed:@"back2.png"
					  frame:CGRectZero]
					 autorelease];
	
	//[[GGBLayer alloc] init];
	CGRect frame = rootLayer.frame;
    backgroundLayer.frame = frame;
	backgroundLayer.masksToBounds = YES;
//    [rootLayer addSublayer: backgroundLayer];
	[rootLayer insertSublayer:backgroundLayer atIndex:0];
	*/
	backgroundLayer = rootLayer;
	
	//[LittleDudeObject spawnNewAsteroidsReplacing:nil];

	
	[CATransaction commit];

//    [backgroundLayer release];
//    _game = [[gameClass alloc] initNewGameWithTable: _gameboard];
/*	
	
	CALayer *thisLayer  = backgroundView.layer;//background.layer;//self.view.layer;
	backgroundLayer = backgroundView.layer;
	backgroundLayer.backgroundColor = GetCGPatternNamed(@"back.png");
	
	CALayer *backgroundLayer2 =
	[[[ImageLayer alloc]
	  initWithImageNamed:@"back.png"
	  frame:CGRectZero]
	 autorelease];
	backgroundLayer2.masksToBounds = YES;
//	[thisLayer insertSublayer:backgroundLayer atIndex:0];
	[backgroundLayer addSublayer:backgroundLayer2];

	double gameWidth = [[GameData sharedGameData] gameWidth];
	double gameHeight = [[GameData sharedGameData] gameHeight];
	
	CGSize contentSize = [self.view bounds].size;
	
	CGSize aspectSize = contentSize;
	double scale;
	if ((aspectSize.width / aspectSize.height) > (gameWidth / gameHeight))
	{
		scale = aspectSize.height / gameHeight;
		aspectSize.width = aspectSize.height * (gameWidth / gameHeight);
	}
	else
	{
		scale = aspectSize.width / gameWidth;
		aspectSize.height = aspectSize.width * (gameHeight / gameWidth);
	}
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1.0);
	backgroundLayer.frame =
	CGRectMake(
			   0.5 * (contentSize.width - aspectSize.width),
			   0.5 * (contentSize.height - aspectSize.height),
			   aspectSize.width,
			   aspectSize.height);
	[CATransaction commit];
	
	//	[background.layer insertSublayer:backgroundLayer atIndex:0];
//	[thisLayer updateContentViewFrame:nil];
	
*/
	
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	
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
		
		for (int i = 0; i < backgroundLayer.sublayers.count; i++) {
			CALayer* layer = [backgroundLayer.sublayers objectAtIndex:i];
			NSLog(@"Layer-%@-%@", layer, layer.name);
			//[layer setNeedsDisplay];
		}
		
		[asteroidFrontLayer setNeedsDisplay];
		[backgroundLayer setNeedsDisplay];
		[self.view setNeedsDisplay];
		[self.view.layer setNeedsDisplay];
		[CATransaction commit];

		[asteroidFrontLayer setNeedsDisplay];

	}

	[backgroundLayer setNeedsDisplay];
	[self.view setNeedsDisplay];
	[self.view.layer setNeedsDisplay];
	
}


-(IBAction)movePlane:(id)sender {
	/*
	
	
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];

	
	 */
	[UIView beginAnimations:nil context:NULL];
	
	CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(200, 200);
	[plane2.layer setAffineTransform:moveTransform];
	plane2.layer.opacity = 1;
	
	CGAffineTransform myAffine = CGAffineTransformMakeRotation(180*M_PI*2/360); //.50*M_PI); 
	CGAffineTransformTranslate(myAffine, 100, 100); 
	//CGContextConcatCTM(ctx, myAffine); 
	[background.layer setAffineTransform:myAffine];

	
	[LittleDudeObject spawnNewAsteroidsReplacing:nil];
	

	
	[UIView commitAnimations];


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


//	[self movePlane:nil];
//	if(bdone == false) {
		

		[LittleDudeObject spawnNewAsteroidsReplacing:nil];


//	}	
	
}	

- (void)drawBackground

{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	
	backgroundLayer = 	[[[ImageLayer alloc]
						  initWithImageNamed:@"back2.png"
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
	/*

	if (lastUpdate)
	{
		frameDuration = [[NSDate date] timeIntervalSinceDate:lastUpdate];
		[lastUpdate release];
		lastUpdate = [[NSDate alloc] init];
	}
	else
	{
		frameDuration = GAME_UPDATE_DURATION2;
	}
	

	[UIView beginAnimations:nil context:NULL];
	
	angle  += speed;
	CGAffineTransform myAffine = CGAffineTransformMakeRotation(angle*M_PI*2/360); //.50*M_PI); 
	CGAffineTransformTranslate(myAffine, 100, 100); 
	[background.layer setAffineTransform:myAffine];
	
	[UIView commitAnimations];
	*/
	/*

	curloc += speed;
	CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(curloc, curloc);
	[plane.layer setAffineTransform:moveTransform];		
	 
	 */
}





/** Locates the layer at a given point in window coords.
 If the leaf layer doesn't pass the layer-match callback, the nearest ancestor that does is returned.
 If outOffset is provided, the point's position relative to the layer is stored into it. */
/*
- (CALayer*) hitTestPoint: (CGPoint)where
         forLayerMatching: (LayerMatchCallback)match
                   offset: (CGPoint*)outOffset
{
    where = [_gameboard convertPoint: where fromLayer: self.layer];
    CALayer *layer = [_gameboard hitTest: where];
    while( layer ) {
        if( match(layer) ) {
            CGPoint bitPos = [self.layer convertPoint: layer.position 
                              fromLayer: layer.superlayer];
            if( outOffset )
                *outOffset = CGPointMake( bitPos.x-where.x, bitPos.y-where.y);
            return layer;
        } else
            layer = layer.superlayer;
    }
    return nil;
}

 */
#pragma mark -
#pragma mark MOUSE CLICKS & DRAGS:


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
	}		
	
    /*
    BOOL placing = NO;
    _dragStartPos = [touch locationInView: self];
    _dragBit = (Bit*) [self hitTestPoint: _dragStartPos
                        forLayerMatching: layerIsBit 
                                  offset: &_dragOffset];
	
    if( ! _dragBit ) {
        // If no bit was clicked, see if it's a BitHolder the game will let the user add a Bit to:
        id<BitHolder> holder = (id<BitHolder>) [self hitTestPoint: _dragStartPos
                                                 forLayerMatching: layerIsBitHolder
                                                           offset: NULL];
        if( holder ) {
            _dragBit = [_game bitToPlaceInHolder: holder];
            if( _dragBit ) {
                _dragOffset.x = _dragOffset.y = 0;
                if( _dragBit.superlayer==nil )
                    _dragBit.position = _dragStartPos;
                placing = YES;
            }
        }
    }
	
    if( ! _dragBit ) {
        Beep();
        return;
    }
    
    // Clicked on a Bit:
    _dragMoved = NO;
    _dropTarget = nil;
    _oldHolder = _dragBit.holder;
    // Ask holder's and game's permission before dragging:
    if( _oldHolder ) {
        _dragBit = [_oldHolder canDragBit: _dragBit];
        if( _dragBit && ! [_game canBit: _dragBit moveFrom: _oldHolder] ) {
            [_oldHolder cancelDragBit: _dragBit];
            _dragBit = nil;
        }
        if( ! _dragBit ) {
            _oldHolder = nil;
            Beep();
            return;
        }
    }
    // Start dragging:
    _oldSuperlayer = _dragBit.superlayer;
    _oldLayerIndex = [_oldSuperlayer.sublayers indexOfObjectIdenticalTo: _dragBit];
    _oldPos = _dragBit.position;
    ChangeSuperlayer(_dragBit, self.layer, self.layer.sublayers.count);
    _dragBit.pickedUp = YES;
    
    if( placing ) {
        if( _oldSuperlayer )
            _dragBit.position = _dragStartPos;      // animate Bit to new position
        _dragMoved = YES;
        [self _findDropTarget: _dragStartPos];
    }
	 */
}




- (void)dealloc {
    [super dealloc];
}

@end
