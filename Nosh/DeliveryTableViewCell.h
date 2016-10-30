//
//  DeliveryTableViewCell.h
//  Nosh
//
//  Created by Muthiah Kumarasamy on 11/07/16.
//  Copyright © 2016 Themesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeliveryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *delieveryCharge;
@property (weak, nonatomic) IBOutlet UILabel *onlineCharge;
@property (weak, nonatomic) IBOutlet UILabel *taxCharge;
@property (weak, nonatomic) IBOutlet UILabel *totalCharge;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponCharge;
@end
