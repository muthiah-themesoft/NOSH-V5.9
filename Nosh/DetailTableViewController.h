//
//  SimpleTableViewController.h
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAUIActionSheetViewController.h"
#import "DDAUIActionSheet2ViewController.h"
#import <MapKit/MapKit.h>
@interface DetailTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,AudioViewDelegate,ReasonDelegate>
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,readwrite)int indexPath;
@property (nonatomic,readwrite)BOOL disableButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic,strong)NSString *titleString;
@end



@interface UILabel (Boldify)
- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;
@end

