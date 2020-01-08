//
//  MVLDownloadManagerTest.swift
//  MVLDownloaderTests
//
//  Created by Aniket on 1/5/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import XCTest
@testable import MVLDownloader

/// Mock class for URLSessionTask
class MockURLSessionTask: URLSessionTask {
    var cancelled = false
    override func cancel() {
        cancelled = true
    }
}

class MVLDownloadManagerTests: XCTestCase {
    
    let timeout = TimeInterval(20)
    
    override func setUp() {
        MVLDownloader.shared = MVLDownloader(cacheSize: MVLDownloader.DEFAULT_CACHE_SIZE)
    }
    
    func testInitialization() {
        let downloadManager = MVLDownloadManager()
        
        XCTAssertNotNil(downloadManager, "download manager should not be nil")
        XCTAssertNotNil(downloadManager.downloadTasks, "download manager downloadTasks list should not be nil")
    }
    
    func testDeInitialization() {
        var downloadManager: MVLDownloadManager?
        
        downloadManager = MVLDownloadManager()
        downloadManager = nil
        XCTAssertNil(downloadManager, "download manager manager should be nil")
    }
    
    func testAddTask() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let sessionTask = URLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock))
        
        XCTAssertNotNil(downloadManager.downloadTasks[request], "task for given request should exist in download tasks list")
    }
    
    func testGetTaskWhenTaskFound() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let sessionTask = URLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock))
        
        XCTAssertNotNil(downloadManager.downloadTasks[request], "task for given request should exist in download tasks list")
        XCTAssertNotNil(downloadManager.getTask(for: request), "getTask return value should not be nil")
    }
    
    func testGetTaskWhenTaskDoesNotFound() {
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c1976")!)
        
        let task = MVLDownloader.shared.downloadManager.getTask(for: request)
        
        XCTAssertNil(task, "task should be nil")
    }
    
    func testRemoveTask() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let sessionTask = URLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock))
        
        XCTAssertNotNil(downloadManager.downloadTasks[request], "task for given request should exist in download tasks list")
        XCTAssertNotNil(downloadManager.getTask(for: request), "getTask return value should not be nil")
        
        downloadManager.removeTask(for: request)
        
        XCTAssertNil(downloadManager.downloadTasks[request], "task for given request should not exist in download tasks list")
        XCTAssertNil(downloadManager.getTask(for: request), "getTask return value should be nil")
    }
    
    func testIsTaskExist() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let sessionTask = URLSessionTask()
        let token = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock))
        
        XCTAssertTrue(downloadManager.isTaskExist(for: request), "download manager should have task")
    }
    
    func testAddCompletionBlock() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let sessionTask = URLSessionTask()
        let token = UUID().uuidString
        let token2 = UUID().uuidString
        let completionBlock: MVLCompletionBlock = { (_, _) in }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: sessionTask, requestToken: token, completion: completionBlock))
        downloadManager.addCompletionBlock(for: request, downloaderCompletion: MVLDownloaderCompletionBlockMap(requestToken: token2, completion: completionBlock))
        
        let completionBlock1 = downloadManager.downloadTasks[request]?.downloaderCompletions.first(where: { $0.requestToken == token })
        let completionBlock2 = downloadManager.downloadTasks[request]?.downloaderCompletions.first(where: { $0.requestToken == token2 })
        
        XCTAssertNotNil(completionBlock1, "completion block 1 should not be nil")
        XCTAssertNotNil(completionBlock2, "completion block 2 should not be nil")
    }
    
    func testCancelCompletionBlockForSingleCompletion() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let task = MockURLSessionTask()
        let token = UUID().uuidString
        var error: Error?
        let expectation = self.expectation(description: "handler should receive error upon cancellation")
        let completionBlock: MVLCompletionBlock = { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: task, requestToken: token, completion: completionBlock))
        downloadManager.cancelCompletionBlock(for: MVLDownloadSource(urlRequest: request, requestToken: token))
    
        waitForExpectations(timeout: timeout, handler: nil)
        
        let downloaderCompletions = downloadManager.downloadTasks[request]?.downloaderCompletions.first(where: { $0.requestToken == token })
        XCTAssertNil(downloaderCompletions, "downloaderCompletions should be nil")
        XCTAssertNil(downloadManager.downloadTasks[request], "request should not exist in download tasks list")
        XCTAssertNotNil(error, "error should not be nil")
        XCTAssertTrue(task.cancelled, "task should be cancelled")
    }
    
    func testCancelCompletionBlockForMultipleCompletionsOfSameRequest() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let task = MockURLSessionTask()
        let token = UUID().uuidString
        let token2 = UUID().uuidString
        var error: Error?
        let expectation = self.expectation(description: "Completion block should receive error upon cancellation")
        let completionBlock1: MVLCompletionBlock = { (_, _) in }
        let completionBlock2: MVLCompletionBlock = { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: task, requestToken: token, completion: completionBlock1))
        downloadManager.addCompletionBlock(for: request, downloaderCompletion: MVLDownloaderCompletionBlockMap(requestToken: token2, completion: completionBlock2))
        downloadManager.cancelCompletionBlock(for: MVLDownloadSource(urlRequest: request, requestToken: token2))
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        let downloaderCompletions1 = downloadManager.downloadTasks[request]?.downloaderCompletions.first(where: { $0.requestToken == token })
        let downloaderCompletions2 = downloadManager.downloadTasks[request]?.downloaderCompletions.first(where: { $0.requestToken == token2 })
        
        XCTAssertNotNil(downloaderCompletions1, "downloaderCompletions 1 should not be nil")
        XCTAssertNotNil(downloadManager.downloadTasks[request], "request should exist in download tasks list")
        XCTAssertNil(downloaderCompletions2, "downloaderCompletions 2 should be nil")
        XCTAssertNotNil(error, "error should not be nil")
        XCTAssertFalse(task.cancelled, "task should not be cancelled")
    }
    
    func testFireAllCompletions() {
        let downloadManager = MVLDownloader.shared.downloadManager
        let request = URLRequest(url: URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")!)
        let task = MockURLSessionTask()
        let token1 = UUID().uuidString
        let token2 = UUID().uuidString
        var data1: Data?
        var data2: Data?
        var error1: Error?
        var error2: Error?
        let expectation1 = self.expectation(description: "downloaderCompletions 1 should receive data and error")
        let expectation2 = self.expectation(description: "downloaderCompletions 2 should receive data and error")
        
        let completionBlock1: MVLCompletionBlock = { (data, error) in
            data1 = data
            error1 = error
            expectation1.fulfill()
        }
        let completionBlock2: MVLCompletionBlock = { (data, error) in
            data2 = data
            error2 = error
            expectation2.fulfill()
        }
        
        downloadManager.addTask(for: request, task: MVLDownloaderTask(sessionTask: task, requestToken: token1, completion: completionBlock1))
        downloadManager.addCompletionBlock(for: request, downloaderCompletion: MVLDownloaderCompletionBlockMap(requestToken: token2, completion: completionBlock2))
        downloadManager.fireCompletionBlock(for: request, data: Data(), error: MVLDownloadError.DownloadTerminated)
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(data1, "data 1 should not be nil")
        XCTAssertNotNil(data2, "data 2 should not be nil")
        XCTAssertNotNil(error1, "error 1 should not be nil")
        XCTAssertNotNil(error2, "error 2 should not be nil")
        XCTAssertNil(downloadManager.downloadTasks[request], "request should not be exist in download tasks list")
        XCTAssertFalse(task.cancelled, "task should not be cancelled")
    }
}

