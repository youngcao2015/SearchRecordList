//
//  ViewController.m
//  标签不确定行和列-仿天猫最近搜索记录
//
//  Created by young on 16/7/7.
//  Copyright © 2016年 young. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "NSString+Extension.h"

#import <objc/runtime.h>

#define Lazy(object, assignment) (object = object ? : assignment)

@interface ViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/** 搜索标签父视图 */
@property (nonatomic, weak) UIView *latestSearchTagView;

/** 搜索历史整体内容视图 */
@property(nonatomic, weak) UIView *contentView;

/** 整个搜索视图的背景视图 */
@property(nonatomic, weak) UIImageView *backgroundView;
@end


static NSString *const kSearchTextArraySorted = @"kSearchTextArraySorted";
static NSUInteger const kLastestSearchTextNumber = 20;
static CGFloat const kButtonMargin = 15;
static CGFloat const kButtonHeight = 30;

#pragma mark -
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)saveSearchText:(NSString *)searchText
{
    //添加数据，最近搜索数据放在最前面
    NSMutableArray *searchTextArr = @[].mutableCopy;
#if DEBUG
    [searchTextArr addObject:searchText];
#else
    ![text isContainChinese] ? : [searchTextArr addObject:searchText];
#endif
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchTextArraySorted];
    [searchTextArr addObjectsFromArray:arr];
    
    //对数据去重（保持数据的原顺序并把后面的重复数据删除）
    NSMutableArray *unrepeatedArr = @[].mutableCopy;
    for (NSString *str in searchTextArr) {
        if (![unrepeatedArr containsObject:str]) {
            [unrepeatedArr addObject:str];
        }
    }
    
    //指定数据的数量(标签个数20个)
    if (unrepeatedArr.count > kLastestSearchTextNumber) {
        NSAssert(unrepeatedArr.count < kLastestSearchTextNumber+2, @"最近搜索数据数组数量大于%lu", kLastestSearchTextNumber+1);
        [unrepeatedArr removeObjectAtIndex:unrepeatedArr.count-1];
    }
    
    //保存数据到本地
    [[NSUserDefaults standardUserDefaults] setObject:unrepeatedArr forKey:kSearchTextArraySorted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //保存搜索数据
    [self saveSearchText:searchBar.text];
    
    //搜索
    [self search];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    Lazy(_backgroundView, [self setupLatestSearchEntireView]);
    
    return YES;
}


#pragma mark - setup search view

