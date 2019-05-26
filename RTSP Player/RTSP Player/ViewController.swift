//
//  ViewController.swift
//  RTSP Player
//
//  Created by Hoang Minh Nhat on 5/24/19.
//  Copyright © 2019 GST. All rights reserved.
//

import UIKit
import IJKMediaFramework

class ViewController: UIViewController {
    var player: IJKFFMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = IJKFFOptions.byDefault()
        let url = URL(string: "rtsp://170.93.143.139/rtplive/470011e600ef003a004ee33696235daa")
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)!
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

