//
//  PTVPictureInpicture.m
//  PictureInPicture
//
//  Created by 尚娱互动 on 2022/1/4.
//

#import "PTVPictureInpicture.h"
#import <UIKit/UIKit.h>
#import "AVKit/AVKit.h"
///kvo 监听状态
static NSString *const kForPlayerItemStatus = @"status";

@interface PTVPictureInpicture()<AVPictureInPictureControllerDelegate>

///#画中画
@property (nonatomic, strong) AVPictureInPictureController *pipViewController;// 画中画

@end

@implementation PTVPictureInpicture
{
    BOOL           _needEnterRoom;
    UIView        *_playerContent;
    AVQueuePlayer *_queuePlayer;
    ///#开始
    AVPlayerItem                 *_beginItem;
    AVPlayerItem                 *_playerItem;
    AVPlayerLayer                *_playerLayer;
}
+ (instancetype)pictureInpicture {
    static PTVPictureInpicture *_p;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _p = [PTVPictureInpicture new];
    });
    return _p;
}

+ (BOOL)isSupportPictureInPicture {
    static BOOL _isSuportPic = NO;
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    Class _c = NSClassFromString(@"AVPictureInPictureController");
    if (_c != nil) {
        _isSuportPic = [AVPictureInPictureController isPictureInPictureSupported];
    }
    //    });
    return _isSuportPic;
}


- (void)_initPicture {
    if (![[self class] isSupportPictureInPicture]) return;
    [self setupSuport];
}

-(void)setupSuport
{
    if([AVPictureInPictureController isPictureInPictureSupported]) {
        _pipViewController =  [[AVPictureInPictureController alloc] initWithPlayerLayer:_playerLayer];
        _pipViewController.delegate = self;
    }
}

-(void)_mediaPlayDidEnd:(NSNotification *)noti{
    [self performSelectorOnMainThread:@selector(_mediaPlayDidEndInMainThread:) withObject:noti waitUntilDone:NO];
}
-(void)_mediaPlayDidEndInMainThread:(NSNotification *)noti{
    AVPlayerItem *item = [noti object];
    if (item != _beginItem) return;
    [_beginItem seekToTime:kCMTimeZero completionHandler:nil];
}
//初始化画中画
- (void)initPTVPicutre:(NSString *)roomId{
    [self closePicInPic];
    
    self.roomID = roomId;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    ///#等待资源加载好
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"BeginPIP"
                                                     ofType:@"mp4"];
    
    NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
    _beginItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    [_beginItem addObserver:self
                 forKeyPath:kForPlayerItemStatus
                    options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    
    
    _queuePlayer = [AVQueuePlayer queuePlayerWithItems:@[_beginItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mediaPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_queuePlayer.currentItem];
    _queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_queuePlayer];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;  // 适配视频尺寸
    _playerLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    
    [self _initPicture];
    
    if (!_playerContent) {
        _playerContent = [UIView new];
        _playerContent.frame = CGRectMake(-10, -10, 1, 1);
        _playerContent.alpha = 0.0;
        _playerContent.backgroundColor = [UIColor clearColor];
        _playerContent.userInteractionEnabled = NO;
    }
    _playerLayer.frame = [UIScreen mainScreen].bounds;
    [_playerContent.layer addSublayer:_playerLayer];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_playerContent];
    
    [_queuePlayer play];
}


