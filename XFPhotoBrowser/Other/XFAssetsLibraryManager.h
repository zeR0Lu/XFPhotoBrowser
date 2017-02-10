//
//  XFAssetsLibraryManager.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XFAssetsGroupModel.h"
#import "XFAssetsModel.h"

typedef void(^CameraGroupCompletion)(XFAssetsGroupModel *model);
typedef void(^AllAlumbGroupCompletion)(NSArray<XFAssetsGroupModel *> *allGroup);
typedef void(^AllAssetCompletion)(NSArray<XFAssetsModel *> *allAsset, BOOL stop);
typedef void(^FailBlock)();

@interface XFAssetsLibraryManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)shareManager;

- (void)getCameraGroupWithSuccess:(CameraGroupCompletion)success failBlcok:(FailBlock)failBlock;

- (void)getAllAlumbGroupWithSuccess:(AllAlumbGroupCompletion)successBlock failBlcok:(FailBlock)failBlock;

- (void)getAssetsWithGroupModel:(XFAssetsGroupModel *)groupModel selectAssets:(NSArray<XFAssetsModel *> *)selectAssets successBlock:(AllAssetCompletion)successBlock;

@end
