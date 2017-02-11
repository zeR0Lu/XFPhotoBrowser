//
//  XFAssetsPhotoViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XFAssetsModel.h"
#import "XFSelectedAssetsViewController.h"
#import "XFAssetsCollectionViewCell.h"
#import "XFTakePhotoCollectionViewCell.h"
#import "XFAssetsModel.h"
#import "UIView+SDAutoLayout.h"
#import "XFHUD.h"
#import "XFAssetsGroupModel.h"
#import "XFAssetsLibraryManager.h"
#import "XFAssetsLibraryAccessFailureView.h"
#import "XFPhotoAlbumViewController.h"
#import "XFCameraViewController.h"
#import "XFBrowerViewController.h"
#import "GCD.h"

static NSString *firstItemIdentifier = @"XFTakePhotoCollectionViewCell";
static NSString *aidentifier = @"XFAssetsCollectionViewCell";

@interface XFAssetsPhotoViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) XFSelectedAssetsViewController *selectedAssetsView;
/** 相册分组 */
@property (strong, nonatomic) NSMutableArray *groupArray;
/** 分组内的数据 */
@property (strong, nonatomic) NSMutableArray<XFAssetsModel *> *dataArray;
/** 选中的 Asset 数组 */
@property (strong, nonatomic) NSMutableArray<XFAssetsModel *> *selectedArray;

@property (nonatomic, strong) GCDSemaphore *semaphore;
@end

@implementation XFAssetsPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    [self.collectionView registerNib:[UINib nibWithNibName:firstItemIdentifier bundle:nil] forCellWithReuseIdentifier:firstItemIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:aidentifier bundle:nil] forCellWithReuseIdentifier:aidentifier];
    
    [self addChildViewController:self.selectedAssetsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChange) name:ALAssetsLibraryChangedNotification object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelBarButtonAction)];
}

#pragma mark - 取消按钮事件
- (void)didCancelBarButtonAction {
    [self dismissViewControllerAnimated:true completion:^{
        self.browerViewController = nil;
    }];
}

- (void)setAssetsGroupModel:(XFAssetsGroupModel *)assetsGroupModel {
    _assetsGroupModel = assetsGroupModel;
    self.title = assetsGroupModel.groupName;
    XFWeakSelf;
    [[XFAssetsLibraryManager shareManager] getAssetsWithGroupModel:assetsGroupModel selectAssets:self.browerViewController.selectedAssets successBlock:^(NSArray *array, BOOL stop) {
        [wself.dataArray removeAllObjects];
        [wself.dataArray addObjectsFromArray:array];
        [wself.collectionView reloadData];
        
        [wself setupSelectedAsset];
    }];
}

#pragma mark - 处理相册改变的通知
//(例如在退出后台时相册有写入新的照片,就要更新数据)
- (void)assetsLibraryChange {
//    NSLog(@"通知方法");
    
    XFWeakSelf;
    // 重置数据
    [self.groupArray removeAllObjects];
    // 首先获取相册分组
    [[XFAssetsLibraryManager shareManager] getAllAlumbGroupWithSuccess:^(NSArray<XFAssetsGroupModel *> *array) {
        [wself.groupArray addObjectsFromArray:array];
        // 设置当前页面的标题
        wself.title = [[wself.groupArray.firstObject group] valueForProperty:ALAssetsGroupPropertyName];
        // 根据分组默认获取第一组的照片
        [[XFAssetsLibraryManager shareManager] getAssetsWithGroupModel:wself.groupArray.firstObject selectAssets:nil successBlock:^(NSArray *array, BOOL stop) {
            
            // 重置数据源数据
            [wself.dataArray removeAllObjects];
            [wself.dataArray addObjectsFromArray:array];
            [XFHUD dismiss];
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[wself.selectedArray copy]];
            // 标记原来选中的照片
            for ( XFAssetsModel *smodel in wself.selectedArray ) {
                for ( XFAssetsModel *cmodel in wself.dataArray ) {
                    if ( [smodel.modelID isEqual:cmodel.modelID] ) {
                        cmodel.selected = true;
                        smodel.selected = true;
                    }
                }
                if ( !smodel.selected ) {
                    [tempArray removeObject:smodel];
                }
            }
            // 处理在进入后台时,删除了已经选中的图片
            if ( tempArray.count != wself.selectedArray.count ) {
                [wself.selectedArray removeAllObjects];
                [wself.selectedArray addObjectsFromArray:tempArray];
            }
            [wself.collectionView reloadData];
        }];
    } failBlcok:^(NSError *error) {
        // 获取失败的操作
        [XFHUD dismiss];
        XFAssetsLibraryAccessFailureView *view = [XFAssetsLibraryAccessFailureView makeView];
        [wself.view addSubview:view];
        view.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    }];
}

