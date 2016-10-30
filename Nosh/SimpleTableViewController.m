//
//  SimpleTableViewController.m
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "SimpleTableCell.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "SWRevealViewController.h"
#include <AudioToolbox/AudioToolbox.h>
#import "DetailTableViewController.h"
#import "AppDelegate.h"
@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController
{
    NSArray *tableData;
    NSArray *thumbnails;
    NSArray *prepTime;
    NSMutableData *urlData;
    MBProgressHUD *hud;
    NSArray *orderArray;
    __weak IBOutlet UITableView *tableview;
    AVAudioPlayer *myAudioPlayer;
}
-(void)reloadService:(NSNotification*)notification
{
    orderArray = [NSArray new];
    orderArray = notification.object;
    
    if (orderArray.count) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"vintage2" ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
        myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        myAudioPlayer.numberOfLoops = 1; //infinite loop
        [myAudioPlayer play];
        [tableview setHidden:NO];
    }
   [tableview reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadService:) name:@"reloadService" object:nil];

    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                         style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    orderArray = [[NSArray alloc]init];
	// Initialize table data
    tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
    
    // Initialize thumbnails
    thumbnails = [NSArray arrayWithObjects:@"egg_benedict.jpg", @"mushroom_risotto.jpg", @"full_breakfast.jpg", @"hamburger.jpg", @"ham_and_egg_sandwich.jpg", @"creme_brelee.jpg", @"white_chocolate_donut.jpg", @"starbucks_coffee.jpg", @"vegetable_curry.jpg", @"instant_noodle_with_egg.jpg", @"noodle_with_bbq_pork.jpg", @"japanese_noodle_with_pork.jpg", @"green_tea.jpg", @"thai_shrimp_cake.jpg", @"angry_birds_cake.jpg", @"ham_and_cheese_panini.jpg", nil];
    
    // Initialize Preparation Time
    prepTime = [NSArray arrayWithObjects:@"30 min", @"30 min", @"20 min", @"30 min", @"10 min", @"1 hour", @"45 min", @"5 min", @"30 min", @"8 min", @"20 min", @"20 min", @"5 min", @"1.5 hour", @"4 hours", @"10 min", nil];

    // Find out the path of recipes.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"recipes" ofType:@"plist"];    

    // Load the file content and read the data into arrays
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    tableData = [dict objectForKey:@"RecipeName"];
    thumbnails = [dict objectForKey:@"Thumbnail"];
    prepTime = [dict objectForKey:@"PrepTime"];
    self.title = self.titleString;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor =  [UIColor colorWithRed:110/255.0 green:94/255.0 blue:127/255.0 alpha:1.0];
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
   self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

