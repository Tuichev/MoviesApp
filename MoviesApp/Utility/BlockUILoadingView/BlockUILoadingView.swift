//
//  BlockUILoadingView.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit

class BlockUILoadingView: UIView {
    
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var kdView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let duration: Double = 0.25
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showBackGround()
        setupView()
    }
    
    class func fromNib() -> BlockUILoadingView {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BlockUILoadingView
    }
    
    func setupView() {
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        activityIndicator.transform = transform
    }
    
    func showBackGround() {
        UIView.animate(withDuration: duration, animations: {
            self.backgroundContainerView.alpha = 0.40
        })
    }
    
    func dismissView() {
        UIView.animate(withDuration: duration, animations: {
            self.backgroundContainerView.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
