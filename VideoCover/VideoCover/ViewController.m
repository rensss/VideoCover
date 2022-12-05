//
//  ViewController.m
//  VideoCover
//
//  Created by RZK on 2022/12/1.
//

#import "ViewController.h"
#import "Masonry.h"
#import "R_categorys.h"
#import "CoverViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()

@property (nonatomic, assign) PHAuthorizationStatus ggPhotoAlbumStatus;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.doneButton];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(200);
        make.leading.mas_offset(45);
        make.height.mas_equalTo(40);
        make.width.mas_offset(self.view.width - 90 - 80 - 10);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(35);
        make.centerY.mas_equalTo(self.textField);
        make.leading.mas_equalTo(self.textField.mas_trailing).mas_offset(10);
    }];
}


// MARK: - event
- (void)doneClick {
    NSString *ctime = self.textField.text;
    CGFloat time = [ctime floatValue];
    if (ctime.length != 0) {
        NSLog(@"---- %f", time);
    } else {
        NSLog(@"---- no content");
    }
    
    [self gg_TryOpenPhotoAlbum:^(BOOL granted) {
        if (granted) {
            CoverViewController *coverVC = [[CoverViewController alloc] init];
            coverVC.ctime = time;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:coverVC];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            NSLog(@"---- no granted");
        }
    } refused:^{
        NSLog(@"---- no permissions");
    }];
}

// MARK: - lazy
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"封面CTime时间点 eg:0.0";
        _textField.layer.borderWidth = 1.0f;
        _textField.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return _textField;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.layer.borderWidth = 1.0f;
        _doneButton.layer.borderColor = [UIColor blackColor].CGColor;
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (PHAuthorizationStatus)ggPhotoAlbumStatus {
    if (@available(iOS 14, *)) {
        return [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    return [PHPhotoLibrary authorizationStatus];
}

// MARK: - utils
- (void)gg_TryOpenPhotoAlbum:(void (^)(BOOL granted))block refused:(void (^)(void))refused {
    if (self.ggPhotoAlbumStatus == PHAuthorizationStatusNotDetermined) {
        if (@available(iOS 14, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                        if (status == PHAuthorizationStatusAuthorized) {
                            
                        }
                        if (status == PHAuthorizationStatusLimited) {
                            
                        }
                        if (block) {
                            block(YES);
                        }
                    } else {
                        if (refused) {
                            refused();
                        }
                    }
                });
            }];
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        //同意
                        if (block) {
                            block(YES);
                        }
                    } else {
                        // 拒绝
                        if (refused) {
                            refused();
                        }
                    }
                });
            }];
        }
    } else {
        BOOL granted = [self gg_CheckPhotoAlbum];
        if (block) {
            block(granted);
        }
    }
}

- (BOOL)gg_CheckPhotoAlbum {
    if (@available(iOS 14, *)) {
        if (self.ggPhotoAlbumStatus == PHAuthorizationStatusLimited || self.ggPhotoAlbumStatus == PHAuthorizationStatusAuthorized) {
            return YES;
        }
        return NO;
    } else {
        if (self.ggPhotoAlbumStatus == PHAuthorizationStatusAuthorized) {
            return YES;
        }
        return NO;
    }
}


@end
