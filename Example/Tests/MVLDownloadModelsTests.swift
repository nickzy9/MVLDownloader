//
//  MVLDownloadModelsTests.swift
//  MVLDownloaderTests
//
//  Created by Aniket on 1/5/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import XCTest
@testable import MVLDownloader

class MVLDownloadModelsTests: XCTestCase {
    
    func testMVLDownloadSourceInitialization() {
        let request = URLRequest(url: URL(string: "https://www.w3.org/TR/PNG/iso_8859-1.txt")!)
        let token = UUID().uuidString
        let source = MVLDownloadSource(urlRequest: request, requestToken: token)
        
        XCTAssertNotNil(source, "source should not be nil")
    }
    
    func testMVLDownloadSourceDeInitialization() {
        let request = URLRequest(url: URL(string: "https://www.w3.org/TR/PNG/iso_8859-1.txt")!)
        let token = UUID().uuidString
        var source: MVLDownloadSource?
        source =  MVLDownloadSource(urlRequest: request, requestToken: token)
        
        source = nil
        XCTAssertNil(source, "source should be nil")
    }
    
    func testMVLDownloaderCompletionBlockMapInitialization() {
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        let completionBlockMap = MVLDownloaderCompletionBlockMap(requestToken: token, completion: completionBlock)
        
        XCTAssertNotNil(completionBlockMap, "completionBlockMap should not be nil")
    }
    
    func testMVLDownloaderCompletionBlockMapDeInitialization() {
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        var completionBlockMap: MVLDownloaderCompletionBlockMap?
            completionBlockMap = MVLDownloaderCompletionBlockMap(requestToken: token, completion: completionBlock)
    
        completionBlockMap = nil
        XCTAssertNil(completionBlockMap, "completionBlockMap should be nil")
    }
    
    func testMVLDownloaderTaskInitialization() {
        let sessionTask = MockURLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        let task = MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock)
        
        XCTAssertNotNil(task, "task should not be nil")
        XCTAssertNotNil(task.downloaderCompletions.first, "downloaderCompletions should not be nil")
        XCTAssertEqual(task.downloaderCompletions.first?.requestToken, token, "downloaderCompletions token should be equal to task token")
    }
    
    func testDownloadKitTaskDeInitialization() {
        let sessionTask = MockURLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        var task: MVLDownloaderTask?
           task = MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock)
        
        task = nil
        
        XCTAssertNil(task, "task should be nil")
    }
}
