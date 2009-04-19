//
//  ianimateAppDelegate.h
//  ianimate
//
//  Created by Shannon Appelcline on 10/17/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ianimateViewController;

@interface ianimateAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ianimateViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ianimateViewController *viewController;

@end

