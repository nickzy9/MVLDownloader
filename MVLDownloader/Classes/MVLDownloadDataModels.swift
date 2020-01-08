//
//  MVLDownloadDataModels.swift
//  MVLDownloader
//
//  Created by Aniket on 1/4/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import Foundation

/// This structure model is used to referering download source from their Request Token.
public struct MVLDownloadSource {
    public let urlRequest: URLRequest
    public let requestToken: String
}

/// Common completion block for `Data` and `Error`
public typealias MVLCompletionBlock = (Data?, Error?) -> Void

/// A completion block handler with a Request Token to refer a Completion block
public struct MVLDownloaderCompletionBlockMap {
    let requestToken: String
    let completion: MVLCompletionBlock
}

/// This class model is used to create `MVLDownloader` task with `URLSessionTask`, Request Token and
/// an array of `MVLDownloaderCompletionBlockMap` which contains completion block for the task
public class MVLDownloaderTask {
    public let urlSessionTask: URLSessionTask
    public var downloaderCompletions = [MVLDownloaderCompletionBlockMap]()
    
    init(sessionTask: URLSessionTask, requestToken: String, completion: MVLCompletionBlock?) {
        self.urlSessionTask = sessionTask
        if let completion = completion {
            self.downloaderCompletions.append(MVLDownloaderCompletionBlockMap(requestToken: requestToken, completion: completion))
        }
    }
}
