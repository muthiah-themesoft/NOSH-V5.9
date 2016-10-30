//
//  SimpleTableViewController.h
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)NSString *titleString;
@property (nonatomic,strong)NSString *searchString;

@end
