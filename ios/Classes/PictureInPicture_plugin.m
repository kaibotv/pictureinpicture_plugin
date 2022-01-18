//
//  PictureInPicture_plugin.m
//  pictureinpicture_plugin
//
//  Created by 尚娱互动 on 2022/1/10.
//
#import <Flutter/Flutter.h>
#import "PictureInPicture_plugin.h"
#import "PTVPictureInpicture.h"
@interface PictureInPicture_plugin ()
<
FlutterPlugin
>
@end

@implementation PictureInPicture_plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar{
    FlutterMethodChannel * channel = [FlutterMethodChannel methodChannelWithName:@"pictureinpicture_plugin" binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:[PictureInPicture_plugin new] channel:channel];
    
    [PTVPictureInpicture pictureInpicture].pip_block = ^{
        NSString * roomId = [PTVPictureInpicture pictureInpicture].roomID;
        NSInteger second = [PTVPictureInpicture pictureInpicture].progressSecond;
        NSString * secondStr = [NSString stringWithFormat:@"%ld",(long)second];
        NSArray * arguments = @[roomId,secondStr];
        [channel invokeMethod:@"restoreUserInterfaceForPIP" arguments:arguments result:^(id  _Nullable result) {

        }];
    };
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    NSString *method=call.method;
    if ([method isEqualToString:@"PIPInt"]) {//初始化
        [[PTVPictureInpicture pictureInpicture] initPTVPicutre:call.arguments];
    }
    else if ([method isEqualToString:@"PIPopen"]){//开启画中画
        NSArray * arguments = call.arguments;
        [[PTVPictureInpicture pictureInpicture] openPictureInPicture:arguments[0] seekToSecond:[arguments[1] intValue]];
    }
    else if ([method isEqualToString:@"PIPisSupport"]){//是否支持画中画
        bool isSupportPIP = [PTVPictureInpicture isSupportPictureInPicture];
        NSString * pipStr = [NSString stringWithFormat:@"%d",isSupportPIP];
        result(pipStr);
    }
    else if ([method isEqualToString:@""]){
        
    }
    else if ([method isEqualToString:@""]){
        
    }
    else if ([method isEqualToString:@"PIPdispost"]){
        [[PTVPictureInpicture pictureInpicture] closePicInPic];
    }
}
@end
