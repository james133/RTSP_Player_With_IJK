//
//  IJKPlayerViewController.swift
//  RTSP Player
//
//  Created by Hoang Minh Nhat on 5/24/19.
//  Copyright © 2019 GST. All rights reserved.
//

import UIKit
import IJKMediaFramework

class IJKPlayerViewController: UIViewController {

    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    
    private var player: IJKFFMoviePlayerController!
    private weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textFieldURL.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReplayStream),
            name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil

        player.stop()
        player.shutdown()
        player = nil
    }
    
    deinit {
//        timer?.invalidate()
//        timer = nil
//
//        player.stop()
//        player.shutdown()
//        player = nil
    }
    
    @objc private func handleReplayStream() {
        if !player.isPlaying() {
            self.player.play()
        }
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
        
        viewPlayer.autoresizesSubviews = true
        viewPlayer.addSubview(player.view)
        
        self.player = player
    }
    
    private func settingOptionForPlayer(_ options: IJKFFOptions) {
        // Use hardware decode
//        options.setPlayerOptionIntValue(1, forKey: "videotoolbox")
        
        
        // Use tcp instead of udp
//        options.setFormatOptionValue("tcp", forKey: "rtsp_transport")
        // User-agent
        options.setFormatOptionValue("rtsp-player", forKey: "user-agent")
        
        options.setOptionIntValue(0, forKey: "packet-buffering", of: kIJKFFOptionCategoryPlayer)
        options.setOptionValue("nobuffer", forKey: "fflags", of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(512 * 1024, forKey: "max-buffer-size", of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(5, forKey: "min-frames", of: kIJKFFOptionCategoryPlayer)
        options.setOptionIntValue(4096, forKey: "probsize", of: kIJKFFOptionCategoryFormat)
        options.setOptionIntValue(2000000, forKey: "analyzeduration", of: kIJKFFOptionCategoryFormat)
        
        options.setOptionIntValue(32, forKey: "probesize", of: kIJKFFOptionCategoryFormat)
        options.setOptionValue("ext", forKey: "sync", of: kIJKFFOptionCategoryFormat)
    }
    
    private func playVideo(with url: String) {
        guard let url = URL(string: url) else {
            print("URL Invalid")
            return
        }
        
        showLoadingProgress(for: viewPlayer)
        setupPlayer(with: url)
        player.prepareToPlay()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkPlayerState), userInfo: nil, repeats: true)
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
    }
    
    @IBAction func invokeButtonTakeImage(_ sender: UIButton) {
        if let screenShotImage = player.thumbnailImageAtCurrentTime() {            
            print(screenShotImage)
            UIImageWriteToSavedPhotosAlbum(screenShotImage, self, nil, nil)
        } else {
            print("Save image failed")
        }
    }
    
    
}

extension IJKPlayerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        // rtsp://170.93.143.139/rtplive/470011e600ef003a004ee33696235daa
        //rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov
        if textField.text?.count == 0 {
//            textField.text = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
            textField.text = "rtsp://admin:1234qwer@192.168.1.7:554/onvif1"
        }
        let urlString = textField.text
        playVideo(with: urlString ?? "rtsp://admin:1234qwer@192.168.0.174:554/onvif1")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension IJKPlayerViewController {
    @objc private func checkPlayerState() {
        if player.isPlaying() == true {
            hideLoadingProgress()
            timer?.invalidate()
            enableButtons(true)
        }
        
        print("Checking Player State")
    }
}

// MARK: UI ralated
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

// MARK: Notification register and remover
private extension IJKPlayerViewController {
    
}
