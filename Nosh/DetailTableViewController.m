//
//  SimpleTableViewController.m
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import "DetailTableViewController.h"
#import "DetailCell.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "SWRevealViewController.h"
#include <AudioToolbox/AudioToolbox.h>
#import "DeliveryTableViewCell.h"
#import "SummaryTableViewCell.h"
#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import "PostMasterTableViewCell.h"
#import "WebViewController.h"
@interface DetailTableViewController ()
@property (nonatomic) DDAUIActionSheetViewController *customActionSheet;
@property (nonatomic) DDAUIActionSheet2ViewController *customActionSheet1;


@end
@implementation UILabel (Boldify)
- (void)boldRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText;
    if (!self.attributedText) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    self.attributedText = attributedText;
}

- (void)boldSubstring:(NSString*)substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}
@end
@implementation DetailTableViewController
{
    NSArray *tableData;
    NSArray *thumbnails;
    NSArray *prepTime;
    NSMutableData *urlData;
    MBProgressHUD *hud;
    NSArray *orderArray;
    __weak IBOutlet UITableView *tableview;
    AVAudioPlayer *myAudioPlayer;
    __weak IBOutlet UIButton *accept;
    __weak IBOutlet UIButton *reject;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet NSLayoutConstraint *tableviewheight;
    __weak IBOutlet UIButton *statusBtn;
    UIBarButtonItem *flipButton;
}
-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.title = [NSString stringWithFormat:@"Order# %@",[_dict objectForKey:@"order_id"]];
    statusBtn.hidden =YES;
    if (_disableButton) {
       titleLabel.hidden =  accept.hidden = reject.hidden = _disableButton;
    }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *rejectedOrders = [userDefaults objectForKey:@"rejectedOrders"];
        NSMutableArray *obj = [NSMutableArray arrayWithArray:rejectedOrders];
        NSString *order_id =     [_dict objectForKey:@"order_id"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", order_id];
        NSArray *rejectedFilteredArray = [obj filteredArrayUsingPredicate:predicate];
        
        NSArray *acceptOrders = [userDefaults objectForKey:@"acceptOrders"];
        NSMutableArray *obj2 = [NSMutableArray arrayWithArray:acceptOrders];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"order_id == %@", order_id];
        NSArray *acceptedArray = [obj2 filteredArrayUsingPredicate:predicate1];
        if (rejectedFilteredArray.count||acceptedArray.count) {
            accept.enabled = reject.enabled =NO;
            accept.alpha = reject.alpha = 0.5;
            statusBtn.hidden =NO;
          accept.hidden = reject.hidden = _disableButton;
            
        }
        if (rejectedFilteredArray.count) {
            [statusBtn setTitle:[_dict objectForKey:@"dateandtime"] forState:UIControlStateNormal];
            [statusBtn setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:48.0/255.0  blue:55.0/255.0  alpha:1.0]];
            titleLabel.text =@"----Order History----";
        }
        else if (acceptedArray.count) {
            [statusBtn setTitle:[_dict objectForKey:@"dateandtime"] forState:UIControlStateNormal];
            [statusBtn setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:155.0/255.0  blue:64.0/255.0  alpha:1.0]];
            titleLabel.text =@"----Order History----";
        }
    else {
//     titleLabel.text = @"";
    }
    
    
    if ([[_dict objectForKey:@"order_type"]integerValue] == 1) {
        tableviewheight.constant = 130;
        NSString *location = [_dict objectForKey:@"customer_address"];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:location
                     completionHandler:^(NSArray* placemarks, NSError* error){
                         if (placemarks && placemarks.count > 0) {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             MKCoordinateRegion region = self.mapView.region;
                             region.center = placemark.region.center;
                             region.span.longitudeDelta /= 8.0;
                             region.span.latitudeDelta /= 8.0;
                             [self.mapView setRegion:region animated:YES];
                             [self.mapView addAnnotation:placemark];
                         }
                     }
         ];
        _mapView.hidden =NO;
        
    }
    else {
        tableviewheight.constant = 0;
        _mapView.hidden =YES;
        
        
    }
//    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Print Order"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(flipView)];
    self.navigationItem.rightBarButtonItem = flipButton;
    self.customActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customActionSheet.delegate = self;
    
    self.customActionSheet1 = [[DDAUIActionSheet2ViewController alloc] init];
    self.customActionSheet1.delegate = self;
    
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

