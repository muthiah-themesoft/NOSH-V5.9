//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *prepTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabelk;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidLabel;
@property (weak, nonatomic) IBOutlet UILabel *address;
@end
