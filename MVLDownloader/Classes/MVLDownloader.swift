//
//  MVLDownloader.swift
//  MVLDownloader
//
//  Created by Aniket on 1/4/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import UIKit

/// This class is responsible for the entire downloading process.
/// It offers:
/// 1. Image downloading from `URL` and returning image as `UIImage` object
/// 2. File downloading from `URL` and returning content as `Data` object
/// 3. `JSON` parsing from `URL` and returning respective `Codable` model object
///
/// `MVLDownloader` utilizes `URLSession` for network request. It can handle multiple parallel requests.
/// I addition it offers memory caching using `URLCache`

public class MVLDownloader {
    // MARK: - Properties
    let urlSession: URLSession
    let urlCache: URLCache
    var downloadManager = MVLDownloadManager()
    
    // MARK: - Static properties
    
    /// Default Cache size is 50 MBs
    public static let DEFAULT_CACHE_SIZE = 50 * 1024 * 1024
    public static var shared = MVLDownloader(cacheSize: MVLDownloader.DEFAULT_CACHE_SIZE)
    
    // MARK: - Initializer
    
    /// Initialize `MVLDownloader` with cache size
    public init(cacheSize: Int) {
        urlCache = URLCache(memoryCapacity: cacheSize, diskCapacity: 0, diskPath: nil)
        let config = URLSessionConfiguration.default
        config.urlCache = urlCache
        urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Deinitializer
    deinit {
        urlSession.invalidateAndCancel()
    }
    
    /// Use this method to download image from `URL`
    /// This method creates a  download image `URLRequest` for `URL`. On completion it's receive a `Data` object and try to parse into `UIImage` object.
    /// On success `UIIImage` object will be returned in completion block
    /// On failure `Error` object will be returned in completion block
    ///
    /// - Parameters:
    ///   - url: The URL to the image to download
    ///   - completion: A block called once the image download is completed.
    public func downloadImage(from url: URL,
                              completionBlock: @escaping (_ data: UIImage?, _ error: Error?) -> Void) -> MVLDownloadSource {
        let urlRequest = URLRequest(url: url)
        let requestToken = UUID().uuidString
        
        let downloadSource = MVLDownloadSource(urlRequest: urlRequest, requestToken: requestToken)
        
        performDataTask(for: downloadSource) { (data, error) in
            guard error == nil else {
                completionBlock(nil, error)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completionBlock(nil, MVLDownloadError.DataNotFound)
                return
            }
            completionBlock(image, nil)
        }
        
        return downloadSource
    }
    
    
    /// Use this method to download files from `URL`
    /// This method creates a `URLRequest` for `URL`. On completion raw data is returned
    /// On success `Data` object will be returned in completion block
    /// On failure `Error` object will be returned in completion block
    ///
    /// - Parameters:
    ///   - url: The URL to the file to download
    ///   - completion: A block called once the file download is completed.
    public func downloadFile(from url: URL, completionBlock: @escaping MVLCompletionBlock) -> MVLDownloadSource {
        let urlRequest = URLRequest(url: url)
        let requestToken = UUID().uuidString
        
        let downloadSource = MVLDownloadSource(urlRequest: urlRequest, requestToken: requestToken)
        
        performDataTask(for: downloadSource, completion: completionBlock)
        
        return MVLDownloadSource(urlRequest: urlRequest, requestToken: requestToken)
    }
    
    
    /// Use this method to parse `JSON` object  from `URL`.
    /// This method creates a `URLRequest` for `URL`. On completion data from the response is parsed as json, based on the provided model object provided to the function.
    /// The provided model should  conform `Codable` protocol.
    /// On success `Codable` object will be returned in completion block
    /// On failure `Error` object will be returned in completion block
    ///
    ///
    /// - Parameters:
    ///   - url: The URL to the `JSON` to parse
    ///   - model: Expected `Codable` model
    ///   - completionBlock: A block called once the process is completed.
    public func loadJSON<T>(from url: URL, model: T.Type,
                            completionBlock: @escaping (_ data: T?, _ error: Error?)  -> Void) -> MVLDownloadSource where T: Codable {
        let urlRequest = URLRequest(url: url)
        let requestToken = UUID().uuidString
        
        let downloadSource = MVLDownloadSource(urlRequest: urlRequest, requestToken: requestToken)
        
        performDataTask(for: downloadSource) { (data, error) in
            guard error == nil else {
                completionBlock(nil, error)
                return
            }
            guard let data = data else {
                completionBlock(nil, MVLDownloadError.DataNotFound)
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completionBlock(result, nil)
            } catch let error {
                completionBlock(nil, error)
            }
        }
        
        return downloadSource
    }
    
    /// This method cancel the download request for given download source i.e `MVLDownloadSource`
    /// - Parameter source: `MVLDownloadSource` object
    public func cancelRequest(downloadSource source: MVLDownloadSource) {
        downloadManager.cancelCompletionBlock(for: source)
    }
    
    
    /// This method is the internal method of this class used to process all `URLRequest`(s).
    /// It is responsible for creating `URLSession` data task and sending the task responsibilities to `MVLDownloadManager`
    /// - Parameters:
    ///   - downloadSource: `MVLDownloadSource` object which includes `URLRequest` and request token.
    ///   - completion: A block called once the data task is completed.
    func performDataTask(for downloadSource: MVLDownloadSource,
                         completion: @escaping MVLCompletionBlock) {
        
        /// Check first if the `MVLDownloaderTask` exist for the current request. If yes then exit the execution and pass the completion handler for this call.
        if downloadManager.isTaskExist(for: downloadSource.urlRequest) {
            let completion = MVLDownloaderCompletionBlockMap(requestToken: downloadSource.requestToken, completion: completion)
            downloadManager.addCompletionBlock(for: downloadSource.urlRequest, downloaderCompletion: completion)
            return
        }
        
        /// Create data task from given `URLRequest` and get the response data. For old request `URLSession` will fetch the response from cache.
        let task = urlSession.dataTask(with: downloadSource.urlRequest) { [weak self] (data, _, error) in
            guard let `self` = self else {
                return
            }
            
            /// If error found fire completion block with an error
            guard error == nil else {
                self.downloadManager.fireCompletionBlock(for: downloadSource.urlRequest, data: nil, error: error)
                return
            }
            
            /// If  data is nil fire completion block with no data error
            guard let data = data else {
                self.downloadManager.fireCompletionBlock(for: downloadSource.urlRequest, data: nil, error: MVLDownloadError.DataNotFound)
                return
            }
            
            /// Fire completion block with data
            self.downloadManager.fireCompletionBlock(for: downloadSource.urlRequest, data: data, error: nil)
        }
        
        /// The current request with its completion block are inserted in `MVLDownloadManager`.
        let downloaderTask = MVLDownloaderTask(sessionTask: task, requestToken: downloadSource.requestToken, completion: completion)
        downloadManager.addTask(for: downloadSource.urlRequest, task: downloaderTask)
        task.resume()
    }
}

// MARK: - Cache method
extension MVLDownloader {
    
    /// Use this method to clear all cache
    public func clearCache() {
        urlCache.removeAllCachedResponses()
    }
    
    /// Use this method to clear the cache for specific `URL`
    /// - Parameter url: `URL` object
    public func clearCache(for url: URL) {
        let request = URLRequest(url: url)
        urlCache.removeCachedResponse(for: request)
    }
}
