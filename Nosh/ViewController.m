//
//  ViewController.m
//  Nosh
//
//  Created by Themesoft on 5/25/16.
//  Copyright © 2016 Themesoft. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "WebViewController.h"
#import "SimpleTableViewController.h"
#import "RearViewController.h"
#import "SWRevealViewController.h"
#import "RightViewController.h"
#import "AppDelegate.h"

@interface ViewController () <SWRevealViewControllerDelegate> {
     NSMutableData *urlData;
    MBProgressHUD *hud;
}
- (IBAction)loginAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *resturauntid;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation ViewController

- (IBAction)forGotPassword:(UIButton *)sender {
    WebViewController * controller = (WebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    controller.urlString = @"https://www.togonosh.com/demo/admin/index.php?route=common/forgotten";
    controller.titleString =@"Forgot Password";
    
}
- (IBAction)signUp:(UIButton *)sender {
    WebViewController * controller = (WebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    
    [self.navigationController pushViewController:controller animated:YES];
    controller.urlString = @"https://www.togonosh.com/restaurant-owners/#/partner-with-us";
    controller.titleString =@"Registration";
}

-(void)checkVersionUpdate
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.togonosh.com/api/v1/login"]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:120.0];
    
    // Create the NSMutableData to hold the received data.
    // receivedData is an instance variable declared elsewhere.
    urlData = [NSMutableData dataWithCapacity: 0];
    
    
    [theRequest setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"resturent_id=%@&username=%@&password=%@",_resturauntid.text,_userName.text,_password.text];
    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
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

            SimpleTableViewController *simple  = [[SimpleTableViewController alloc] initWithNibName:@"SimpleTableViewController" bundle:nil];
            simple.dict = (NSDictionary *)object;
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.dict = (NSDictionary *)object;
            simple.titleString =@"New Orders";
            RearViewController *rearViewController = [[RearViewController alloc] init];
            rearViewController.dict = (NSDictionary *)object;

            UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:simple];
            UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
            
            SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
            revealController.delegate = self;
            
            
            RightViewController *rightViewController = rightViewController = [[RightViewController alloc] init];
            rightViewController.view.backgroundColor = [UIColor greenColor];
            
            revealController.rightViewController = rightViewController;
            
            //revealController.bounceBackOnOverdraw=NO;
            //revealController.stableDragOnOverdraw=YES;
            
            [self presentViewController:revealController animated:YES completion:nil];

            //[self sendMesage:@"Logged In successfully!!" title:@"Success!"];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    _userName.text = @"mezze";
//    _resturauntid.text =@"demo";
//    _password.text = @"mezze*#123";
    
    
    _userName.text = @"devuser";
    _resturauntid.text =@"dev";
    _password.text = @"devuser";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(UIButton *)sender {
    

    
    
    if (_resturauntid.text.length && _userName.text.length && _password.text.length) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        [self checkVersionUpdate];
    }
    else {
    [self sendMesage:@"Please enter the mandatory fields" title:@"Error!"];
}
    
    
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
