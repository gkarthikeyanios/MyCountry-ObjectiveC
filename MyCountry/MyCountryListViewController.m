//

//  MyCountry
//
//  Created by Lexicon on 15/02/18.
//  Copyright © 2018 Lexicon. All rights reserved.
//

#import "MyCountryListViewController.h"
#import "MyCountryListTableViewCell.h"


@interface MyCountryListViewController ()

@end

@implementation MyCountryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self createControls];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setCenter:CGPointMake(self.view.frame.size.width /2, self.view.frame.size.height / 2)];
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    
    NSLayoutConstraint *Height = [NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:50];
    
    NSLayoutConstraint *Width = [NSLayoutConstraint constraintWithItem:activityView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:50];
    
    [self.view addConstraints:@[Width, Height]];
    
    [self callWebService];
}

//MARK:local methods

-(void)refreshData
{
    
}

-(void)createControls
{
    tblMapList = [[UITableView alloc]init];
    tblMapList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblMapList.delegate = self;
    tblMapList.dataSource = self;
    tblMapList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tblMapList];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [tblMapList addSubview:refreshControl];
   
    
   
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:tblMapList attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:tblMapList attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:tblMapList attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:tblMapList attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[trailing, leading, top, bottom]];
    
}

-(void)callWebService
{
    arrList = [[NSMutableArray alloc]init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    dataReponse = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [dataReponse appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSString *strResponse = [[NSString alloc] initWithData:dataReponse encoding:NSMacOSRomanStringEncoding];

    NSData *data = [strResponse dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err = nil;
    NSDictionary *dicResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];

    arrList = [dicResult objectForKey:@"rows"];
    self.navigationItem.title = [dicResult objectForKey:@"title"];
    
    [activityView stopAnimating];
    
    [tblMapList reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    [activityView stopAnimating];
}

#pragma mark - local Methods
-(float) getHeightForText:(NSString*) text withFont:(UIFont*) font andWidth:(float) width{
    CGSize constraint = CGSizeMake(width , 20000.0f);
    CGSize title_size;
    float totalHeight;
    
    SEL selector = @selector(boundingRectWithSize:options:attributes:context:);
    if ([text respondsToSelector:selector]) {
        title_size = [text boundingRectWithSize:constraint
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : font }
                                        context:nil].size;
        
        totalHeight = ceil(title_size.height);
    } else {
        title_size = [text sizeWithFont:font
                      constrainedToSize:constraint
                          lineBreakMode:NSLineBreakByWordWrapping];
        totalHeight = title_size.height ;
    }
    
    CGFloat height = MAX(totalHeight, 40.0f);
    return height;
}


#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    
    NSDictionary *dicList = [arrList objectAtIndex:indexPath.row];
    NSString *strDescription =  [dicList objectForKey:@"description"];
    
    if ([strDescription isKindOfClass:[NSString class]])
    {
        height = [self getHeightForText:strDescription withFont:[UIFont systemFontOfSize:12.0] andWidth:tblMapList.frame.size.width];
        if(height < 10)
        {
            height = 150;
        }
        else if(height < 20)
        {
            height = 160 + height;
        }
        else
        {
            height = 170 + height;
        }
        
        
        return height;
    }
    else
    {
        return 150;
    }
    
   
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    MyCountryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CGFloat height = 50;
    
    NSDictionary *dicList = [arrList objectAtIndex:indexPath.row];
    NSString *strDescription =  [dicList objectForKey:@"description"];
    
    if ([strDescription isKindOfClass:[NSString class]])
    {
        height = [self getHeightForText:strDescription withFont:[UIFont systemFontOfSize:12.0] andWidth:tblMapList.frame.size.width];
        if(height < 10)
        {
            height = 50;
        }
        else
        {
            height = height + 60;
        }
        
    }

    
    if (cell == nil) {
        cell = [[MyCountryListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withLabelHeight:height];
     }
    
  
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSString *strImgURL =  [dicList objectForKey:@"imageHref"];
    

    if ([strImgURL isKindOfClass:[NSString class]])
    {
        cell.imgImageView.tag = indexPath.row;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // Download or get images here
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImgURL]];
            UIImage *cellImage = [[UIImage alloc] initWithData:imageData];

            // Use main thread to update the view. View changes are always handled through main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // Refresh image view here
                [cell.imgImageView setImage:cellImage];
                [cell setNeedsLayout];
            });
        });
    }
    
    if ([strDescription isKindOfClass:[NSString class]])
    {
        cell.lblDescription.text = strDescription;
    }
   
    NSString *strTitle =  [dicList objectForKey:@"title"];
    if ([strTitle isKindOfClass:[NSString class]])
    {
        cell.lblTitle.text = strTitle;
    }
    

    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
