//
//  SummaryTableViewCell.h
//  Nosh
//
//  Created by Muthiah Kumarasamy on 11/07/16.
//  Copyright © 2016 Themesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *quantityCell;
@property (weak, nonatomic) IBOutlet UILabel *produtName;
@property (weak, nonatomic) IBOutlet UILabel *ingredients;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *special_instruction;

@end
