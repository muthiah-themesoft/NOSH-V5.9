//
//  DDAUIActionSheetViewController.h
//  UIActionSheetExample
//
//  Created by Dulio Denis on 3/23/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol AudioViewDelegate <NSObject>
- (void)didSelectTimings:(NSString*)str;
@end
@interface DDAUIActionSheetViewController : UIViewController
@property (nonatomic, weak) id<AudioViewDelegate> delegate;

- (void)slideOut;

@end