-(NSString*) phoneNumber:(NSString *)str{
    static NSCharacterSet* set = nil;
    if (set == nil){
        set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    NSString* phoneString = [[str componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    switch (phoneString.length) {
        case 7: return [NSString stringWithFormat:@"%@-%@", [phoneString substringToIndex:3], [phoneString substringFromIndex:3]];
        case 10: return [NSString stringWithFormat:@"(%@) %@-%@", [phoneString substringToIndex:3], [phoneString substringWithRange:NSMakeRange(3, 3)],[phoneString substringFromIndex:6]];
        case 11: return [NSString stringWithFormat:@"%@ (%@) %@-%@", [phoneString substringToIndex:1], [phoneString substringWithRange:NSMakeRange(1, 3)], [phoneString substringWithRange:NSMakeRange(4, 3)], [phoneString substringFromIndex:7]];
        case 12: return [NSString stringWithFormat:@"+%@ (%@) %@-%@", [phoneString substringToIndex:2], [phoneString substringWithRange:NSMakeRange(2, 3)], [phoneString substringWithRange:NSMakeRange(5, 3)], [phoneString substringFromIndex:8]];
        default: return nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [orderArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[orderArray objectAtIndex:indexPath.row]objectForKey:@"order_type"]integerValue] == 1)
    return 197;
    else
        return 150;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";

    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) 
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    } 

    cell.nameLabel.text = [[orderArray objectAtIndex:indexPath.row]objectForKey:@"customer_name"];
    cell.addressLabel.text = [[orderArray objectAtIndex:indexPath.row]objectForKey:@"customer_address"];
    cell.orderLabel.text = [NSString stringWithFormat:@"Order #%@",[[orderArray objectAtIndex:indexPath.row]objectForKey:@"order_id"]];

    cell.phoneLabelk.text = [NSString stringWithFormat:@"Customer Phone #: %@",[self phoneNumber:[[orderArray objectAtIndex:indexPath.row]objectForKey:@"telephone"]]];
    cell.quantityLabel.text = [[orderArray objectAtIndex:indexPath.row]objectForKey:@"total"];
    if ([[[orderArray objectAtIndex:indexPath.row]objectForKey:@"order_type"]integerValue] == 1) {
    cell.pickupLabel.text = @"DELIVERY";
         cell.pickupLabel.backgroundColor = [UIColor colorWithRed:7/255.0 green:101/255.0 blue:15/255.0 alpha:1.0];
          cell.addressLabel.hidden =cell.address.hidden =NO;
    cell.prepTimeLabel.text = [NSString stringWithFormat:@"Requested for Deliver at %@",[[orderArray objectAtIndex:indexPath.row]objectForKey:@"date_added"]];
        
        NSString *text = cell.prepTimeLabel.text;
        NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:text];
        [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:7/255.0 green:101/255.0 blue:15/255.0 alpha:1.0] range:[text rangeOfString:@"Deliver"]];
        NSString *str= [[orderArray objectAtIndex:indexPath.row]objectForKey:@"date_added"];
        [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:[text rangeOfString:str]];
        cell.prepTimeLabel.attributedText = mutable;

    }
    else {
            cell.prepTimeLabel.text = [NSString stringWithFormat:@"Requested for Pick-up at %@",[[orderArray objectAtIndex:indexPath.row]objectForKey:@"date_added"]];
        cell.pickupLabel.text = @"PICKUP";
        NSString *text = cell.prepTimeLabel.text;
        NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:text];
        [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:17/255.0 green:41/255.0 blue:132/255.0 alpha:1.0] range:[text rangeOfString:@"Pick-up"]];
        NSString *str= [[orderArray objectAtIndex:indexPath.row]objectForKey:@"date_added"];
         [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:[text rangeOfString:str]];
        cell.prepTimeLabel.attributedText = mutable;
        cell.pickupLabel.backgroundColor = [UIColor colorWithRed:17/255.0 green:41/255.0 blue:132/255.0 alpha:1.0];

        cell.addressLabel.hidden =cell.address.hidden =YES;

    }
     if ([[[orderArray objectAtIndex:indexPath.row]objectForKey:@"payment_status"]integerValue] == 7) {
    cell.paidLabel.text = @"NOTPAID";
     }
     else {
         cell.paidLabel.text = @"PAID";
   
     }
    cell.backgroundColor = [UIColor colorWithRed:164/255.0 green:162/255.0 blue:163/255.0 alpha:1.0];

    cell.pickupLabel.layer.masksToBounds = YES;
    cell.pickupLabel.layer.cornerRadius = 4.0;
    cell.paidLabel.layer.masksToBounds = YES;
    cell.paidLabel.layer.cornerRadius = 4.0;
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 20.0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    DetailTableViewController *simple  = [[DetailTableViewController alloc] initWithNibName:@"DetailTableViewController" bundle:nil];
    simple.dict = [orderArray objectAtIndex:indexPath.row];
    simple.indexPath = indexPath.row;
    simple.titleString  = self.titleString;
    if ([self.titleString isEqualToString:@"New Orders"]) {
        simple.disableButton = NO;
    }
    else
        simple.disableButton = YES;

    [self.navigationController pushViewController:simple animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    

    if ([self.titleString isEqualToString:@"New Orders"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.configureDict = _dict;
        [appDelegate loadTimer];
      [self checkVersionUpdate];
    }
   	else if ([self.titleString isEqualToString:@"Confirmed Orders"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"acceptOrders"];
        orderArray = [[NSMutableArray alloc]init];
        orderArray  = [NSMutableArray arrayWithArray:arrayOfImages];
        [tableview reloadData];
    }
    else if ([self.titleString isEqualToString:@"Rejected Orders"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"rejectedOrders"];
        orderArray = [[NSMutableArray alloc]init];
        orderArray  = [NSMutableArray arrayWithArray:arrayOfImages];
        [tableview reloadData];
    }
    
    else if ([self.titleString isEqualToString:@"SearchBar"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"rejectedOrders"];
             NSArray *acceptedOrder = [userDefaults objectForKey:@"acceptOrders"];
        NSArray *noresponse = [userDefaults objectForKey:@"noresponse"];
        NSMutableArray *combinedArray = [[NSMutableArray alloc]init];
        [combinedArray addObjectsFromArray:arrayOfImages];
        [combinedArray addObjectsFromArray:acceptedOrder];
        [combinedArray addObjectsFromArray:noresponse];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", _searchString];
        
       NSMutableArray *orderData = [[NSMutableArray alloc]init];
        orderData = [NSMutableArray arrayWithArray:[combinedArray filteredArrayUsingPredicate:predicate]];
        orderArray =[NSArray new];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"customer_name CONTAINS[cd] %@", _searchString];
        NSArray *searchArray = [combinedArray filteredArrayUsingPredicate:predicate1];
        for (NSDictionary *dict  in searchArray) {
            [orderData addObject:dict];
        }
        orderArray =[NSArray arrayWithArray:orderData];

        
        [tableview reloadData];
        self.title = @"Search Result";

    }
    else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"noresponse"];
        orderArray = [[NSMutableArray alloc]init];
        orderArray  = [NSMutableArray arrayWithArray:arrayOfImages];
        
        
        [tableview reloadData];

    }
    if (!orderArray.count && ![self.titleString isEqualToString:@"New Orders"]) {
        UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height/2, self.view.frame.size.width-10, 60)];
        [self.titleString stringByReplacingOccurrencesOfString:@"No" withString:@""];
        fromLabel.text =[NSString stringWithFormat:@"No %@",self.titleString];
        if ([self.titleString isEqualToString:@"No response orders"]) {
            fromLabel.text =[NSString stringWithFormat:@"%@",self.titleString];
        }
        [fromLabel setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];

        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.textColor = [UIColor lightGrayColor];
        fromLabel.textAlignment = NSTextAlignmentCenter;
        [fromLabel setFont:[UIFont systemFontOfSize:25 weight:1.0]];
        [self.view addSubview:fromLabel];
        [tableview setHidden:YES];
    }
    else {
        [tableview setHidden:NO];
    }
    
    [super viewDidAppear:animated];
}
-(void)checkVersionUpdate
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *str = [[_dict objectForKey:@"message"]objectForKey:@"file_path"];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:120.0];
    
    // Create the NSMutableData to hold the received data.
    // receivedData is an instance variable declared elsewhere.
    urlData = [NSMutableData dataWithCapacity: 0];
    
    
    [theRequest setHTTPMethod:@"POST"];
