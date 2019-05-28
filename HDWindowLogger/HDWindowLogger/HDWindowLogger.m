//
//  HDWindowLogger.m
//  HDWindowLogger
//
//  Created by Damon on 2019/5/28.
//  Copyright © 2019 Damon. All rights reserved.
//

#import "HDWindowLogger.h"
#import "HDLoggerTableViewCell.h"


@implementation HDWindowLoggerItem
@end

#pragma mark -
#pragma mark - HDWindowLogger
@interface HDWindowLogger () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *mLogDataArray;
@property (strong, nonatomic) UIView *mBGView;
@property (strong, nonatomic) UITableView *mTableView;
@property (strong, nonatomic) UIButton *mCleanButton;
@property (strong, nonatomic) UIButton *mHideButton;
@property (strong, nonatomic) UIButton *mFloatButton;

@end

@implementation HDWindowLogger

#pragma mark -
#pragma mark - init Method
+ (HDWindowLogger *)defaultWindowLogger {
    static HDWindowLogger *defaultLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLogger = [[HDWindowLogger alloc] init];
    });
    return defaultLogger;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
    if (self) {
        [self p_createUI];
        [self p_bindClick];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Method
- (void)p_createUI {
    self.rootViewController = [UIViewController new]; // suppress warning
    self.windowLevel = UIWindowLevelAlert;
    [self setBackgroundColor:[UIColor clearColor]];
    self.userInteractionEnabled = YES;
    
    ///添加主视图
    [self.rootViewController.view  addSubview:self.mBGView];
    [self.mBGView setFrame:self.bounds];
    
    //按钮
    [self.mBGView addSubview:self.mHideButton];
    [self.mHideButton setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2.0, 40)];
    [self.mBGView addSubview:self.mCleanButton];
    [self.mCleanButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0, 0, [UIScreen mainScreen].bounds.size.width/2.0, 40)];
    
    //主视图
    [self.mBGView addSubview:self.mTableView];
    [self.mTableView setFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 300 - 40)];
    
    ///添加悬浮按钮
    [self.rootViewController.view addSubview:self.mFloatButton];
    [self.mFloatButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70, 10, 60, 60)];
    
}

- (void)p_bindClick {
    [self.mHideButton addTarget:self action:@selector(hideLogWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.mCleanButton addTarget:self action:@selector(cleanLog) forControlEvents:UIControlEventTouchUpInside];
    [self.mFloatButton addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
}


- (void)hideLogWindow {
    [HDWindowLogger hideLogWindow];
}

- (void)cleanLog {
    [HDWindowLogger cleanLog];
}
- (void)show {
    [HDWindowLogger show];
}
#pragma mark -
#pragma mark - Public Method

/**
 根据日志的输出类型去输出相应的日志，不同日志类型颜色不一样
 
 @param log 日志内容
 @param logType 日志类型
 */
+ (void)printLog:(id)log withLogType:(HDLogType)logType {
    HDWindowLoggerItem *item = [[HDWindowLoggerItem alloc] init];
    item.mLogItemType = logType;
    item.mLogContent = [NSString stringWithFormat:@"%@",log];
    [[self defaultWindowLogger].mLogDataArray addObject:item];
    [[self defaultWindowLogger].mTableView reloadData];
}

/**
 删除log日志
 */
+ (void)cleanLog {
    [[self defaultWindowLogger].mLogDataArray removeAllObjects];
    [[self defaultWindowLogger].mTableView reloadData];
}

/**
 显示log窗口
 */
+ (void)show {
    [self defaultWindowLogger].hidden = NO;
    [self defaultWindowLogger].mBGView.hidden = NO;
    [self defaultWindowLogger].mFloatButton.hidden = YES;
}


/**
 隐藏整个log窗口
 */
+ (void)hide {
    [self defaultWindowLogger].hidden = YES;
    [self defaultWindowLogger].mBGView.hidden = YES;
    [self defaultWindowLogger].mFloatButton.hidden = YES;
}


/**
 只隐藏log的输出窗口，保留悬浮图标
 */
+ (void)hideLogWindow {
    [self defaultWindowLogger].mBGView.hidden = YES;
    [self defaultWindowLogger].mFloatButton.hidden = NO;
}

#pragma mark -
#pragma mark - Lazyload
- (NSMutableArray *)mLogDataArray {
    if (!_mLogDataArray) {
        _mLogDataArray = [NSMutableArray array];
    }
    return _mLogDataArray;
}

- (UIView *)mBGView {
    if (!_mBGView) {
        _mBGView = [[UIView alloc] init];
        [_mBGView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    }
    return _mBGView;
}

- (UITableView *)mTableView {
    if (!_mTableView) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mTableView.scrollsToTop = YES;
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
        _mTableView.showsHorizontalScrollIndicator = NO;
        _mTableView.showsVerticalScrollIndicator = YES;
        _mTableView.backgroundColor = [UIColor clearColor];
        _mTableView.separatorColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:240.0/255.0 alpha:1.0];
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _mTableView;
}

- (UIButton *)mCleanButton {
    if (!_mCleanButton) {
        _mCleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mCleanButton setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0]];
        [_mCleanButton setTitle:@"Clean Log" forState:UIControlStateNormal];
    }
    return _mCleanButton;
}

- (UIButton *)mHideButton {
    if (!_mHideButton) {
        _mHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mHideButton setBackgroundColor:[UIColor colorWithRed:93.0/255.0 green:174.0/255.0 blue:139.0/255.0 alpha:1.0]];
        [_mHideButton setTitle:@"Hide" forState:UIControlStateNormal];
    }
    return _mHideButton;
}

- (UIButton *)mFloatButton {
    if (!_mFloatButton) {
        _mFloatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mFloatButton setBackgroundColor:[UIColor colorWithRed:93.0/255.0 green:174.0/255.0 blue:139.0/255.0 alpha:1.0]];
        [_mFloatButton setTitle:@"H" forState:UIControlStateNormal];
        [_mFloatButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
        _mFloatButton.layer.masksToBounds = YES;
        _mFloatButton.layer.cornerRadius = 30.0f;
        _mFloatButton.hidden = YES;
        
    }
    return _mFloatButton;
}


#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mLogDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"loggerCellIdentifier";
    HDWindowLoggerItem *item = [self.mLogDataArray objectAtIndex:indexPath.row];
    
    HDLoggerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[HDLoggerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updateWithLoggerItem:item];
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDWindowLoggerItem *item = [self.mLogDataArray objectAtIndex:indexPath.row];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    CGSize size = [item.mLogContent boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:style} context:nil].size;
    return ceil(size.height) + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}
@end