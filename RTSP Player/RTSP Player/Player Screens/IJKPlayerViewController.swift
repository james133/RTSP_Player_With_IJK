//
//  IJKPlayerViewController.swift
//  RTSP Player
//
//  Created by Hoang Minh Nhat on 5/24/19.
//  Copyright © 2019 GST. All rights reserved.
//

import UIKit
import IJKMediaFramework
import Photos

class IJKPlayerViewController: UIViewController {

    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    
    private var player: IJKFFMoviePlayerController!
    private weak var timer: Timer?
    private weak var currentPlaybackTimer: Timer?
    private var isStopRecording = false
    
    private var ageObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textFieldURL.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
        currentPlaybackTimer?.invalidate()
        currentPlaybackTimer = nil
        if let player = player {
            player.stop()
            player.shutdown()
        }
        removePlayerStateObserver()
    }

    private func setupPlayer(with url: URL) {
        if self.player != nil {
            self.player.view.removeFromSuperview()
        }
        
        guard let options = IJKFFOptions.byDefault() else {
            print("Setup IJKFFOptions failed!!!")
            return
        }
        
        settingOptionForPlayer(options)
        
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)!
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        player.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        player.view.frame = viewPlayer.bounds
        player.scalingMode = IJKMPMovieScalingMode.aspectFit
        player.shouldAutoplay = true
        player.shouldShowHudView = true
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
        
        viewPlayer.autoresizesSubviews = true
        viewPlayer.addSubview(player.view)
        
        self.player = player
        
        addPlayerStateObserver(player: player)
    }
    
    private func settingOptionForPlayer(_ options: IJKFFOptions) {
        // Use hardware decode
//        options.setPlayerOptionIntValue(1, forKey: "videotoolbox")
        
        
        // Use tcp instead of udp
//        options.setFormatOptionValue("tcp", forKey: "rtsp_transport")
        // User-agent
        options.setFormatOptionValue("rtsp-player", forKey: "user-agent")
        
        options.setOptionIntValue(0,            forKey: "packet-buffering", of: kIJKFFOptionCategoryPlayer)
        options.setOptionIntValue(5,            forKey: "min-frames",       of: kIJKFFOptionCategoryPlayer)
        options.setOptionIntValue(25,           forKey: "max-fps",          of: kIJKFFOptionCategoryPlayer)
        
        options.setOptionIntValue(512 * 1024,   forKey: "max-buffer-size",  of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(4096,         forKey: "probsize",         of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(2000000,      forKey: "analyzeduration",  of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(32,           forKey: "probesize",        of: kIJKFFOptionCategoryFormat)
        
        options.setOptionValue("ext",           forKey: "sync",             of: kIJKFFOptionCategoryFormat)
        options.setOptionValue("nobuffer",      forKey: "fflags",           of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(1, forKey: "reconnect", of: kIJKFFOptionCategoryPlayer)
//mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "reconnect", 1);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "opensles", 0);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", 1);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", 1);
//
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "http-detect-range-support", 0);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fflags", "nobuffer");
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "flush_packets", 1);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "max_delay", 0);
//
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", 48);
//
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 0);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "max-buffer-size", 4 * 1024);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", 50);
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "probsize", "1024");
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "analyzeduration", "100");
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_clear", 1);
//        //mute
//        //mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "an", 1);
//        / / Reconnect mode, if the midway server disconnected, let it reconnect
//        mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "reconnect", 1);
        
//        [options setPlayerOptionIntValue:30  forKey:@"max-fps"];
//        [options setPlayerOptionIntValue:30 forKey:@"r"];
//        [options setPlayerOptionIntValue:1  forKey:@"framedrop"];
//        [options setPlayerOptionIntValue:0  forKey:@"start-on-prepared"];
//        [options setPlayerOptionIntValue:0  forKey:@"http-detect-range-support"];
//        [options setPlayerOptionIntValue:48  forKey:@"skip_loop_filter"];
//        [options setPlayerOptionIntValue:0  forKey:@"packet-buffering"];
//        [options setPlayerOptionIntValue:2000000 forKey:@"analyzeduration"];
//        [options setPlayerOptionIntValue:25  forKey:@"min-frames"];
//        [options setPlayerOptionIntValue:1  forKey:@"start-on-prepared"];
//        [options setCodecOptionIntValue:8 forKey:@"skip_frame"];
//        [options setFormatOptionValue:@"nobuffer" forKey:@"fflags"];
//        [options setFormatOptionValue:@"8192" forKey:@"probsize"];
    }
    
    private func playVideo(with url: String) {
        guard let url = URL(string: url) else {
            print("URL Invalid")
            return
        }
        
        showLoadingProgress(for: viewPlayer)
        setupPlayer(with: url)
        player.prepareToPlay()
    }
    
    @IBAction func invokeButtonPlay(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            sender.setTitle("Pause", for: .normal)
            player.play()
        } else {
            sender.setTitle("Play", for: .normal)
            player.pause()
        }
    }
    
    @IBAction func invokeButtonStop(_ sender: Any) {
        player.stop()
        player.shutdown()
        enableButtons(false)
        removePlayerStateObserver()
    }
    
    @IBAction func invokeButtonTakeImage(_ sender: UIButton) {
        let urlPath = getDocumentsDirectory()
        print(urlPath)
        if !isStopRecording {
            player.startRecord(withFileName: urlPath.absoluteString)
        } else {
            player.stopRecord()
        }

        if isStopRecording {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: urlPath)
            }) { [unowned self] saved, error in
                if saved {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    print(error ?? "Unknow error")
                    let alertController = UIAlertController(title: "Your video was successfully FAILED", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        isStopRecording = !isStopRecording
    }
    
    func getDocumentsDirectory() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("rtsp.mov") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                let attr: [FileAttributeKey : Any]? = try? FileManager.default.attributesOfItem(atPath: filePath) as [FileAttributeKey : Any]
                if let _attr = attr {
                    print(_attr)
                }
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("rtsp.mov")
    }
}

