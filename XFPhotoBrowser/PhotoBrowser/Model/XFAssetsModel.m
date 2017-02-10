//
//  XFAssetsModel.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsModel.h"

@implementation XFAssetsModel

+ (XFAssetsModel *)getModelWithAsset:(id)asset {
    return [[self alloc] changeAssetsToModelWithAsset:asset];
}

- (XFAssetsModel *)changeAssetsToModelWithAsset:(id)asset {
    XFAssetsModel *model = [[XFAssetsModel alloc] init];
    
    if ( iOS8Later ) {
        model.modelID = [(PHAsset *)asset localIdentifier];
    } else {
        
        model.modelID = [(ALAsset *)asset valueForProperty:ALAssetPropertyURLs];
    }
    
    model.asset = asset;
    
    model.selected = NO;
    
    return model;
}

@end
