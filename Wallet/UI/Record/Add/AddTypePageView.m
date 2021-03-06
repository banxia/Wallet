//
//  AddTypePageView.m
//  Wallet
//
//  Created by 王成浩 on 2018/9/17.
//  Copyright © 2018年 evan. All rights reserved.
//

#import "AddTypePageView.h"
#import "AddTypePageViewCell.h"
#import "TypeManagerViewController.h"

@interface AddTypePageView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddTypePageViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) RecordType type;
@property (nonatomic, strong) RecordWithTypeModel *record;

@end

@implementation AddTypePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configView];
    }
    return self;
}

- (void)configView {
    WS(ws);
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
    [self addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws);
        make.centerX.mas_equalTo(ws);
        make.height.mas_equalTo(10);
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[AddTypePageViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (void)addRecord:(RecordWithTypeModel *)record withType:(RecordType)type {
    self.type = type;
    self.dataArray = [NSMutableArray array];
    for (RecordTypeModel *model in [RecordTypeDao getAllRecordTypes]) {
        if (model.type == type) {
            [self.dataArray addObject:model];
        }
    }
    if (self.dataArray.count > 0) {
        RecordTypeModel *setting = [RecordTypeModel new];
        setting.name = NSLocalizedString(@"text_setting", nil);
        setting.img_name = @"type_item_setting";
        setting.type = self.type;
        setting.setting = YES;
        [self.dataArray addObject:setting];
    }
    self.record = record;
    if (self.checkID == nil) {//第一次进入
        if (self.record != nil && self.record.recordTypes[0].type == self.type) {//更新
            BOOL exist = NO;
            for (RecordTypeModel *rt in self.dataArray) {
                if ([record.recordTypes[0].ID integerValue] == [rt.ID integerValue]) {
                    self.checkID = rt.ID;
                    exist = YES;
                    break;
                }
            }
            if (!exist) {
                RecordTypeModel *rm = [self.dataArray objectAtIndex:0];
                self.checkID = rm.ID;
                [self showHUDInView:self.viewForLastBaselineLayout justWithText:NSLocalizedString(@"text_tip_type_delete", nil) disMissAfterDelay:2];
            }
        } else {
            RecordTypeModel *rm = [self.dataArray objectAtIndex:0];
            self.checkID = rm.ID;
        }
    }
    
    for (RecordTypeModel *r in self.dataArray) {
        if ([r.ID integerValue] == [self.checkID integerValue]) {
            r.checked = YES;
        } else {
            r.checked = NO;
        }
    }
    
    _sourceArray = nil;
    [self.collectionView reloadData];
}

- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (RecordTypeModel *model in self.dataArray) {
            if (self.checkID && ([self.checkID integerValue] == [model.ID integerValue])) {
                model.checked = YES;
            } else {
                model.checked = NO;
            }
            [tmpArray addObject:model];
            if (tmpArray.count == 8) {
                [_sourceArray addObject:tmpArray];
                tmpArray = [NSMutableArray array];
            }
        }
        if (tmpArray.count > 0) {
            [_sourceArray addObject:tmpArray];
        }
        self.pageControl.numberOfPages = _sourceArray.count;
    }
    return _sourceArray;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddTypePageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.dataArray = [self.sourceArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - AddTypePageViewCellDelegate

- (void)didSelectItemModel:(RecordTypeModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if (model.isSetting) {
        TypeManagerViewController *tvc = [TypeManagerViewController new];
        [((UINavigationController *)[[UIApplication sharedApplication].keyWindow rootViewController]) pushViewController:tvc animated:YES];
    } else {
        self.checkID = model.ID;
        _sourceArray = nil;
        [self.collectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}
@end

