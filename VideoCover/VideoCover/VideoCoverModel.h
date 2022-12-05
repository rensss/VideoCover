//
//  VideoCoverModel.h
//  VideoCover
//
//  Created by RZK on 2022/12/2.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCoverModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *coverImage;

@end

NS_ASSUME_NONNULL_END
