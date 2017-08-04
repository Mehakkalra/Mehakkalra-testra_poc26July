//
//  telstraTableViewCell.h
//  telstra_poc
//
//  Created by Mehak Kalra on 25/07/17.
//  Copyright © 2017 Mehak Kalra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Details.h"

@protocol telstraTableViewCellRefersh <NSObject>

-(void)refreshCell;

@end

@interface telstraTableViewCell : UITableViewCell
@property(nonatomic,strong) UIImageView *imageInView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic, strong) Details *details;
@property (weak) id <telstraTableViewCellRefersh> delegate;

@end