- (void)setupSelectedAsset {
    if ( self.browerViewController.selectedAssets.count ) {
        
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObjectsFromArray:self.browerViewController.selectedAssets];
        
        [self.selectedAssetsView addModelWithData:self.browerViewController.selectedAssets];
        
        self.browerViewController.selectedAssets = nil;
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        XFTakePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:firstItemIdentifier forIndexPath:indexPath];
        return cell;
    }else {
        XFAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:aidentifier forIndexPath:indexPath];
        XFAssetsModel *model = self.dataArray[indexPath.item - 1];
        cell.model = model;
        XFWeakSelf;
        __weak typeof(cell) wcell = cell;
        cell.didSelectImageBlock = ^() {
            
            if ( wself.browerViewController.maxPhotosNumber == 0 ) {
                model.selected = true;
                [wself changeDataWithIndexPath:indexPath];
            } else {
                if ( model.selected ) {
                    model.selected = false;
                    [wself changeDataWithIndexPath:indexPath];
                }else {
                    if ( wself.selectedArray.count < wself.browerViewController.maxPhotosNumber ) {
                        model.selected = true;
                        [wself changeDataWithIndexPath:indexPath];
                    }else {
                        [XFHUD overMaxNumberWithNumber:wself.browerViewController.maxPhotosNumber];
                    }
                }
            }
            [wcell refreshState];
        };
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        XFWeakSelf;
        XFCameraViewController *cameraViewController = [XFCameraViewController new];
        cameraViewController.takePhotosBlock = ^(XFAssetsModel *pmodel) {
        
            [wself.selectedArray addObject:pmodel];
            [wself.selectedAssetsView addModelWithData:@[pmodel]];
            
            [collectionView reloadData];
        };
        [self presentViewController:cameraViewController animated:true completion:nil];
    }else {
        
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f);
}

#pragma mark - 处理选择和取消选中的数据模型
- (void)changeDataWithIndexPath:(NSIndexPath *)indexPath {
    
    XFAssetsModel *model = self.dataArray[indexPath.item - 1];
    
    if ( !model.selected ) {
        [self.selectedAssetsView deleteModelWithData:@[model]];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.selectedArray copy]];
        for ( XFAssetsModel *smodel in self.selectedArray) {
            if ( [smodel.modelID isEqual:model.modelID] ) {
                [tempArray removeObject:smodel];
            }
        }
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObjectsFromArray:[tempArray copy]];
        
    }else {
        [self.selectedArray addObject:model];
        [self.selectedAssetsView addModelWithData:@[model]];
    }
//    model.selected = !model.selected;
}

#pragma mark - lazy
- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)selectedArray {
    if ( !_selectedArray ) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

- (NSMutableArray *)groupArray {
    if ( !_groupArray ) {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}

- (XFSelectedAssetsViewController *)selectedAssetsView {
    if ( !_selectedAssetsView ) {
        _selectedAssetsView = [XFSelectedAssetsViewController makeView];
        
        _selectedAssetsView.maxPhotosNumber = self.browerViewController.maxPhotosNumber;
        XFWeakSelf;
        self.selectedAssetsView.deleteAssetsBlock = ^(XFAssetsModel *model) {
            [wself.selectedArray removeObject:model];
            for ( XFAssetsModel *dmodel in wself.dataArray ) {
                if ( [dmodel.modelID isEqual:model.modelID] ) {
                    dmodel.selected = false;
                    break;
                }
            }
            [wself.collectionView reloadData];
        };
        _selectedAssetsView.confirmBlock = ^() {
            // 这个block返回的是 Asset 的数组
            if ( wself.browerViewController.callback ) {
                wself.browerViewController.callback([wself.selectedArray copy]);
            }
            
            // 这个block返回的是 UIimage 的数组
            if ( wself.browerViewController.getImageBlock ) {
                NSMutableArray<UIImage *> *result = [NSMutableArray array];
                [wself.selectedArray enumerateObjectsUsingBlock:^(XFAssetsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [result addObject:[UIImage imageWithCGImage:[[obj.asset defaultRepresentation] fullResolutionImage]]];
                }];
                wself.browerViewController.callback(result.copy);
            }
            
            [wself didCancelBarButtonAction];
        };
        [self.bottomView addSubview:_selectedAssetsView.view];
        _selectedAssetsView.view.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    }
    return _selectedAssetsView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - free
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
    
    [self.selectedArray removeAllObjects];
    self.selectedArray = nil;
    
    [self.groupArray removeAllObjects];
    self.groupArray = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
