# RTSP_Player_With_IJK
RTSP player on iOS using Swift with IJKPlayer (https://github.com/bilibili/ijkplayer)

# Hướng dẫn build IJK Player để play RTSP streaming

## Table of Contents

* [Chuẩn bị môi trường](#Chuẩn_bị_môi_trường)
* [Build lib IJKPlayer](#Build_lib_IJKPlayer)
* [Tích hợp IJKPlayer vào project](#Tích_hợp_IJKPlayer_vào_project)
* Sample

### Chuẩn bị môi trường
* Cài đặt Homebrew
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
* Cài git `brew install git`
* Cài yasm `brew install yasm`
* Clone IJKPlayer từ github:
  * `git clone https://github.com/RioV/ijkplayer.git ijkplayer-ios`
    * Note: ở đây dùng `/RioV/ijkplayer` bởi vì đang tìm hiểu thấy IJKPlayer có issue, vậy nên folk sang một bản khác để tiện fix bug
    * Note: chú ý checkout source code về folder mà tên không có space, ví dụ: `IJK Player` => NG, `IJK-Player` => OK. Việc này sẽ ảnh hưởng đến tiến trình build lib, nếu như có space thì build sẽ bị lỗi.
  * `cd ijkplayer-ios`
  * `git checkout -B latest k0.8.8` version lấy theo release tag của IJKPlayer [Release](https://github.com/RioV/ijkplayer/releases) Nếu sau này sửa lỗi lib ở branch develop thì sẽ là `git checkout -B develop`

### Build lib IJKPlayer
* `cd config`
* `rm module.sh`
* `ln -s module-lite.sh module.sh` -> việc này sẽ bỏ module.sh default và thay vào đó sử dụng moule-lite.sh nhằm giảm binary size
* Để build lib support RTSP thì cần chỉnh sửa file `module-lite.sh` như sau:
  * Xoá: `export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --disable-protocol=rtp"`
  * Add: `export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-protocol=rtp"`
  * Add: `export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-demuxer=rtsp"` (nên để trong section của demuxer)
* `cd ..`
* `./init-ios.sh`
* `cd ios`
* `./compile-ffmpeg.sh clean`
* Sửa file ijkplayer-ios/ios/compile-ffmpeg.sh
  * Chuyển:

    FF_ALL_ARCHS_IOS6_SDK="armv7 armv7s i386"
    FF_ALL_ARCHS_IOS7_SDK="armv7 armv7s arm64 i386 x86_64"
    FF_ALL_ARCHS_IOS8_SDK="armv7 arm64 i386 x86_64"

    Thành

    FF_ALL_ARCHS_IOS8_SDK="arm64 i386 x86_64"
* `./compile-ffmpeg.sh all`
  * Note: Với câu lệnh ./compile-ffmpeg.sh all thì rất dễ xảy ra lỗi nếu như source code đang ở trong directoy có chứa space. Ví dụ: working directory là `/Documents/JLK Player` thì sẽ lỗi, để fix thì chuyển thành `/Documents/IJKPlayer`

### Tích hợp IJKPlayer vào project  
* Add IJKPlayer vào project: File -> add File to "Project" -> chọn ijkplayer-ios/ios/IJKMediaPlayer/IJKMediaPlayer.xcodeproj
* Chọn: Application's target.
  * Vào: Build Phases -> Target Dependencies -> Chọn IJKMediaFramework
  * Chọn `IJKMediaPlayer.xcodeproj`, chọn target `IJKMediaFramework` và build.
  * Vào: Build Phases -> Link Binary with Libraries -> Thêm:
    * libc++.tbd
    * libz.tbd
    * libbz2.tbd
    * AudioToolbox.framework
    * UIKit.framework
    * CoreGraphics.framework
    * AVFoundation.framework
    * CoreMedia.framework
    * CoreVideo.framework
    * MediaPlayer.framework
    * MobileCoreServices.framework
    * OpenGLES.framework
    * QuartzCore.framework
    * VideoToolbox.framework

### Sample
Sử dụng đoạn source code sau để play thử RTSP stream bằng IJKPlayer

```swift
import UIKit
import IJKMediaFramework

class IJKPlayerViewController: UIViewController {
    var player: IJKFFMoviePlayerController!
    override func viewDidLoad() {
        super.viewDidLoad()

        let options = IJKFFOptions.byDefault()
        let url = URL(string: "rtsp://170.93.143.139/rtplive/470011e600ef003a004ee33696235daa")
        guard let player = IJKFFMoviePlayerController(contentURL: url, with: options) else {
            print("Create RTSP Player failed")
            return
        }

        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        player.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)

        player.view.frame = self.view.bounds
        player.scalingMode = IJKMPMovieScalingMode.aspectFit
        player.shouldAutoplay = true
        self.view.autoresizesSubviews = true
        self.view.addSubview(player.view)
        self.player = player        
        self.player.prepareToPlay()
    }
}
