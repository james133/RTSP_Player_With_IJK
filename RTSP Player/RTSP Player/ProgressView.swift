//
//  ProgressView.swift
//  RTSP Player
//
//  Created by Hoang Minh Nhat on 5/24/19.
//  Copyright © 2019 GST. All rights reserved.
//

import UIKit

public class ProgressView: UIView {
    
    public static var TagValue: Int = 9987
    
    public static var ProgressViewSize = CGSize(width: 80, height: 80)
    public static var IndicatorViewSize = CGSize(width: 40, height: 40)
    
    private var loadingView: UIView = UIView()
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initComponents()
    }
    
    private func initComponents() {
        loadingView.frame = CGRect(x: 0, y: 0, width: ProgressView.ProgressViewSize.width, height: ProgressView.ProgressViewSize.height)
        loadingView.center = center
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        addSubview(loadingView)
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: ProgressView.IndicatorViewSize.width, height: ProgressView.IndicatorViewSize.height)
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(activityIndicator)
        addSubview(loadingView)
        activityIndicator.startAnimating()
    }
    
    public static func show(view: UIView?) {
        guard let view = view else {
            return
        }
        
        let progressView = ProgressView(frame: view.bounds)
        progressView.tag = ProgressView.TagValue
        
        view.addSubview(progressView)
    }
    
    public static func hide(view: UIView?) {
        guard let view = view else {
            return
        }
        
        guard let progressView = view.viewWithTag(ProgressView.TagValue) else {
            return
        }
        progressView.removeFromSuperview()
    }
}
