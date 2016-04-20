//
//  ACFSearchVwController.h
//  AcronymFinder
//
//  Created by Hussain  on 19/4/16.
//  Copyright © 2016 HussainCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACFSearchVwController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,weak) IBOutlet UISearchBar *searchBText;
@property (nonatomic,weak) IBOutlet UILabel *errorLabel;
@end
