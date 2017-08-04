//
//  telstraTableViewController.m
//  telstra_poc
//
//  Created by Mehak Kalra on 7/22/17.
//  Copyright © 2017 Mehak Kalra. All rights reserved.
//

#import "telstraTableViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+WebCache.h"
#import "telstraTableViewCell.h"
#import "Details.h"

static NSString * const cellReuseIdentifier = @"cellReuseIdentifier";
NSIndexPath *rowSelected;

@interface telstraTableViewController ()<telstraTableViewCellRefersh>

@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) NSArray *valueOfTitle;
@property (strong, nonatomic) NSArray *valueOfRows;
@property (strong, nonatomic) NSArray *detailsArray;
@end

@implementation telstraTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.detailsArray = [[NSArray alloc]init];
    
    // registering tableview cell
    [self.tableView registerClass:[telstraTableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = button;

    
    
    [self getData:^(NSError *error) {
     //   dispatch_async(dispatch_get_main_queue(), ^(void){
        if(!error){
            [self.tableView reloadData];
        }
        else if ([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Internet"
                                                                                     message:@"Please Check your  Internet connectivity"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {}];
            [alertController addAction:cancelAction];
            [self.navigationController presentViewController:alertController animated:YES completion:^{}];
            
        }
          //  });
    }];
    
}

-(void)refresh{
    [self.tableView reloadData];
}

- (void)getData:(void (^)(NSError *error))completionHandler  {
    // using afnetworking to fetch data from url
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    
  
        if(!error){
            NSString *stringToReplace = [[filePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSString *setLatinEncoding = [NSString stringWithContentsOfFile:stringToReplace encoding:NSISOLatin1StringEncoding error:&error];
            NSData *encodedData = [setLatinEncoding dataUsingEncoding:NSUTF8StringEncoding];
            
            // serializing the data after using NSJSONSerialization and storing results globally.
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:encodedData options:kNilOptions error:&error];
            self.keys = [json allKeys];
            self.valueOfTitle =  [json valueForKey:[self.keys objectAtIndex:0]];
            [self.navigationItem setTitle:[json valueForKey:@"title"]];
            self.valueOfRows = [json valueForKey:[self.keys objectAtIndex:1]];
            NSMutableArray *detailsArray = [[NSMutableArray alloc] init];
            for(NSDictionary *factDictionary in self.valueOfRows) {
                Details *details = [[Details alloc] initWithDictionary:factDictionary];
                if (details) {
                    [detailsArray addObject:details];
                    details.downloadRequired = YES;
                }
            }
            _detailsArray = detailsArray;
           // [self.tableView reloadData];
        }
        completionHandler(error);
        
    }];
    [downloadTask resume];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detailsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    telstraTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    rowSelected = indexPath;
    
    Details *detailsObj = (Details *)[self.detailsArray objectAtIndex:indexPath.row];
    cell.details=detailsObj;

    return cell;
    
}

#pragma Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Details *detail = [self.detailsArray objectAtIndex:indexPath.row];
    
    if (detail.downloadRequired || !detail.detailImage) {
        return 400.0;
    }
    else {
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21]};
        CGSize detailTitleTextSize = [detail.detailTitle sizeWithAttributes:attributes];
        CGSize detailDescriptionTextSize = [detail.detailDescription sizeWithAttributes:attributes];
        CGFloat widthOfTableView = self.tableView.frame.size.width;
        
        float heightAdjustment =  (detailTitleTextSize.width/widthOfTableView)*detailTitleTextSize.height  + (detailDescriptionTextSize.width/widthOfTableView)*detailDescriptionTextSize.height + 60.0;
        return  heightAdjustment + detail.detailImage.size.height;
    }
}

-(void)refreshCell{
    [self.tableView reloadRowsAtIndexPaths:@[rowSelected] withRowAnimation:UITableViewRowAnimationFade];
}




        
        @end