-(void)flipView {
    UIImage *image = [self imageWithTableView:tableview];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    NSString *fileName = [NSString stringWithFormat:@"%d.png",1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    [fileMan createFileAtPath:pdfFileName contents:imageData attributes:nil];
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = (id)self;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [pdfFileName lastPathComponent];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    pic.printInfo = printInfo;
    pic.showsPageRange = YES;
    pic.printingItem = imageData;
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    [pic presentFromBarButtonItem:flipButton animated:YES completionHandler:completionHandler];

    
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
    if ([self.titleString isEqualToString:@"Confirmed Orders"] && [[_dict objectForKey:@"order_type"]integerValue] == 1) {
        return [[_dict objectForKey:@"products"]count] + 5;
    }
    return [[_dict objectForKey:@"products"]count] + 3;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];//first get total rows in that section by current indexPath.
    
    if (indexPath.row == 0) {
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.nameLabel.text = [_dict objectForKey:@"customer_name"];
        cell.addressLabel.text = [_dict objectForKey:@"customer_address"];
        cell.orderLabel.text = [NSString stringWithFormat:@"Order #%@",[_dict objectForKey:@"order_id"]];
        
        cell.phoneLabelk.text = [NSString stringWithFormat:@"Customer Phone #: %@",[self phoneNumber:[_dict objectForKey:@"telephone"]]];
        cell.quantityLabel.text = [_dict objectForKey:@"total"];
        if ([[_dict objectForKey:@"order_type"]integerValue] == 1) {
            cell.pickupLabel.text = @"DELIVERY";
            cell.pickupLabel.backgroundColor = [UIColor colorWithRed:7/255.0 green:101/255.0 blue:15/255.0 alpha:1.0];
            cell.addressLabel.hidden =cell.address.hidden =NO;
            cell.prepTimeLabel.text = [NSString stringWithFormat:@"Requested for Deliver at %@",[_dict objectForKey:@"date_added"]];
            
            NSString *text = cell.prepTimeLabel.text;
            NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:text];
            [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:7/255.0 green:101/255.0 blue:15/255.0 alpha:1.0] range:[text rangeOfString:@"Deliver"]];
            NSString *str= [_dict objectForKey:@"date_added"];
            [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:[text rangeOfString:str]];
            cell.prepTimeLabel.attributedText = mutable;
            
        }
        else {
            cell.prepTimeLabel.text = [NSString stringWithFormat:@"Requested for Pick-up at %@",[_dict objectForKey:@"date_added"]];
            cell.pickupLabel.text = @"PICKUP";
            NSString *text = cell.prepTimeLabel.text;
            NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:text];
            [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:17/255.0 green:41/255.0 blue:132/255.0 alpha:1.0] range:[text rangeOfString:@"Pick-up"]];
            NSString *str= [_dict objectForKey:@"date_added"];
            [mutable addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:[text rangeOfString:str]];
            cell.prepTimeLabel.attributedText = mutable;
            cell.pickupLabel.backgroundColor = [UIColor colorWithRed:17/255.0 green:41/255.0 blue:132/255.0 alpha:1.0];
            
            cell.addressLabel.hidden =cell.address.hidden =YES;
            
        }
        if ([[_dict objectForKey:@"payment_status"]integerValue] == 7) {
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
    else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:11.0];
            if ([[_dict objectForKey:@"customer_comment"] length]>0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Special Instruction: %@ ",[_dict objectForKey:@"customer_comment"]];

            }
            else {
                cell.textLabel.text = [NSString stringWithFormat:@"Special Instruction:"];
            }
            [cell.textLabel boldSubstring: @"Special Instruction:"];

           
        }
        return cell;
    }
    else if(indexPath.row == totalRow -3 && ([self.titleString isEqualToString:@"Confirmed Orders"] && [[_dict objectForKey:@"order_type"]integerValue] == 1)) {
        static NSString *simpleTableIdentifier = @"DeliveryTableViewCell";
        DeliveryTableViewCell *cell = (DeliveryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DeliveryTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.delieveryCharge.text = [_dict objectForKey:@"deliver_charge"];
        cell.onlineCharge.text = [_dict objectForKey:@"handling_charge"];
        cell.totalCharge.text = [_dict objectForKey:@"total"];
        cell.taxCharge.text =  [_dict objectForKey:@"tax"];
        cell.taxLabel.text =  [NSString stringWithFormat:@"Tax %@ ",[_dict objectForKey:@"tax"]];
        cell.couponCharge.text =  [NSString stringWithFormat:@"%@",[_dict objectForKey:@"coupon"]];
        return cell;
    }
    else if(indexPath.row == totalRow -1 && ([self.titleString isEqualToString:@"Confirmed Orders"] && [[_dict objectForKey:@"order_type"]integerValue] == 1)) {
        static NSString *simpleTableIdentifier = @"PostMasterTableViewCell";
        PostMasterTableViewCell *cell = (PostMasterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostMasterTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell.trackerButton addTarget:self action:@selector(trackerButton) forControlEvents:UIControlEventTouchUpInside];

        
        return cell;
    }
    
    else if (indexPath.row == totalRow -2 && ([self.titleString isEqualToString:@"Confirmed Orders"] && [[_dict objectForKey:@"order_type"]integerValue] == 1)) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:11.0];
