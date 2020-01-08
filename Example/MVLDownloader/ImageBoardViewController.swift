//
//  ImageCollectionViewCell.swift
//  MVLDownloaderExample
//
//  Created by Aniket on 1/7/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import UIKit
import MVLDownloader

/// Used to display image
class ImageBoardViewController: UIViewController {
    
    // Mark: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var imageUrls = [URL]()
    var downloader: MVLDownloader!
    
    private var isFetching = false
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloader = MVLDownloader(cacheSize: 200 * 1024 * 1024)
        downloadPastBinImageUrls()
        setupView()
    }
    
    // Setup elements
    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        title = "MVLDownloader"
        
        // Add refresh control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    
        self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    // Pull to refresh
    @objc func refresh() {
        downloader.clearCache()
        downloadPastBinImageUrls()
    }
    
    // This method download the image url JSON
    func downloadPastBinImageUrls() {
        guard let url = imageJson else { return }
        
        isFetching = true
        loadingIndicator.startAnimating()
        _ = downloader.loadJSON(from: url, model: [PasteBinImageModel].self, completionBlock: { (entities, error) in
            self.isFetching = false
            guard error == nil else {
                debugPrint("ERROR: ", error!)
                return
            }
            
            guard let entities = entities else {
                debugPrint("ERROR: NO DATA FOUND")
                return
            }
            
            var newImageUrls = [URL]()
            
            for entity in entities {
                if let url = URL(string: entity.urls.regular) {
                    newImageUrls.append(url)
                }
            }
            
            // UI updates
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                    self.imageUrls.removeAll()
                }
                self.imageUrls.append(contentsOf: newImageUrls)
                self.collectionView.reloadData()
                self.loadingIndicator.stopAnimating()
            }
        })
    }
}

// MARK: - UICollectionViewDataSource to set images
extension ImageBoardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.url = imageUrls[indexPath.row]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImageBoardViewController: UICollectionViewDelegateFlowLayout {
    /// Load more images when scroll down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height > 0 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height {
            if !isFetching {
                downloadPastBinImageUrls()
            }
        }
    }
}

