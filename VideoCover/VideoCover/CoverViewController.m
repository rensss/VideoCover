//
//  CoverViewController.m
//  VideoCover
//
//  Created by RZK on 2022/12/1.
//

#import "CoverViewController.h"
#import <Photos/Photos.h>
#import "Masonry.h"
#import "R_categorys.h"
#import "VideoCoverModel.h"
#import "CoverCollectionViewCell.h"

typedef void(^MyImageBlock)(UIImage * _Nullable image);

#define itemWidth ((self.view.width - 20 - 20 - 1)/3)
#define itemHeight (itemWidth + 30)

@interface CoverViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

// MARK: - event
- (void)backClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


// MARK: - func


// MARK: - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CoverCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CoverCollectionViewCell class]) forIndexPath:indexPath];
    
    cell.model = self.dataArray[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCoverModel *model = self.dataArray[indexPath.item];
    NSLog(@"---- %@", model.asset);
}


// MARK: - lazy
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray array];
        
        NSArray<PHAsset *> *allAsset = [self getAllVideoAssetWithAscending:YES];
        NSMutableArray *models = [NSMutableArray array];
        
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
        __weak typeof(self) weakSelf = self;
        __block NSInteger count = 0;
        [allAsset enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            VideoCoverModel *model = [[VideoCoverModel alloc] init];
            model.asset = obj;
            
            NSLog(@"---- itemWith:%f", itemWidth);
            if (self.ctime < 0) {
                [self getPhotoWithAsset:obj photoWidth:itemWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    count ++;
                    model.coverImage = photo;
                    if (count == allAsset.count) {
                        NSLog(@"---- coverImage done");
                        [weakSelf.collectionView reloadData];
                        
                        // do something
                        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                        NSLog(@"---- system time %f", end - start);
                    }
                } progressHandler:nil networkAccessAllowed:YES];
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    @autoreleasepool {
                        [weakSelf getAVAssetFromPHAsset:obj completion:^(AVAsset *avasset) {
                            [weakSelf getThumbWithAsset:(AVURLAsset *)avasset atTime:0 completion:^(UIImage * _Nullable image) {
                                count ++;
                                model.coverImage = image;
                                if (count == allAsset.count) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSLog(@"---- coverImage done");
                                        [weakSelf.collectionView reloadData];
                                        
                                        // do something
                                        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                                        NSLog(@"---- url time: %f", end - start);
                                    });
                                }
                            }];
                        }];
                    }
                });
                
//                [weakSelf requestUrlWihtAsset:obj completion:^(AVAsset *avaseet, NSError *error) {
//                    if (error) {
//                        count ++;
//                        NSLog(@"---- error:%@", error);
//                        if (count == allAsset.count) {
//                            NSLog(@"---- error coverImage done");
//                            [weakSelf.collectionView reloadData];
//
//                            // do something
//                            CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//                            NSLog(@"---- error url time: %f", end - start);
//                        }
//                    } else {
//                        AVURLAsset *av = (AVURLAsset *)avaseet;
//
//                        NSString *videoStr = av.URL.absoluteString;
//                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                            NSFileManager *fm = [NSFileManager defaultManager];
//                            NSError *error = nil;
//                            NSDictionary *dict = [fm attributesOfItemAtPath:videoStr error:&error];
//                            if (error) {
//                                NSLog(@"---- error:%@", error);
//                            }
//                            NSLog(@"---- %@",dict);
//                        });
//                        [weakSelf getThumbnailImage:[NSURL URLWithString:videoStr] atTime:self.ctime completion:^(UIImage * _Nullable image) {
//                            count ++;
//                            model.coverImage = image;
//                            if (count == allAsset.count) {
//                                NSLog(@"---- coverImage done");
//                                [weakSelf.collectionView reloadData];
//
//                                // do something
//                                CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//                                NSLog(@"---- url time: %f", end - start);
//                            }
//                        }];
//                    }
//                }];
                
                
//                [weakSelf getVideoUrl:obj completion:^(NSString *videoStr) {
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        NSFileManager *fm = [NSFileManager defaultManager];
//                        NSError *error = nil;
//                        NSDictionary *dict = [fm attributesOfItemAtPath:videoStr error:&error];
//                        if (error) {
//                            NSLog(@"---- error:%@", error);
//                        }
//                        NSLog(@"---- %@",dict);
//                    });
//                    [weakSelf getThumbnailImage:[NSURL URLWithString:videoStr] atTime:self.ctime completion:^(UIImage * _Nullable image) {
//                        count ++;
//                        model.coverImage = image;
//                        if (count == allAsset.count) {
//                            NSLog(@"---- coverImage done");
//                            [weakSelf.collectionView reloadData];
//
//                            // do something
//                            CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//                            NSLog(@"---- url time: %f", end - start);
//                        }
//                    }];
//                }];
            }
            
            [models addObject:model];
        }];
        NSLog(@"---- %lu", (unsigned long)models.count);
        _dataArray = models;
    }
    return _dataArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        [_collectionView registerClass:[CoverCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CoverCollectionViewCell class])];
    }
    return _collectionView;
}


