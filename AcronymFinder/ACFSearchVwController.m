//
//  ACFSearchVwController.m
//  AcronymFinder
//
//  Created by Hussain  on 19/4/16.
//  Copyright © 2016 HussainCode. All rights reserved.
//

#import "ACFSearchVwController.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"

static NSString * const BaseURLString = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";
@interface ACFSearchVwController ()
@property (nonatomic,strong) NSMutableArray *longFormMutList;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@end

@implementation ACFSearchVwController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBProgressHUD *hud = [[MBProgressHUD alloc]init];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [self.view addSubview:hud];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [self.view addSubview:self.errorLabel];
    [self.errorLabel setHidden:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *searchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length > 0){
        [self loadData:searchText];
    }
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length == 0){
        if (self.longFormMutList && self.longFormMutList.count > 0){
            [self.longFormMutList removeAllObjects];
            [self reloadTableViewData];
        }
    }
}


-(void)loadData:(NSString*)acronymName
{
    @try
    {
        [self startProgressIndicator];
        NSString *url = [NSString stringWithFormat:@"%@?sf=%@",BaseURLString,acronymName];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                 options:kNilOptions
                                                                   error:&error];
            self.longFormMutList = [NSMutableArray array];
                NSArray *longFormList = [json valueForKey:@"lfs"];
                id variations = [[longFormList valueForKey:@"vars"]valueForKey:@"lf"];
                if (variations && [variations count] > 0){
                for (id longFormArr in variations[0])
                {
                    for (NSUInteger i = 0; i < [longFormArr count]; i++)
                    {
                        [self.longFormMutList addObject:longFormArr[i]];
                    }
                }
                [self.longFormMutList addObjectsFromArray:longFormList[0]];
            }
            [self reloadTableViewData];
            if (self.longFormMutList.count == 0){
              [self.errorLabel setHidden:NO];
            }
            else{
                [self.errorLabel setHidden:YES];
            }
            [self.searchBText resignFirstResponder];
            [self stopProgressIndicator];
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            NSInteger statusCode = response.statusCode;
            NSLog(@"Failure Block=%ld",statusCode);
            [self stopProgressIndicator];
        }];
    }
  @catch (NSException *exception) {
      NSLog(@"Exception=%@",exception.reason);
      [self stopProgressIndicator];
}
}


-(void)startProgressIndicator{
    if (![NSThread isMainThread]){
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    }
    else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)stopProgressIndicator{
    if (![NSThread isMainThread]){
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    }
    else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

-(void)reloadTableViewData{
    if (![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    else{
        [self.tableView reloadData];
    }
}

-(IBAction)dismissVwController:(id)sender{
    [self.searchBText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.longFormMutList.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    @try {
        NSString *fullFormText = self.longFormMutList[indexPath.row];
        if ([fullFormText isKindOfClass:[NSString class]]){
        cell.textLabel.text = fullFormText;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception=%@",exception.reason);
    }
    return cell;
}

@end
