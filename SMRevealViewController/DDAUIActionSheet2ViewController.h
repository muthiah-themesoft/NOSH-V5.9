//
//  DDAUIActionSheetViewController.h
//  UIActionSheetExample
//
//  Created by Dulio Denis on 3/23/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol ReasonDelegate <NSObject>
- (void)didSelectReason:(NSString*)str;
@end
@interface DDAUIActionSheet2ViewController : UIViewController
@property (nonatomic, weak) id<ReasonDelegate> delegate;
- (void)slideOut;
@end