// MARK: - utils
- (void)getThumbnailImage:(NSURL *)videoURL atTime:(Float64)seconds completion:(void(^)(UIImage *image))handler {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    [self getThumbWithAsset:asset atTime:seconds completion:handler];
}

- (void)getAVAssetFromPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *avasset))completion {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        completion(avasset);
    }];
}

- (void)getThumbWithAsset:(AVURLAsset *)asset atTime:(Float64)seconds completion:(void(^)(UIImage *image))handler {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    CMTime time = CMTimeMakeWithSeconds(seconds, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    handler(thumb);
}

// MARK: -相册相关
- (NSArray<PHAsset *> *)getAllVideoAssetWithAscending:(BOOL)ascending {
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    // 按创建时间排序 ascending为YES时，按照照片的创建时间升序排列;为NO时，则降序排列(由现在到过去)
    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeVideo];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    // 获取所有照片
    PHFetchResult<PHAsset *> *allAsset = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    NSMutableArray *assets = [NSMutableArray array];
    [allAsset enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:obj];
    }];
    return assets;
}

// MARK: -获取封面
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    
    CGSize imageSize = CGSizeMake(photoWidth, photoWidth);
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        @autoreleasepool {
            BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
            if (!cancelled && result) {
                //                CLog(@"---- imageSize:%@", NSStringFromCGSize(result.size));
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            // Download image from iCloud / 从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress, error, stop, info);
                        }
                    });
                };
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData];
                    if (!resultImage && result) {
                        resultImage = result;
                    }
                    if (completion) completion(resultImage,info,NO);
                }];
            }
            
        }
    }];
    return imageRequestID;
}

- (void)getVideoUrl:(PHAsset *)asset completion:(void (^)(NSString *videoStr))completion {
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
    videoRequestOptions.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        NSLog(@"---- info - %@", info);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *videoURL;
            //video路径获取
            if (asset && [asset isKindOfClass:[AVURLAsset class]] && [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL].length > 0) {
                NSString *videoURLStr = [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL];
                videoURL = ((AVURLAsset *)asset).URL;
                NSLog(@"---- %@",videoURLStr);
                if (completion) {
                    completion(videoURLStr);
                }
            }
        });
    }];
}

- (void)requestUrlWihtAsset:(PHAsset *)passet completion:(void (^)(AVAsset *avaseet, NSError *error))completion {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    };
    //相册中获取到的phAsset;
    PHAsset *phAsset = passet; //= self.sset;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if(([asset isKindOfClass:[AVComposition class]] && ((AVComposition *)asset).tracks.count == 2)){
            //slow motion videos. See Here: https://overflow.buffer.com/2016/02/29/slow-motion-video-ios/
            
            //Output URL of the slow motion file.
            NSString *root = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSString *tempDir = [root stringByAppendingString:@"/com.sdk.demo/temp"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *myPathDocs =  [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeSlowMoVideo-%d.mov",arc4random() % 1000]];
            NSURL *url = [NSURL fileURLWithPath:myPathDocs];
            //Begin slow mo video export
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        NSURL *URL = exporter.outputURL;
                        AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 拿到有权限的asset
                            completion(asset, nil);
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 错误
                            completion(nil, exporter.error);
                        });
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 拿到有权限的asset
                completion(asset, nil);
            });
        }
    }];
}



@end
