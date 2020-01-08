//
//  MVLDownloadError.swift
//  MVLDownloader
//
//  Created by Aniket on 1/4/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import Foundation

/// Custom download error
public enum MVLDownloadError: Error {
    case DownloadTerminated
    case DownloadFailed
    case DataNotFound
}
