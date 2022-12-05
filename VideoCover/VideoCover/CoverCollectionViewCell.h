//
//  CoverCollectionViewCell.h
//  VideoCover
//
//  Created by RZK on 2022/12/2.
//

#import <UIKit/UIKit.h>
#import "VideoCoverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoverCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VideoCoverModel *model;

@end

NS_ASSUME_NONNULL_END
