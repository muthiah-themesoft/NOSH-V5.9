//
//  WebViewController.m
//  Nosh
//
//  Created by Themesoft on 6/8/16.
//  Copyright © 2016 Themesoft. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"

@interface WebViewController () {
    
    __weak IBOutlet UIWebView *webView;
    
}
@property  MBProgressHUD *hud ;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.titleString isEqualToString:@"NOSH Support"]) {
        SWRevealViewController *revealController = [self revealViewController];
        
        [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                             style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;

    }
   
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:self.urlString]];

    self.title =self.titleString;
    [webView loadRequest: request];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading";
    webView.delegate = (id)self;
    
    [webView addSubview:_hud];
    [_hud hide:YES];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor =  [UIColor colorWithRed:110/255.0 green:94/255.0 blue:127/255.0 alpha:1.0];
    //    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden =NO;
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden =NO;
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden =YES;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [_hud show:YES];
    return YES;
}

- (void)webViewDidFinishLoading:(UIWebView *)wv
{
    [_hud removeFromSuperview];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [_hud removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