- (void)openPictureInPicture:(NSString *)url seekToSecond:(int)second {
    
//    if (![[self class] isSupportPictureInPicture]) return;
//    if (!url || url.length == 0 ) return;
//    if (![url containsString:@"m3u8"]) return;
//
//    [self closePicInPic];
//
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setActive: YES error: nil];
//
//    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
//
//    ///#等待资源加载好
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"BeginPIP"
//                                                     ofType:@"mp4"];
//
//    NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
//    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
//    _beginItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//
//
//    [_playerItem addObserver:self
//                  forKeyPath:kForPlayerItemStatus
//                     options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
//
//    [_beginItem addObserver:self
//                 forKeyPath:kForPlayerItemStatus
//                    options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
//
//
//    _queuePlayer = [AVQueuePlayer queuePlayerWithItems:@[_beginItem]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mediaPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_queuePlayer.currentItem];
//    _queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//
//
//    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_queuePlayer];
//    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;  // 适配视频尺寸
//    _playerLayer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
//
//    [self _initPicture];
//
//    if (!_playerContent) {
//        _playerContent = [UIView new];
//        _playerContent.frame = CGRectMake(-10, -10, 1, 1);
//        _playerContent.alpha = 0.0;
//        _playerContent.backgroundColor = [UIColor clearColor];
//        _playerContent.userInteractionEnabled = NO;
//    }
//    _playerLayer.frame = CGRectMake(0, 0, 400, 400);
//    [_playerContent.layer addSublayer:_playerLayer];
//
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:_playerContent];
//
//    [_queuePlayer play];
    if (!url || url.length == 0 ) return;
    if (![url containsString:@"m3u8"]) return;
    // - 播放视频
    NSArray *keys = @[@"tracks"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:url] options:nil];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^(){
        for (NSString *thisKey in keys) {
            NSError *error = nil;
            AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
            if (keyStatus != AVKeyValueStatusLoaded) {
                return ;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
            [item seekToTime: CMTimeMakeWithSeconds(second, 1)];
            [item addObserver:self forKeyPath:kForPlayerItemStatus options:NSKeyValueObservingOptionNew context:nil];
            [self->_queuePlayer replaceCurrentItemWithPlayerItem:item];
            [self->_queuePlayer play];
        });
    }];
    [self doPicInPic];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
//    if ([keyPath isEqualToString:@"status"]) {
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            if (_queuePlayer.status == AVPlayerStatusReadyToPlay) {
//                [_queuePlayer play];
//                if (!_pipViewController.isPictureInPictureActive) {
//                    [self doPicInPic];
//                }
//            } else {
//                [self closePicInPic];
//            }
//
//        });
//
//    }
    if (object == _beginItem) {
        NSLog(@"// - console [error] ... beginItem %ld", (long)_queuePlayer.status);
    }else {
        // - 如果当前开始使用 _queuePlayer 播放m3u8, 停止播放视频.
//        [[QIEPlayer shareInstance] stopPlay];
        NSLog(@"// - console [error] ... xxxxx");
    }
    
}


- (void)doPicInPic {
    if (![[self class] isSupportPictureInPicture]) return;
    
    if (!_pipViewController.pictureInPictureActive) {
        [_pipViewController startPictureInPicture];
        _needEnterRoom = YES;
    }
}


- (void)closePicInPic {
    if (![[self class] isSupportPictureInPicture]) return;
    if (!_pipViewController) return;
    
    [self _removePlayerContentView];
    _needEnterRoom = NO;
    [self _removeObserve];
    
    if (_pipViewController.pictureInPictureActive) {
        [_pipViewController stopPictureInPicture];
    }
    
    ///# 释放资源
    _playerItem  = nil;
    _playerLayer = nil;
    _beginItem   = nil;
    _queuePlayer = nil;
}

- (void)_removeObserve {
    if (_playerItem) {
        [_playerItem removeObserver:self
                         forKeyPath:@"status"];
        _playerItem = nil;
    }
    if (_beginItem) {
        [_beginItem removeObserver:self
                        forKeyPath:@"status"];
        _beginItem = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_changeToLoadingVideo{
    [_queuePlayer pause];
    [_queuePlayer replaceCurrentItemWithPlayerItem:_beginItem];
    [_queuePlayer play];
}


- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    
//    if (_needEnterRoom) {
//
//        [self _removePlayerContentView];
//
//        if (self.roomID) {
////####进入直播间
//        }
//        [self _removeObserve];
//    }
    if (_needEnterRoom) {
        NSTimeInterval currentTimeSec = _queuePlayer.currentTime.value / _queuePlayer.currentTime.timescale;
        self.progressSecond = currentTimeSec;
    }
    [_queuePlayer pause];
    self.pip_block();
    completionHandler(YES);
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if (!_needEnterRoom) {
        [self _changeToLoadingVideo];
    }
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if (!_needEnterRoom) {
        [self _changeToLoadingVideo];
    }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    [self _removePlayerContentView];
}

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}

- (void)_removePlayerContentView {
    if (_playerContent && _playerContent.superview) {
        [_playerContent removeFromSuperview];
    }
}

@end


