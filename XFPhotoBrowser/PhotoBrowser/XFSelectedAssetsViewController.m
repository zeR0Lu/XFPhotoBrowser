//
//  XFSelectedAssetsView.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFSelectedAssetsViewController.h"
#import "XFAssetsModel.h"
#import "XFSelectedAssetsCollectionViewCell.h"
#import "XFPreviewViewController.h"
#import "SDAutoLayout.h"

static NSString *identifier = @"XFSelectedAssetsCollectionViewCell";

@interface XFSelectedAssetsViewController ()
@property (strong, nonatomic) UICollectionView *collectedView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIView *collectionContainer;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation XFSelectedAssetsViewController

+ (instancetype)makeView {
    XFSelectedAssetsViewController *selectedAssetsViewController = [[XFSelectedAssetsViewController alloc] initWithNibName:@"XFSelectedAssetsViewController" bundle:nil];
    return selectedAssetsViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.confirmButton.titleLabel.numberOfLines = 0;
}

- (void)setMaxPhotosNumber:(NSInteger)maxPhotosNumber {
    _maxPhotosNumber = maxPhotosNumber;
    
    self.numberLabel.text = [NSString stringWithFormat:@"0/%ld",(long)maxPhotosNumber];
}

- (void)removeData {
    [self.dataArray removeAllObjects];
    [self.collectedView reloadData];
}

#pragma mark - 确定按钮事件
- (IBAction)didConfirmButtonAction:(UIButton *)sender {
    if ( self.confirmBlock ) {
        self.confirmBlock();
    }
}

- (void)addModelWithData:(NSArray<XFAssetsModel *> *)data {
    XFWeakSelf;
    
//    [self.dataArray removeAllObjects];
//    [self.dataArray addObjectsFromArray:data];
//    [self.collectedView reloadData];
//    [self setupButtonTitle];
    [self.collectedView performBatchUpdates:^{
        NSMutableArray *tempArray = [NSMutableArray array];
        for ( int i = 0; i < data.count ; i++ ) {
            [tempArray addObject:[NSIndexPath indexPathForItem:wself.dataArray.count + i inSection:0]];
        }
        [wself.dataArray addObjectsFromArray:data];
        [wself.collectedView insertItemsAtIndexPaths:[tempArray copy]];
    } completion:^(BOOL finished) {
        [wself.collectedView reloadData];
        if ( wself.dataArray.count ) {
            [wself.collectedView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:wself.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        [wself setupButtonTitle];
    }];
}

- (void)deleteModelWithData:(NSArray<XFAssetsModel *> *)data {
    XFWeakSelf;
    [self.collectedView performBatchUpdates:^{
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *tempData = [self.dataArray copy];
        for ( XFAssetsModel *model in data ) {
            for (int i = 0; i < tempData.count; i++ ) {
                XFAssetsModel *dmodel = tempData[i];
                if ( [model.modelID isEqual: dmodel.modelID] ) {
//                    NSLog(@"%d",i);
                    [tempArray addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                    [wself.dataArray removeObjectAtIndex:i];
                }
            }
        }
        [wself.collectedView deleteItemsAtIndexPaths:[tempArray copy]];
    } completion:^(BOOL finished) {
        [wself.collectedView reloadData];
        if ( wself.dataArray.count ) {
            [wself.collectedView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:wself.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        [wself setupButtonTitle];
    }];
}

- (void)setupButtonTitle {
    if ( self.maxPhotosNumber != 0 ) {
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)self.dataArray.count,(long)self.maxPhotosNumber];
    }else {
        self.numberLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.dataArray.count];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XFSelectedAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    XFAssetsModel *model = self.dataArray[indexPath.item];
    cell.model = model;
    XFWeakSelf;
    cell.deleteAssetBlock = ^(XFAssetsModel *deleteModel) {
        [wself deleteModelWithData:@[deleteModel]];
        if ( wself.deleteAssetsBlock ) {
            wself.deleteAssetsBlock(deleteModel);
        }
    };
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 60);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XFPreviewViewController *previewViewController = [XFPreviewViewController new];
    previewViewController.showIndex = indexPath.item;
    previewViewController.assetsArray = [NSMutableArray arrayWithArray:[self.dataArray copy]];
    XFWeakSelf;
    previewViewController.deleteImageBlock = ^(NSInteger index) {
        [wself.dataArray removeObjectAtIndex:index];
        [wself.collectedView reloadData];
    };
    [self.navigationController pushViewController:previewViewController animated:true];
}

#pragma mark - lazy
- (UICollectionView *)collectedView {
    if ( !_collectedView ) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.collectionContainer.height, self.collectionContainer.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 8;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectedView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, XFScreenWidth - 84, 76) collectionViewLayout:layout];
        _collectedView.backgroundColor = [UIColor clearColor];
        _collectedView.delegate = self;
        _collectedView.dataSource = self;
        [self.collectionContainer addSubview:_collectedView];
        _collectedView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
        
        [_collectedView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    }
    return _collectedView;
}

- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)dealloc {
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
}

@end
