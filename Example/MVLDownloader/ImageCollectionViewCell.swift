//
//  ImageCollectionViewCell.swift
//  MVLDownloaderExample
//
//  Created by Aniket on 1/7/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import UIKit
import MVLDownloader

/// Image download status to update UI
enum ImageDownloadState {
    case Success
    case Failed
    case Loading
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    // Mark: Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    var downloadSource: MVLDownloadSource?
    let downloader = MVLDownloader.shared
    
    var url: URL! {
        didSet {
            guard let url = url else {
                return
            }
            downloadImage(url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let source = downloadSource {
            downloader.cancelRequest(downloadSource: source)
        }
        imageView.image = nil
        imageView.isHidden = true
        imageView.alpha = 0
        actionButton.isHidden = false
        actionButton.tag = 0
        actionButton.alpha = 1
        bgView.stopLoading()
    }
    
    func downloadImage(_ url: URL) {
        self.updateState(state: .Loading)
        downloadSource = downloader.downloadImage(from: url, completionBlock: { (image, error) in
            guard error == nil else {
                debugPrint("ERROR FAILED TO DOWNLOAD IMAGE :\(self.url!) :", error!)
                self.updateState(state: .Failed)
                return
            }
            
            guard let image = image else {
                debugPrint("ERROR: IMAGE NOT FOUND :\(self.url!) :")
                self.updateState(state: .Failed)
                return
            }
            
            self.updateState(state: .Success, image: image)
        })
    }
    
    /// This method update the UI state of the cell
    /// - Parameters:
    ///   - state: Type of state to display
    ///   - image: Set Image if state is success
    func updateState(state: ImageDownloadState, image: UIImage? = nil) {
        switch state {
        case .Loading:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    self.bgView.startLoading()
                    self.actionButton.tag = 1
                    self.actionButton.isHidden = false
                    self.actionButton.setTitle("Cancel", for: .normal)
                })
            }
            break
        case .Failed:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    self.bgView.stopLoading()
                    self.actionButton.tag = 0
                    self.actionButton.isHidden = false
                    self.actionButton.setTitle("Try Again!", for: .normal)
                })
            }
            break
        case .Success:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: {
                    self.bgView.stopLoading()
                    self.actionButton.isHidden = true
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    self.imageView.alpha = 1
                })
            }
            break
        }
    }
    
    /// Trigger ` Cancel/Try Again`  action based on button tag 1 for cancel download  else download again
    @IBAction func actionButton_TouchUpInside(_ sender: UIButton) {
        if sender.tag == 1 {
            if let source = downloadSource {
                downloader.cancelRequest(downloadSource: source)
            }
            updateState(state: .Failed)
            return
        }
        
        if let url = url {
            downloadImage(url)
        }
    }
}
