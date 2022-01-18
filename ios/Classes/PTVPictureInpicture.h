//
//  PTVPictureInpicture.h
//  PictureInPicture
//
//  Created by 尚娱互动 on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^pipBlock)(void);

@interface PTVPictureInpicture : NSObject

+ (instancetype)pictureInpicture;

//初始化画中画
- (void)initPTVPicutre:(NSString *)roomId;

///是否支持画中画中能
+ (BOOL)isSupportPictureInPicture;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) pipBlock pip_block;

///当前播放时间
@property (nonatomic, assign) NSInteger progressSecond;

///#初始化 url m3u8格式
- (void)openPictureInPicture:(NSString *)url seekToSecond:(int)second;

///#开启画中画
- (void)doPicInPic;

///#关闭画中画
- (void)closePicInPic;

@end

NS_ASSUME_NONNULL_END
