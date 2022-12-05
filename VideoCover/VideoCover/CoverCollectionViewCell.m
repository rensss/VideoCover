//
//  CoverCollectionViewCell.m
//  VideoCover
//
//  Created by RZK on 2022/12/2.
//

#import "CoverCollectionViewCell.h"
#import "Masonry.h"
#import "R_categorys.h"

@interface CoverCollectionViewCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *assetTitle;


@end

@implementation CoverCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.coverImageView];
        [self.contentView addSubview:self.assetTitle];
        
        [self.assetTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
            make.leading.trailing.bottom.mas_offset(0);
        }];
        
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_offset(0);
            make.bottom.mas_equalTo(self.assetTitle.mas_top).mas_offset(0);
        }];
        
    }
    return self;
}

- (void)setModel:(VideoCoverModel *)model {
    _model = model;
    
    self.coverImageView.image = model.coverImage;
    self.assetTitle.text = model.asset.localIdentifier;
}


- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.clipsToBounds = YES;
        _coverImageView.backgroundColor = [UIColor colorWithRandom];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImageView;
}

- (UILabel *)assetTitle {
    if (!_assetTitle) {
        _assetTitle = [[UILabel alloc] init];
        _assetTitle.numberOfLines = 0;
        _assetTitle.adjustsFontSizeToFitWidth = YES;
        _assetTitle.minimumScaleFactor = 0.7;
        _assetTitle.font = [UIFont systemFontOfSize:12];
        _assetTitle.textColor = [UIColor blackColor];
        _assetTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _assetTitle;
}

@end