- (UIImageView *)setupLatestSearchEntireView
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImageView *backgroundView = ({
        UIImageView *view = [UIImageView new];
        view.frame = CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), screenWidth, screenHeight);
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackgroudView)]];
        [self.view addSubview:view];
        view;
    });
    self.backgroundView = backgroundView;
    
    UIView *contentView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.x = 0;
        view.y = 0;
        view.width = screenWidth;
        [backgroundView addSubview:view];
        view;
    });
    self.contentView = contentView;
    
    UIView *latestSearchTopView = ({
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, 0, screenWidth, kButtonHeight);
        [contentView addSubview:view];
        view;
    });
    
    ({
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        iconBtn.size = CGSizeMake(90, 25);
        iconBtn.center = CGPointMake(0.5*iconBtn.width + 10, 0.5*latestSearchTopView.height);
        iconBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        iconBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [iconBtn setImage:[UIImage imageNamed:@"search_normal"] forState:UIControlStateNormal];
        [iconBtn setTitle:@"最近搜索" forState:UIControlStateNormal];
        [iconBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        iconBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [latestSearchTopView addSubview:iconBtn];
    });

    ({
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearBtn.frame = CGRectMake(screenWidth - 10 - kButtonHeight, 0, kButtonHeight, kButtonHeight);
        [clearBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(delegateLatestSearchData) forControlEvents:UIControlEventTouchUpInside];
        [latestSearchTopView addSubview:clearBtn];
    });
    
    NSArray *latestArr = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchTextArraySorted];
    
    UIView *latestSearchTagView = ({
        UIView *view = [UIView new];
        view.x = 0;
        view.y = CGRectGetMaxY(latestSearchTopView.frame);
        view.width = screenWidth;
        view.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:view];
        view;
    });
    self.latestSearchTagView = latestSearchTagView;
    
    CGFloat buttonHeight = kButtonHeight;//标签高度
    CGFloat rowSpacing = 10;//标签行间距
    NSUInteger column = 0;//列数
    NSUInteger row = 0;//行数
    for (NSUInteger i = 0; i < latestArr.count; i++) {
        UIButton *button = [UIButton new];
        //属性设置
        [button setTitle:latestArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 0.5f;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        [self.latestSearchTagView addSubview:button];
        //手势处理
        button.tag = i + 100;
        [button addTarget:self action:@selector(searchForLatestData:) forControlEvents:UIControlEventTouchUpInside];
        
        /** frame设置 */
        CGFloat sumRowWidth = 0; //单行标签所占的行宽度
        sumRowWidth += 2 * kButtonMargin;
        sumRowWidth += column * rowSpacing;
        for (NSUInteger k = i-column; k <= i; k++) {
            CGFloat textWidth = [latestArr[k] textWidth];//每条标签文本的宽度
            CGFloat textShowWidth = screenWidth - 2*kButtonMargin;//文本可显示总宽度
            if (textWidth > textShowWidth) {
                textWidth = textShowWidth;
            }
            sumRowWidth += textWidth;
        }
        
        //标签所占的行宽度大于屏幕宽度时：换行，列初始化，行宽度初始化
        if (sumRowWidth > screenWidth) {
            sumRowWidth = 0;
            row ++;
            column = 0;
        }
        
        //设置坐标x
        CGFloat sumColumnsSectionalWidth = 0;
        for (NSUInteger j = 0; j < column; j++) {
            NSString *text = latestArr[i-j-1];
            CGFloat textWidth = [text textWidth];
            sumColumnsSectionalWidth += textWidth;
        }
        CGFloat x = kButtonMargin + column*rowSpacing + sumColumnsSectionalWidth;
        //设置坐标y
        CGFloat y = kButtonMargin + row*(rowSpacing + buttonHeight);
        //标签宽度
        CGFloat buttonWidth = [latestArr[i] textWidth];
        if (buttonWidth >= (screenWidth - 2*kButtonMargin)) {
            buttonWidth = screenWidth - 2*kButtonMargin;
        }
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
        
        if (i == latestArr.count-1) {
            self.latestSearchTagView.height = CGRectGetMaxY(button.frame) + 2*kButtonMargin;
            contentView.height = self.latestSearchTagView.height + latestSearchTopView.height;
        }
        
        column ++;//所有数据用完column后自增1，进入下次循环时用
    }
    
    if (!latestArr.count) {
        [self setupNonrecordsHint];
    }
    
    return backgroundView;
}

- (void)removeBackgroudView
{
    [_backgroundView removeFromSuperview];
    [_searchBar endEditing:YES];
}

/*!
 * @brief 删除搜索历史(数据和标签)
 */
- (void)delegateLatestSearchData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSearchTextArraySorted];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (UIButton *button in self.latestSearchTagView.subviews) {
        [button removeFromSuperview];
    }
    
    [self setupNonrecordsHint];
}

/*!
 * @brief 无搜索历史提示
 */
- (void)setupNonrecordsHint
{
    //父视图的高度设置
    self.latestSearchTagView.height = 2*kButtonMargin;
    self.contentView.height = self.latestSearchTagView.height;
    
    //添加提示文字
    UILabel *nonrecordsLabel = [UILabel new];
    nonrecordsLabel.frame = self.latestSearchTagView.bounds;
    nonrecordsLabel.text = @"没有搜索记录";
    nonrecordsLabel.font = [UIFont systemFontOfSize:15];
    nonrecordsLabel.textColor = [UIColor grayColor];
    nonrecordsLabel.textAlignment = NSTextAlignmentCenter;
    [self.latestSearchTagView addSubview:nonrecordsLabel];
}

/*!
 * @brief 搜索，使用搜索历史
 * @param button 历史搜索标签
 */
- (void)searchForLatestData:(UIButton *)button
{
    NSArray *latestArr = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchTextArraySorted];
    NSUInteger tag = button.tag - 100;
    NSString *searchtext = latestArr[tag];
    NSLog(@"搜索数据为：%@", searchtext);
    
    [self removeBackgroudView];
}

/*!
 * @brief 搜索
 */
- (void)search
{
    NSArray *lastestArr = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchTextArraySorted];
    NSString *searchtext = [lastestArr firstObject];
    NSLog(@"搜索数据为：%@", searchtext);
    
    [self removeBackgroudView];
}

@end
