//
//  CPLogListViewController.m
//  11st
//
//  Created by 김응학 on 2015. 8. 5..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPLogListViewController.h"
#import "CPCommonInfo.h"

@interface CPLogListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITextField *_searchField;
    UITableView *_tableView;
    
    NSMutableArray *_listArray;
    
}

@end

@implementation CPLogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
 
    [self getLogList:@""];
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"안  내"
                                                        message:@"앱스토어 버전은 개발자-와이즈로그를 실행 후 목록이 생성됩니다."
                                                       delegate:nil
                                              cancelButtonTitle:@"확인"
                                              otherButtonTitles:nil, nil];
    [alertview show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubviews
{
    int devY = 0;
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)	devY = 20;
    else															devY = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, devY)];
        blackView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blackView];
    }
    
    //상단 네비
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, devY, self.view.frame.size.width, 44)];
    naviView.backgroundColor = UIColorFromRGB(0x545454);
    [self.view addSubview:naviView];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(self.view.frame.size.width-60, 2, 55, 40);
    [closeBtn setTitle:@"닫기" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onClickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:closeBtn];
    
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(closeBtn.frame.origin.x-60, 2, 55, 40);
    [searchBtn setTitle:@"검색" forState:UIControlStateNormal];
    [searchBtn setTitleColor:UIColorFromRGB(0xff0000) forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(onClickSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:searchBtn];

    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, searchBtn.frame.origin.x-15, 34)];
    _searchField.backgroundColor = UIColorFromRGB(0xffffff);
    _searchField.layer.borderColor = UIColorFromRGB(0x545454).CGColor;
    _searchField.layer.borderWidth = 1;
    [naviView addSubview:_searchField];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(naviView.frame), self.view.frame.size.width,
                                                               self.view.frame.size.height-CGRectGetMaxY(naviView.frame))];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
}

- (void)getLogList:(NSString *)filter
{
    NSMutableArray *dataArray = [[[CPCommonInfo sharedInfo] logDataArray] mutableCopy];
    
    if (!nilCheck(filter)) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSInteger i=0; i<[dataArray count]; i++)
        {
            NSString *item = dataArray[i];
            
            if ([[item lowercaseString] isEqualToString:[filter lowercaseString]]) {
                [tempArr addObject:item];
            }
            
            _listArray = [[NSMutableArray alloc] initWithArray:tempArr];
        }
    }
    else {
        _listArray = [[NSMutableArray alloc] initWithArray:dataArray];
    }
}

- (void)onClickCloseBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)onClickSearchBtn:(id)sender
{
    [self getLogList:[_searchField.text trim]];
    [_tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"twoTabCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = _listArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}


@end
