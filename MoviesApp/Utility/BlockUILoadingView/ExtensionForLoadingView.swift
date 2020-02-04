//
//  ExtensionForLoadingView.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func blockScreenViewStart(flag: Bool) {
        
        DispatchQueue.main.async {
            
            let tag = TagsGlobalViews.blockScreen.rawValue
            
            guard let currentWindow = UIApplication.shared.keyWindow else {
                return
            }
            
            for v in currentWindow.subviews {
                if v.tag == tag {
                    guard let blv: BlockUILoadingView = v as? BlockUILoadingView else {
                        v.removeFromSuperview()
                        return
                    }
                    
                    blv.dismissView()
                    break
                }
            }
            
            if !flag {
                return
            }
            
            let blview = BlockUILoadingView.fromNib()
            blview.frame = UIScreen.main.bounds
            blview.tag = tag
            blview.activityIndicator.color = ColorScheme.Others.kBaseLoader
            currentWindow.addSubview(blview)
            
        }
    }
    
    func inBlockScreenViewStart(flag: Bool) {
        
        DispatchQueue.main.async {
            
            guard let currentWindow = UIApplication.shared.keyWindow else {
                return
            }
            
            let tag = TagsGlobalViews.inBlockScreen.rawValue
            
            for v in currentWindow.subviews {
                if v.tag == tag {
                    v.removeFromSuperview()
                    break
                }
            }
            
            if !flag {
                return
            }
            
            let heightContainer: CGFloat = 80.0
            
            let w = UIScreen.main.bounds.width
            let h = UIScreen.main.bounds.height
            
            let container = UIView.init(frame: CGRect(x: 0, y: 0, width: heightContainer, height: heightContainer))
            container.tag = tag
            
            container.center = CGPoint(x: w / 2, y: h / 2)
            container.layer.cornerRadius = 10
            container.clipsToBounds = true
            container.backgroundColor = UIColor.clear
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: heightContainer / 4, y: heightContainer / 4, width: heightContainer / 2, height: heightContainer / 2))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .whiteLarge
            loadingIndicator.color = ColorScheme.Others.kBaseLoader
            let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            loadingIndicator.transform = transform
            loadingIndicator.startAnimating()
            
            container.addSubview(loadingIndicator)
            
            currentWindow.addSubview(container)
        }
    }
}