//            if ([[_dict objectForKey:@"customer_comment"] length]>0) {
//                cell.textLabel.text = [NSString stringWithFormat:@"Special Instruction: %@ ",[_dict objectForKey:@"customer_comment"]];
//                
//            }
//            else {
//                cell.textLabel.text = [NSString stringWithFormat:@"Special Instruction:"];
//            }
//            
            //[cell.textLabel boldSubstring: @"Special Instruction:"];
            
            
        }
        return cell;
    }
    
    else if(indexPath.row == totalRow -1) {
        static NSString *simpleTableIdentifier = @"DeliveryTableViewCell";
        DeliveryTableViewCell *cell = (DeliveryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DeliveryTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.delieveryCharge.text = [_dict objectForKey:@"deliver_charge"];
        cell.onlineCharge.text = [_dict objectForKey:@"handling_charge"];
        cell.totalCharge.text = [_dict objectForKey:@"total"];
        cell.taxCharge.text =  [_dict objectForKey:@"tax"];
        cell.taxLabel.text =  [NSString stringWithFormat:@"Tax %@ ",[_dict objectForKey:@"tax"]];
        cell.couponCharge.text =  [NSString stringWithFormat:@"%@",[_dict objectForKey:@"coupon"]];
        return cell;
    }
    
    
    else {
        static NSString *simpleTableIdentifier = @"SummaryTableViewCell";
        SummaryTableViewCell *cell = (SummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SummaryTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.produtName.text = [[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"name"];
          cell.special_instruction.text = [[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"special_instructions"];
        if ([[[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"special_instructions"] length]>0) {
            cell.special_instruction.text = [NSString stringWithFormat:@"Special Instruction: %@ ",[[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"special_instructions"]];
            [cell.special_instruction boldSubstring: @"Special Instruction:"];
        }
        else{
        cell.special_instruction.text = @"";
        }
        cell.quantityCell.text = [[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"quantity"];
        cell.priceLabel.text = [[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"total"];
        NSMutableString *mutableString =[[NSMutableString alloc]init];
        for (NSString *str  in [[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"product_options"]) {
            [mutableString appendString:@"- "];
            [mutableString appendString:str];
            [mutableString appendString:@"\n"];
            
        }
        cell.ingredients.text =  [NSString stringWithString:mutableString];
        return cell;
    }
    
}

-(void)trackerButton {
    UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSString *order_id =     [_dict objectForKey:@"order_id"];

    WebViewController * controller = (WebViewController *)[iPhoneStoryboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    controller.urlString = [NSString stringWithFormat:@"https://www.togonosh.com/dev/index.php?route=deliveries/info&order_id=%@",order_id];
    controller.titleString =@"Delivery Details";
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0){
        if ([[_dict objectForKey:@"order_type"]integerValue] == 1)
            return 197;
        else
            return 150;
    }
    else if (indexPath.row == 1){
        return 30;
    }
    
    else {
        
        if (([self.titleString isEqualToString:@"Confirmed Orders"] && [[_dict objectForKey:@"order_type"]integerValue] == 1)) {
            if ([[_dict objectForKey:@"products"]count] + 4 == (indexPath.row+1)) {
                return 20;
            }
            if ([[_dict objectForKey:@"products"]count] + 4 == (indexPath.row)) {
                return 76;
            }
        }

        NSLog(@"indexPath %ld",(long)indexPath.row);

        if ([[_dict objectForKey:@"products"] count] > (indexPath.row-2)  ) {
            NSLog(@"products %@",[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]);
   return 108 + ([[[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"product_options"] count]*20);
        }
//        if (indexPath.row <= [[_dict objectForKey:@"products"] count]) {
//             return 108 + ([[[[_dict objectForKey:@"products"]objectAtIndex:indexPath.row-2]objectForKey:@"product_options"] count]*20);
//        }
        return 150;
    }
    
    
    
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
}
- (void)didSelectReason:(NSString*)str {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *str2 = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_url"];
    NSString *order_id =     [_dict objectForKey:@"order_id"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:str2]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"res_id"],@"a",
                            [NSNumber numberWithInteger:[order_id integerValue]], @"o",
                            @"Rejected", @"ak",
                            str,@"m",
                            @"23:30", @"dt",
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_username"], @"u",
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_password"], @"p",
                            nil];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self sendMesage:@"Thanks for your response Your order has been rejected!!" title:@"Rejected"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"rejectedOrders"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_dict];

        [dictionary setObject:[self dateandtime:@"Rejected"] forKey:@"dateandtime"];
        [dictionary setObject:@"Rejected" forKey:@"orderstatus"];
        
        [statusBtn setTitle:[dictionary objectForKey:@"dateandtime"] forState:UIControlStateNormal];
        [statusBtn setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:48.0/255.0  blue:55.0/255.0  alpha:1.0]];
        titleLabel.text =@"----Order History----";
        accept.hidden = reject.hidden =  YES;
        titleLabel.hidden = statusBtn.hidden =NO;
        
        [array addObject:dictionary];
        
        NSArray *noresponse = [userDefaults objectForKey:@"noresponse"];
        NSMutableArray *obj = [NSMutableArray arrayWithArray:noresponse];
        
        
        //filter array by category using predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", order_id];
        
        NSArray *filteredArray = [obj filteredArrayUsingPredicate:predicate];
        
        [obj removeObject:[filteredArray objectAtIndex:0]];
        
        [userDefaults setObject:obj forKey:@"noresponse"];
        [userDefaults setObject:array forKey:@"rejectedOrders"];
        [userDefaults synchronize];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject                                                             options:kNilOptions
                                                               error:&error];
        
        //   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterGeoFence" object:nil];
        
        //  NSLog(@"getFenceLocation %@",json);
        NSDictionary* dictStatus = [json objectForKey:@"status"];
        BOOL success = [[dictStatus valueForKey:@"success"]boolValue];
        // NSLog(@"success %d",success);
        if(success)
        {
            if(![[dictStatus valueForKey:@"code"] isEqualToString:@"411"])
            {
                
                
                //  [self sendLatLong];
                
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        
        
    }];
    
    
}
- (void)didSelectTimings:(NSString*)str {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *str2 = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_url"];
    NSString *order_id =     [_dict objectForKey:@"order_id"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:str2]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"res_id"],@"a",
                            [NSNumber numberWithInteger:[order_id integerValue]], @"o",
                            @"Accepted", @"ak",
                            str,@"m",
                            @"23:30", @"dt",
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_username"], @"u",
                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_password"], @"p",
                            nil];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject                                                             options:kNilOptions
                                                               error:&error];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        //   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAfterGeoFence" object:nil];
        
        [self sendMesage:@"Thanks for your response Your order has been accepted!!" title:@"Accepted"];

        //  NSLog(@"getFenceLocation %@",json);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *arrayOfImages = [userDefaults objectForKey:@"acceptOrders"];
        
        NSArray *noresponse = [userDefaults objectForKey:@"noresponse"];
        NSMutableArray *obj = [NSMutableArray arrayWithArray:noresponse];
        
        
        //filter array by category using predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", order_id];
        
        NSArray *filteredArray = [obj filteredArrayUsingPredicate:predicate];
        
        for (id Obj in filteredArray) {
            [obj removeObject:Obj];
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:obj];
        NSArray *arrayWithoutDuplicates = [orderedSet array];
        [userDefaults setObject:arrayWithoutDuplicates forKey:@"noresponse"];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_dict];
        
        [dictionary setObject:[self dateandtime:@"Accepted"] forKey:@"dateandtime"];
        [dictionary setObject:@"Accepted" forKey:@"orderstatus"];

        
        [statusBtn setTitle:[dictionary objectForKey:@"dateandtime"] forState:UIControlStateNormal];
        [statusBtn setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:155.0/255.0  blue:64.0/255.0  alpha:1.0]];
        titleLabel.text =@"----Order History----";
        accept.hidden = reject.hidden =  YES;
        titleLabel.hidden = statusBtn.hidden =NO;
        
        [array addObject:dictionary];
        [userDefaults setObject:array forKey:@"acceptOrders"];
        [userDefaults synchronize];
        
        
        NSDictionary* dictStatus = [json objectForKey:@"status"];
        BOOL success = [[dictStatus valueForKey:@"success"]boolValue];
        // NSLog(@"success %d",success);
        if(success)
        {
            if(![[dictStatus valueForKey:@"code"] isEqualToString:@"411"])
            {
                
            }

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    }];
    
}

