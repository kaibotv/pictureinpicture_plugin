#import "PictureinpicturePlugin.h"
#if __has_include(<pictureinpicture_plugin/pictureinpicture_plugin-Swift.h>)
#import <pictureinpicture_plugin/PictureInPicture_plugin.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "PictureInPicture_plugin.h"
#endif

@implementation PictureinpicturePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [PictureInPicture_plugin registerWithRegistrar:registrar];
}
@end
