//
//  ViewController.h

//
//  Created by Lexicon on 15/02/18.
//  Copyright © 2018 Lexicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface MyCountryListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tblMapList;
    NSMutableArray *arrList;
    NSMutableData *dataReponse;
    UIActivityIndicatorView *activityView;
}



@end