-(NSString *)dateandtime:(NSString *)status {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];  // 09:30 AM
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CST"]];
// For GMT+1
    NSString *time = [formatter stringFromDate:[NSDate date]];
    
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"dd MMMM, yyyy"];
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CST"]];
    NSString *date = [formatter1 stringFromDate:[NSDate date]];
    
    NSString *dateTime = [NSString stringWithFormat:@"Order %@ on %@ at %@ CST",status,date,time];
    return  dateTime;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willSelectRowAtIndexPath");
    if (indexPath.row == 0) {
        return nil;
    }
    
    return indexPath;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
-(void)checkVersionUpdate
{
    
    
}
- (IBAction)rejectButton:(id)sender {
    
    
    [self showCustomView2];
    //   return;
    
    //      return;
    //
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    NSArray *arrayOfImages = [userDefaults objectForKey:@"rejectedOrders"];
    //    NSMutableArray *array = [NSMutableArray arrayWithArray:arrayOfImages];
    //    [array addObject:_dict];
    //
    //    NSArray *noresponse = [userDefaults objectForKey:@"noresponse"];
    //    NSMutableArray *obj = [NSMutableArray arrayWithArray:noresponse];
    //    NSString *order_id1 =     [_dict objectForKey:@"order_id"];
    //
    //
    //    //filter array by category using predicate
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_id == %@", order_id];
    //
    //    NSArray *filteredArray = [obj filteredArrayUsingPredicate:predicate];
    //
    //    [obj removeObject:[filteredArray objectAtIndex:0]];
    //    [userDefaults setObject:obj forKey:@"noresponse"];
    //    [userDefaults setObject:array forKey:@"rejectedOrders"];
    //    [userDefaults synchronize];
    //
    //    AppDelegate *appDelegate1 = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    NSString *resturent_id = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"resturent_id"];
    //
    //    NSString *orderStatus =     [_dict objectForKey:@"Accepted"];
    //    NSString *date = @"10:30";
    //    NSString *userName = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"username"];
    //
    //    NSString *password = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"password"];
    //
    //    NSString *str1 = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_url"];
    //
    //
    //    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]
    //                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                                        timeoutInterval:120.0];
    //
    //    // Create the NSMutableData to hold the received data.
    //    // receivedData is an instance variable declared elsewhere.
    //    urlData = [NSMutableData dataWithCapacity: 0];
    //
    //
    //    [theRequest setHTTPMethod:@"POST"];
    //    //    NSString *postString = [NSString stringWithFormat:@"resturent_id=%@&username=%@&password=%@",_resturauntid.text,_userName.text,_password.text];
    //    //    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //    // create the connection with the request
    //    // and start loading the data
    //    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    //    if (theConnection)
    //    {
    //        /* initialize the buffer */
    //        //urlData = [NSMutableData data];
    //
    //        /* start the request */
    //        [theConnection start];
    //    }
    //    else
    //    {
    //        NSLog(@"Connection Failed");
    //    }
}

