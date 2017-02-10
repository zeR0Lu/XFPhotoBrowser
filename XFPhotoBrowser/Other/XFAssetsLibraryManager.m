//
//  XFAssetsLibraryManager.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsLibraryManager.h"

@interface XFAssetsLibraryManager ()
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@end

@implementation XFAssetsLibraryManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static XFAssetsLibraryManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[XFAssetsLibraryManager alloc] init];
        manager.cachingImageManager = [[PHCachingImageManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized {
    
    BOOL status = false;
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            status = YES;
        }
    } else {
        if ( [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized ){
            status = YES;
        } 
    }
    return status;
}

#pragma mark - 获取相机胶卷相册分组(这里的名称在不同的版本会有变化,但是那个类型不会变)
- (void)getCameraGroupWithSuccess:(CameraGroupCompletion)success failBlcok:(FailBlock)failBlock {
    if ( self.authorizationStatusAuthorized ) {
        if (iOS8Later) {
            /** PHAssetCollectionType
             PHAssetCollectionTypeAlbum //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
             PHAssetCollectionTypeSmartAlbum //经由相机得来的相册
             PHAssetCollectionTypeMoment //Photos 为我们自动生成的时间分组的相册 */
            
            /** PHAssetCollectionSubtype
            
             PHAssetCollectionSubtypeAlbumRegular               //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
             PHAssetCollectionSubtypeAlbumSyncedEvent           //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
             PHAssetCollectionSubtypeAlbumSyncedFaces           //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
             PHAssetCollectionSubtypeAlbumSyncedAlbum           //做了 AlbumSyncedEvent 应该做的事
             PHAssetCollectionSubtypeAlbumImported              //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
             PHAssetCollectionSubtypeAlbumMyPhotoStream         //用户的 iCloud 照片流
             PHAssetCollectionSubtypeAlbumCloudShared           //用户使用 iCloud 共享的相册
             PHAssetCollectionSubtypeSmartAlbumGeneric          //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
             PHAssetCollectionSubtypeSmartAlbumPanoramas        //相机拍摄的全景照片
             PHAssetCollectionSubtypeSmartAlbumVideos           //相机拍摄的视频
             PHAssetCollectionSubtypeSmartAlbumFavorites        //收藏文件夹
             PHAssetCollectionSubtypeSmartAlbumTimelapses       //延时视频文件夹，同时也会出现在视频文件夹中
             PHAssetCollectionSubtypeSmartAlbumAllHidden        //包含隐藏照片或视频的文件夹
             PHAssetCollectionSubtypeSmartAlbumRecentlyAdded    //相机近期拍摄的照片或视频
             PHAssetCollectionSubtypeSmartAlbumBursts           //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
             PHAssetCollectionSubtypeSmartAlbumSlomoVideos      //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。不过我的 iPad mini 不支持，没法验证。
             PHAssetCollectionSubtypeSmartAlbumUserLibrary      //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
             PHAssetCollectionSubtypeSmartAlbumSelfPortraits
             PHAssetCollectionSubtypeSmartAlbumScreenshots      //应该是截屏的图片,但是是ios 9以后才能使用
             PHAssetCollectionSubtypeSmartAlbumDepthEffect
             PHAssetCollectionSubtypeAny                        //包含所有类型
             */
            // 首次加载直接获取相机得来的相册,为了速度最快
            // 初始化获取相册的属性
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            // 只获取用户资源
            option.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
            // 过滤只获取照片
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            // 获取分组结果,这里为了速度我直接获取相机胶卷的相册
            PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            // 提取分组结果的第一个元素
            PHAssetCollection *collection = smartAlbums.firstObject;
            // 加一层判断,看看是否是相机胶卷的县格策
            if ( collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary ) {
                // 提取相册信息
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                // 封装 Model
                XFAssetsGroupModel *model = [XFAssetsGroupModel getModelWithData:fetchResult];
                model.groupName = collection.localizedTitle;
                model.groupPropertyType = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
                if ( success ) {
                    NSLog(@"返回相册");
                    success(model);
                }
            }
        } else {
            ALAssetsFilter *assetsFilter = [ALAssetsFilter allPhotos];
            
            ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
                if ( group ) {
                    [group setAssetsFilter:assetsFilter];
                    // 这里的判断是因为系统相册的类型 number 就是16
                    // 因为第一次显示为了速度最快显示所以只需要获取到总相册的相簿就可以了
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == 16) {
                        XFAssetsGroupModel *model = [XFAssetsGroupModel getModelWithData:group];
                        success(model);
                        *stop = true;
                    }
                }else {
                    *stop = true;
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
                failBlock(error);
            };
            
            // Then all other groups
            NSUInteger type = ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
            
            [[XFAssetsLibraryManager shareManager].assetLibrary enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failureBlock];
        }
    } else {
        if ( failBlock ) {
            failBlock();
        }
    }
}