//    NSString *postString = [NSString stringWithFormat:@"resturent_id=%@&username=%@&password=%@",_resturauntid.text,_userName.text,_password.text];
//    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        /* initialize the buffer */
        //urlData = [NSMutableData data];
        
        /* start the request */
        [theConnection start];
    }
    else
    {
        NSLog(@"Connection Failed");
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [urlData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        NSError *jsonParsingError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&jsonParsingError];
        [hud removeFromSuperview];
        if (jsonParsingError) {
            NSLog(@"JSON ERROR: %@", [jsonParsingError localizedDescription]);
        } else {
            NSLog(@"OBJECT: %@", (NSDictionary *)object);
            if([[(NSDictionary *)object objectForKey:@"error"] intValue])
            {
                
                [self sendMesage:[(NSDictionary *)object objectForKey:@"message"] title:@"Error!"];
                
            }
            else {
                
                if ([[(NSDictionary *)object objectForKey:@"status"]integerValue] == 200) {
                    orderArray = [object objectForKey:@"orders"];
                    
//                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                    NSArray *arrayOfImages = [userDefaults objectForKey:@"noresponse"];
//                    NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
//                    [array addObjectsFromArray:orderArray];
//                    
//                    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:array];
//                    NSArray *arrayWithoutDuplicates = [orderedSet array];
//                    [userDefaults setObject:arrayWithoutDuplicates forKey:@"noresponse"];
//                    [userDefaults synchronize];
                    
                    [tableview reloadData];
                    if (!orderArray.count) {
                        UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height/2, self.view.frame.size.width-50, 60)];
                        [fromLabel setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];

                        fromLabel.text =@"No New Orders";
                        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
                        fromLabel.backgroundColor = [UIColor clearColor];
                        fromLabel.textColor = [UIColor lightGrayColor];
                        fromLabel.textAlignment = NSTextAlignmentCenter;
                        [fromLabel setFont:[UIFont systemFontOfSize:30 weight:1.0]];
                        [self.view addSubview:fromLabel];
                        [tableview setHidden:YES];
                    }
                    else
                    {
                        int Count = 0 ;
                        for (NSDictionary *dict  in orderArray) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", [dict valueForKey:@"order_id"]];
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSArray *arrayOfImages = [userDefaults objectForKey:@"noresponse"];
                            NSArray *searchArray = [arrayOfImages filteredArrayUsingPredicate:predicate];
                            if (searchArray.count) {
                                Count = Count+1;
                            }
                            else {
                                Count = Count-1;
                            }
                        }
                 
                        
                        if ([self.titleString isEqualToString:@"New Orders"]&& Count <= 0) {
                            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"vintage2" ofType: @"mp3"];
                            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
                            myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
                            myAudioPlayer.numberOfLoops = 4; //infinite loop
                            [myAudioPlayer play];
                            [tableview setHidden:NO];
                        }
                    }
                    
                    
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSArray *arrayOfImages = [userDefaults objectForKey:@"noresponse"];
                    NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
                    [array addObjectsFromArray:orderArray];
                    
                    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:array];
                    NSArray *arrayWithoutDuplicates = [orderedSet array];
                    [userDefaults setObject:arrayWithoutDuplicates forKey:@"noresponse"];
                    [userDefaults synchronize];
                    
                }
                else {
                    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-75), self.view.frame.size.height/2, 300, 60)];
                    fromLabel.text =@"No New Orders";
                    [fromLabel setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];

                    fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
                    fromLabel.backgroundColor = [UIColor clearColor];
                    fromLabel.textColor = [UIColor lightGrayColor];
                    fromLabel.textAlignment = NSTextAlignmentCenter;
                    [fromLabel setFont:[UIFont systemFontOfSize:30 weight:1.0]];
                    [self.view addSubview:fromLabel];
                    [tableview setHidden:YES];

                }
            }
        }
    });
   }


-(void)sendMesage:(NSString *)message title:(NSString *)title {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: title
                                                                        message: message
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Ok"
                                                          style: UIAlertActionStyleDestructive
                                                        handler: ^(UIAlertAction *action) {
                                                            
                                                        }];
    
    [controller addAction: alertAction];
    
    [self presentViewController: controller animated: YES completion: nil];
}

@end