- (IBAction)acceptButton:(id)sender {
    
    
    [self showCustomView];
    
    
}
////
//    return;
//
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];





//    AppDelegate *appDelegate1 = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString *resturent_id = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"resturent_id"];
//    NSString *orderStatus =     [_dict objectForKey:@"Accepted"];
//    NSString *date = @"10:30";
//    NSString *userName = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"username"];
//
//    NSString *password = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"password"];
//
//    NSString *str1 = [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_url"];
//
//
//    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]
//                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                        timeoutInterval:120.0];
//
//    // Create the NSMutableData to hold the received data.
//    // receivedData is an instance variable declared elsewhere.
//    urlData = [NSMutableData dataWithCapacity: 0];
////
//    NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"res_id"],@"a",
//                            @"order_id", @"o",
//                            @"Accepted", @"ak",
//                            @"ddd",@"m",
//                            @"23:30", @"dt",
//                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_username"], @"u",
//                            [[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_password"], @"p",
//                            nil];
////    NSString *jsonRequest = [params JSONRepresentation];
//
//    [theRequest setHTTPMethod:@"POST"];
//    NSString *postString = [NSString stringWithFormat:@"a=%@&o=%@&ak=%@&m=%@&dt=%@&u=%@&p=%@",[[appDelegate.dict objectForKey:@"message"]objectForKey:@"res_id"],order_id,@"Accepted",@"ddd",@"23:30",[[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_username"],[[appDelegate.dict objectForKey:@"message"]objectForKey:@"callback_password"]];
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil]; //TODO handle error
//    [theRequest setHTTPBody:requestData];
//
//
//    // create the connection with the request
//    // and start loading the data
//    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    if (theConnection)
//    {
//        /* initialize the buffer */
//        //urlData = [NSMutableData data];
//
//        /* start the request */
//        [theConnection start];
//    }
//    else
//    {
//        NSLog(@"Connection Failed");
//    }
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *jsonParsingError = nil;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        id object = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&jsonParsingError];
        [hud removeFromSuperview];
        if (jsonParsingError) {
//            [self sendMesage:@"Thanks for your response!!" title:@"Alert"];
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
                    [tableview reloadData];
                    if (!orderArray.count) {
                        UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height/2, 300, 60)];
                        fromLabel.text =@"No Result";
                        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
                        fromLabel.backgroundColor = [UIColor clearColor];
                        fromLabel.textColor = [UIColor lightGrayColor];
                        fromLabel.textAlignment = NSTextAlignmentLeft;
                        [fromLabel setFont:[UIFont systemFontOfSize:30 weight:1.0]];
                        [self.view addSubview:fromLabel];
                        [tableview setHidden:YES];
                    }
                    else
                    {
                        if ([self.titleString isEqualToString:@"New Orders"]) {
                            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"vintage2" ofType: @"mp3"];
                            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
                            myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
                            myAudioPlayer.numberOfLoops = 2; //infinite loop
                            [myAudioPlayer play];
                            [tableview setHidden:NO];
                        }
                    }
                    
                }
                else {
                    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-75), self.view.frame.size.height/2, 300, 60)];
                    fromLabel.text =@"No Result";
                    fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
                    fromLabel.backgroundColor = [UIColor clearColor];
                    fromLabel.textColor = [UIColor lightGrayColor];
                    fromLabel.textAlignment = NSTextAlignmentLeft;
                    [fromLabel setFont:[UIFont systemFontOfSize:30 weight:1.0]];
                    [self.view addSubview:fromLabel];
                    [tableview setHidden:YES];
                    
                }
            }
        }
    });
}



- (UIImage *)imageWithTableView:(UITableView *)tableView{
    UIImage* image = nil;
    
    UIGraphicsBeginImageContextWithOptions(tableView.contentSize, NO, 0.0);
    
    CGPoint savedContentOffset = tableView.contentOffset;
    CGRect savedFrame = tableView.frame;
    
    tableView.contentOffset = CGPointZero;
    tableView.frame = CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height);
    
    [tableView.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    tableView.contentOffset = savedContentOffset;
    tableView.frame = savedFrame;
    
    UIGraphicsEndImageContext();
    return image;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
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

- (void)showCustomView {
    [self.navigationController.view addSubview:self.customActionSheet.view];
    [self.customActionSheet viewWillAppear:NO];
}




- (void)showCustomView2 {
    [self.navigationController.view addSubview:self.customActionSheet1.view];
    [self.customActionSheet1 viewWillAppear:NO];
}
@end

