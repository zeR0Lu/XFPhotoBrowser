//
//  XFAssetsGroupModel.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsGroupModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation XFAssetsGroupModel

+ (XFAssetsGroupModel *)getModelWithData:(id)data {
    return [[self alloc] changeAssetsGroupToModelWithAssetsGroup:data];
}

- (XFAssetsGroupModel *)changeAssetsGroupToModelWithAssetsGroup:(id)assetsGroup {
    XFAssetsGroupModel *model = [[XFAssetsGroupModel alloc] init];
    
    model.group = assetsGroup;
    
    if ( [assetsGroup isKindOfClass:[PHFetchResult class]] ) {
        PHFetchResult *result = (PHFetchResult *)assetsGroup;
        model.photosNumber = [NSString stringWithFormat:@"%ld",result.count];
    } else {
        
        CGImageRef imageRef = [(ALAssetsGroup *)assetsGroup posterImage];
        
        model.image = [UIImage imageWithCGImage:imageRef];
        
        model.groupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
        model.photosNumber = [NSString stringWithFormat:@"%ld",(long)[assetsGroup numberOfAssets]];
        
        model.groupPropertyType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] integerValue];
    }
    
    
    return model;
}

@end
