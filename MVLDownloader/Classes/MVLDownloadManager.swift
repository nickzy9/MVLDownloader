//
//  MVLDownloadManager.swift
//  MVLDownloader
//
//  Created by Aniket on 1/4/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import Foundation

/// This class is more like an internal download request manager.
/// It's responsible for managing a dictionary of currently active download tasks. Including download cancellation request.
class MVLDownloadManager {
    // MARK: - Properties
    var downloadTasks: [URLRequest: MVLDownloaderTask]
    
    // MARK: - Initializer
    init() {
        downloadTasks = [:]
    }
    
    /// This method will add download task for given request
    /// - Parameters:
    ///   - request: The `URLRequest` for task to be added
    ///   - task: The `MVLDownloaderTask `object which contains the URLSessionTask and CompletionBlocks for the request.
    func addTask(for request: URLRequest, task: MVLDownloaderTask) {
        downloadTasks[request] = task
    }
    
    /// This method return download task for given request
    /// - Parameter request: The `MVLDownloaderTask `object which contains the URLSessionTask and CompletionBlocks for the request.
    func getTask(for request: URLRequest) -> MVLDownloaderTask? {
        return downloadTasks[request]
    }
    
    /// This method remove download task for given request
    /// - Parameter request: The `URLRequest` object which to be removed
    func removeTask(for request: URLRequest) {
        downloadTasks.removeValue(forKey: request)
    }
    
    ///  This method check if the download task exist for given request
    /// - Parameter request: The `URLRequest` object which to be checked
    func isTaskExist(for request: URLRequest) -> Bool {
        return downloadTasks[request] != nil
    }
    
    /// This method  adds a new completion block for a given existing request
    /// - Parameters:
    ///   - request: The `URLRequest` object which the block to be added
    ///   - completion: The `MVLDownloaderCompletionBlockMap` object which contains the RequestToken and CompletionBlock with data and error object
    func addCompletionBlock(for request: URLRequest, downloaderCompletion completionBlock: MVLDownloaderCompletionBlockMap) {
        if let task = downloadTasks[request] {
            task.downloaderCompletions.append(completionBlock)
        }
    }
    
    /// This method  cancel the request for given download source (i.e. `MVLDownloadSource`) by removing its completion block from the list
    /// - Parameter source: The `MVLDownloadSource` for the request to be cancelled.
    func cancelCompletionBlock(for source: MVLDownloadSource) {
        guard let task = downloadTasks[source.urlRequest] else { return }
        
        if let index = task.downloaderCompletions.firstIndex(where: { $0.requestToken == source.requestToken }) {
            let closureReference = task.downloaderCompletions.remove(at: index)
            closureReference.completion(nil, MVLDownloadError.DownloadTerminated)
        }
        
        if task.downloaderCompletions.isEmpty {
            task.urlSessionTask.cancel()
            downloadTasks.removeValue(forKey: source.urlRequest)
        }
    }
    
    
    /// Fire all completion block for given request with data / error. On completion remove all completion blocks for the request
    /// - Parameters:
    ///   - request: The `URLRequest` for completion block to be fired
    ///   - data: `Data` to be passed in completion block
    ///   - error: `Error` to be passed in completion block
    func fireCompletionBlock(for request: URLRequest,
                        data: Data?,
                        error: Error?) {
        if let downloaderCompletions = downloadTasks[request]?.downloaderCompletions {
            for downloaderCompletion in downloaderCompletions {
                downloaderCompletion.completion(data, error)
            }
        }
        downloadTasks.removeValue(forKey: request)
    }
}