extension IJKPlayerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
//            textField.text = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
            textField.text = "rtsp://170.93.143.139/rtplive/470011e600ef003a004ee33696235daa"
        }
        
        playVideo(with: textField.text ?? "rtsp://admin:1234qwer@192.168.0.174:554/onvif1")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UI related
private extension IJKPlayerViewController {
    private func showLoadingProgress(for view: UIView) {
        ProgressView.show(view: view)
    }
    
    private func hideLoadingProgress() {
        ProgressView.hide(view: viewPlayer)
    }
    
    private func enableButtons(_ enable: Bool) {
        buttonPlayPause.isEnabled = enable
        buttonStop.isEnabled = enable
    }
}

// Handle playback current time and seek
private extension IJKPlayerViewController {
    private func createTrackingPlaybackTimerForPlayer(_ player: IJKFFMoviePlayerController) {
        currentPlaybackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(currentSeekPosition), userInfo: nil, repeats: true)
    }
    
    @objc private func currentSeekPosition() {
        playbackSlider.maximumValue = Float(player.duration)
        playbackSlider.minimumValue = 0.0
        playbackSlider.value = Float(player.currentPlaybackTime)
    }
    
    @IBAction func changePlaybackTime(_ sender: UISlider, _ event: UIEvent) {
        currentPlaybackTimer?.invalidate()
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .ended:
                player.currentPlaybackTime = TimeInterval(sender.value)
            default:
                break
            }
        }
    }
}

// MARK: Notification register and remover
private extension IJKPlayerViewController {
    private func addPlayerStateObserver(player: IJKFFMoviePlayerController) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChanged(_:)), name:NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(prepareToPlayDidChanged(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidSeekComplete(_:)), name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinished(_:)), name: Notification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
    }
    
    private func removePlayerStateObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Loading state
    @objc private func loadStateDidChanged(_ notification: NSNotification) {
        print(notification)
        print(player.loadState)

        switch player.loadState.rawValue {
        case IJKMPMovieLoadState.playthroughOK.rawValue | IJKMPMovieLoadState.playable.rawValue:
            print("PLAY THROUGH OK")
            print(player.currentPlaybackTime)
            print(player.playableDuration)
            print(player.duration)
            createTrackingPlaybackTimerForPlayer(player)
            enableButtons(true)
            hideLoadingProgress()
        case IJKMPMovieLoadState.stalled.rawValue:
            print("PLAY STOPPED - RETRY")
            player.play()
        default:
            print("OTHER STATE")
        }
    }
    
    @objc private func prepareToPlayDidChanged(_ notification: NSNotification) {
        print(notification)
        print(player.loadState)
    }
    
    @objc private func playbackStateDidChange(_ notification: NSNotification) {
        switch player.playbackState {
        case .stopped:
            print(".stopped")
        case .playing:
            print(".playing")
        case .paused:
            print(".pause")
        case .interrupted:
            print(".interrupted")
        case .seekingForward, .seekingBackward:
            print(".seeking")
            currentPlaybackTimer?.invalidate()
        default:
            print("IJKMPMoviePlayerPlaybackStateDidChange unknow state = \(player.playbackState)")
        }
    }
    
    @objc private func playerDidSeekComplete(_ notification: NSNotification) {
        createTrackingPlaybackTimerForPlayer(player)
    }
    
    @objc private func playbackDidFinished(_ notification: NSNotification) {
        // If have more than 1 dic in userinfo, it should be error
        guard let userInfo = notification.userInfo else {
            // UserInfo not have data => not need to handle
            return
        }
        
        let reason = userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int ?? -1
        let error = userInfo["error"] as? Int ?? -1
        
        switch reason {
        case IJKMPMovieFinishReason.playbackError.rawValue:
            print("playback error \(error)")
            hideLoadingProgress()
        case IJKMPMovieFinishReason.playbackEnded.rawValue:
            print("playback ended")            
        default:
            print("unknow error")
            hideLoadingProgress()
        }
    }
}