#pragma mark - 获取相册所有分组
- (void)getAllAlumbGroupWithSuccess:(AllAlumbGroupCompletion)successBlock failBlcok:(FailBlock)failBlock {
    
    NSMutableArray<XFAssetsGroupModel *> *resultArray = [NSMutableArray array];
    
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        // 只获取用户的相册
        option.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
        // 过滤只获取照片
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        
        // 获取所有相册
        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 相册对象
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            
            // 只显示有数据的相册
            if ( fetchResult.count ) {
                XFAssetsGroupModel *model = [XFAssetsGroupModel getModelWithData:fetchResult];
                model.groupName = collection.localizedTitle;
                model.groupPropertyType = collection.assetCollectionSubtype;
                // 把相机胶卷放第一位
                if ( collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary ) {
                    [resultArray insertObject:model atIndex:0];
                } else {
                    [resultArray addObject:model];
                }
            }
        }
        
        // 获取所有相册
        PHFetchResult<PHAssetCollection *> *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        for (PHAssetCollection *collection in albums) {
            // 相册对象
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            
            // 只显示有数据的相册
            if ( fetchResult.count ) {
                XFAssetsGroupModel *model = [XFAssetsGroupModel getModelWithData:fetchResult];
                model.groupName = collection.localizedTitle;
                model.groupPropertyType = collection.assetCollectionSubtype;
                [resultArray addObject:model];
            }
        }
        if ( successBlock ) {
            successBlock(resultArray.copy);
        }
    } else {
        
        ALAssetsFilter *assetsFilter = [ALAssetsFilter allPhotos];
        
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            
            if ( group ) {
                //            NSLog(@"%@",[group valueForProperty:ALAssetsGroupPropertyName]);
                [group setAssetsFilter:assetsFilter];
                XFAssetsGroupModel *model = [XFAssetsGroupModel getModelWithData:group];
                [resultArray addObject:model];
            }else {
                //                NSLog(@"停止");
                NSArray *tempArray = [resultArray copy];
                for ( XFAssetsGroupModel *model in tempArray ) {
                    if ( model.groupPropertyType == 16 ) {
                        [resultArray removeObject:model];
                        [resultArray insertObject:model atIndex:0];
                    }
                }
                if ( successBlock ) {
                    successBlock(resultArray.copy);
                }
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            if ( failBlock ) {
                failBlock();
            }
        };
        
        // Then all other groups
        NSUInteger type = ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
        
        [[XFAssetsLibraryManager shareManager].assetLibrary enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failureBlock];
    }
}

#pragma mark - 根据相册分组获取分组内的所有 asset 对象
- (void)getAssetsWithGroupModel:(XFAssetsGroupModel *)groupModel selectAssets:(NSArray<XFAssetsModel *> *)selectAssets successBlock:(AllAssetCompletion)successBlock {
    
    NSMutableArray<XFAssetsModel *> *resultArray = [NSMutableArray array];
    
    if ( [groupModel.group isKindOfClass:[PHFetchResult class]] ) {
        PHFetchResult *fetchResult = (PHFetchResult *)groupModel.group;
        [fetchResult enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            
            if ( asset.mediaType == PHAssetMediaTypeImage ) {
                XFAssetsModel *model = [XFAssetsModel getModelWithAsset:asset];
                
                if ( selectAssets ) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modelID=%@",model.modelID];
                    if ( [[selectAssets filteredArrayUsingPredicate:predicate] count] ) {
                        model.selected = true;
                    }
                }
                
                [resultArray addObject:model];
            }
        }];
        if ( successBlock ) {
            successBlock(resultArray.copy, true);
        }
        
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if ( asset ) {
                    if ( [[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto] ) {
                        XFAssetsModel *model = [XFAssetsModel getModelWithAsset:asset];
                        
                        if ( selectAssets ) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modelID=%@",model.modelID];
                            if ( [[selectAssets filteredArrayUsingPredicate:predicate] count] ) {
                                model.selected = true;
                            }
                        }
                        [resultArray addObject:model];
                        
                        if ( resultArray.count == 30 ) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ( successBlock ) {
                                    successBlock(resultArray.copy, false);
                                }
                                [resultArray removeAllObjects];
                            });
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( successBlock ) {
                            successBlock(resultArray.copy,true);
                        }
                    });
                }
            };
            //    //指定操作方式的，遍历。操作方式有：
            //    //NSEnumerationConcurrent：同步的方式遍历
            //    //NSEnumerationReverse：倒序的方式遍历
            //        [wself.assetsGroup enumerateAssetsUsingBlock:resultsBlock];   //最简单的方法,按默认排序
            [groupModel.group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
        });
    }
}

#pragma mark - lazy
- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
        
    }
    return _assetLibrary;
}

@end
