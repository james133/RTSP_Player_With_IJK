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
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textFieldURL.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons(false)
    }
    
    private func setupPlayer(with url: URL) {
        if self.player != nil {
            self.player.view.removeFromSuperview()
        }
        
        let options = IJKFFOptions.byDefault()
        
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)!
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        player.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        player.view.frame = viewPlayer.bounds
        player.scalingMode = IJKMPMovieScalingMode.aspectFit
        player.shouldAutoplay = true
        
        viewPlayer.autoresizesSubviews = true
        viewPlayer.addSubview(player.view)
        
        self.player = player
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
    
    @objc private func checkPlayerState() {
        if player.isPlaying() == true {
            hideLoadingProgress()
            timer?.invalidate()
            enableButtons(true)
        }
        
        print("Checking Player State")
    }
    
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
}

extension IJKPlayerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        // rtsp://170.93.143.139/rtplive/470011e600ef003a004ee33696235daa
        let urlString = textField.text
        playVideo(with: urlString ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
