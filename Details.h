//
//  Details.h
//  telstra_poc
//
//  Created by Mehak Kalra on 25/07/17.
//  Copyright © 2017 Mehak Kalra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Details : NSObject


@property (nonatomic) NSString *detailTitle;
@property (nonatomic) NSString *detailDescription;
@property (nonatomic) NSString *detailURL;
@property (nonatomic) UIImage *detailImage;
@property (nonatomic) bool downloadRequired;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
