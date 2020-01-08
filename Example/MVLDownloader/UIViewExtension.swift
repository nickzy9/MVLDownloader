//
//  UIViewExtension.swift
//  MVLDownloader_Example
//
//  Created by Aniket on 1/7/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import UIKit

// Custom animation
extension UIView {
    func startLoading() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.duration = 1.5
        animation.fromValue = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        animation.toValue = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        
        self.layer.add(animation, forKey: "loading")
    }

    func stopLoading() {
        self.layer.removeAnimation(forKey: "loading")
        self.backgroundColor = #colorLiteral(red: 0.9349791408, green: 0.9351356626, blue: 0.9349585176, alpha: 1)
    }
}
