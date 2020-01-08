//
//  MVLDownloaderTests.swift
//  MVLDownloaderTests
//
//  Created by Aniket on 1/4/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import XCTest
@testable import MVLDownloader

class MVLDownloaderTests: XCTestCase {
    
    let timeout = TimeInterval(80)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MVLDownloader.shared.urlCache.removeAllCachedResponses()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MVLDownloader.shared.urlCache.removeAllCachedResponses()
    }
    
    func testInitialization() {
        let size = 8 * 1024 * 1024
        let downloader = MVLDownloader(cacheSize: size)
        
        XCTAssertNotNil(downloader, "downloader should not be nil")
        XCTAssertNotNil(downloader.urlCache, "urlCache should not be nil")
        XCTAssertNotNil(downloader.urlSession, "urlSession should not be nil")
        XCTAssertNotNil(downloader.downloadManager, "download manager should not be nil")
        XCTAssertTrue(downloader.urlCache.memoryCapacity == size, "urlCache memory should be same 8 MB")
    }
    
    func testSingltonInitialization() {
        let downloader = MVLDownloader.shared
        XCTAssertNotNil(downloader, "downloader should not be nil")
        XCTAssertNotNil(downloader.urlCache, "urlCache should not be nil")
        XCTAssertNotNil(downloader.urlSession, "urlSession should not be nil")
        XCTAssertNotNil(downloader.downloadManager, "download manager should not be nil")
        XCTAssertTrue(downloader.urlCache.memoryCapacity == MVLDownloader.DEFAULT_CACHE_SIZE, "urlCache size should be same as default cache size")
    }
    
    func testDeInitialization() {
        let size = 10 * 1024 * 1024
        var downloader: MVLDownloader? = MVLDownloader(cacheSize: size)
        downloader = nil
        XCTAssertNil(downloader, "downloader should be nil")
    }
    
    func testDownloadImage() {
        let url = URL(string:  "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "image download should be successful")
        var result: UIImage?
        
        _ = downloader.downloadImage(from: url!) { (data, _) in
            result = data
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
    }
    
    func testInvalidImageDownload() {
        let url = URL(string: "https://images.unsplash.com/photo-14645")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "image download should return an error")
        var error: Error?
        
        _ = downloader.downloadImage(from: url!) { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(error, "error should not be nil")
    }
    
    func testDownloadFile() {
        let url = URL(string: "https://www.w3.org/TR/PNG/iso_8859-1.txt")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should be successful")
        var result: Data?
        
        let source = downloader.downloadFile(from: url!) { (data, er) in
            result = data
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNotNil(source.urlRequest.url, "source url should not be nil")
        XCTAssertEqual(source.urlRequest.url, url, "source url should be equal to request url")
    }
    
    func testInvalidDownloadFile() {
        let url = URL(string: "https://imagesunsplash.com")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should return an error")
        var error: Error?
        
        _ = downloader.downloadFile(from: url!) { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(error, "error should not be nil")
    }
    
    func testLoadJSON() {
        struct SampleJson: Codable {
            let width: Int
            let height: Int
            let color: String
        }
        
        let url = URL(string: "https://pastebin.com/raw/wgkJgazE")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "json download should be successful")
        var result: [SampleJson]?
        
        _ = downloader.loadJSON(from: url!, model: [SampleJson].self) { (data, _) in
            result = data
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
    }
    
    func testInvalidLoadJSON() {
        struct SampleJson: Codable {
            let width: Int
            let height: Int
            let color: String
        }
        let url = URL(string: "https://pastebin.com/raw") // invalid url
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "json download should be successful")
        var error: Error?
        
        _ = downloader.loadJSON(from: url!, model: [SampleJson].self) { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(error, "error should not be nil")
    }
    
    func testLoadJSONWithInvalideModel() {
        struct SampleJson: Codable {
            let testVariable: Int
        }
        let url = URL(string: "https://pastebin.com/raw/wgkJgazE")
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "json download should be successful")
        var error: Error?
        
        _ = downloader.loadJSON(from: url!, model: [SampleJson].self) { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(error, "error should not be nil")
    }
    
    func testPerformDataTask() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request = URLRequest(url: url!)
        let token = UUID().uuidString
        let source = MVLDownloadSource(urlRequest: request, requestToken: token)
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should be successful")
        var result: Data?
        
        downloader.performDataTask(for: source) { (data, _) in
            result = data
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
    }
    
    func testIfLoadingFromCache() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request = URLRequest(url: url!)
        let token = UUID().uuidString
        let source = MVLDownloadSource(urlRequest: request, requestToken: token)
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should be successful")
        var result: Data?
        
        downloader.performDataTask(for: source) { (data, _) in
            result = data
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNotNil(downloader.urlCache.cachedResponse(for: request), "result should be cached")
    }
    
    func testDownloadCacheAfterClearingCache() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request = URLRequest(url: url!)
        let token = UUID().uuidString
        let source = MVLDownloadSource(urlRequest: request, requestToken: token)
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should be successful")
        var result: Data?
        
        downloader.performDataTask(for: source) { (data, _) in
            result = data
            downloader.urlCache.removeAllCachedResponses()
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result, "result should not be nil")
        XCTAssertNil(downloader.urlCache.cachedResponse(for: request), "result should not be cached")
    }
    
    func testSameDownloadsForMultipleRequest() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request1 = URLRequest(url: url!)
        let request2 = URLRequest(url: url!)
        let token1 = UUID().uuidString
        let token2 = UUID().uuidString
        let source1 = MVLDownloadSource(urlRequest: request1, requestToken: token1)
        let source2 = MVLDownloadSource(urlRequest: request2, requestToken: token2)
        var result1: Data?
        var result2: Data?
        let expectation1 = expectation(description: "data download 1 should be successful")
        let expectation2 = expectation(description: "data download 2 should be successful")
        
        let downloader = MVLDownloader.shared
        
        downloader.performDataTask(for: source1) { (data, _) in
            result1 = data
            expectation1.fulfill()
        }
        
        downloader.performDataTask(for: source2) { (data, _) in
            result2 = data
            expectation2.fulfill()
        }
        
        // Then
        let completionBlock1 = downloader.downloadManager.downloadTasks[request1]?.downloaderCompletions.first(where: { $0.requestToken == token1 })
        let completionBlock2 = downloader.downloadManager.downloadTasks[request2]?.downloaderCompletions.first(where: { $0.requestToken == token2 })
        
        XCTAssertNotNil(completionBlock1, "download 1 should have completion block assigned with download manager")
        XCTAssertNotNil(completionBlock2, "download 1 should have completion block assigned with download manager")
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result1, "result 1 should not be nil")
        XCTAssertNotNil(result2, "result 2 should not be nil")
    }
    
    func testMultipleSameDownloadsWithSingleCancel() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request1 = URLRequest(url: url!)
        let request2 = URLRequest(url: url!)
        let token1 = UUID().uuidString
        let token2 = UUID().uuidString
        let source1 = MVLDownloadSource(urlRequest: request1, requestToken: token1)
        let source2 = MVLDownloadSource(urlRequest: request2, requestToken: token2)
        
        var result1: Data?
        var error2: Error?
        
        let expectation1 = expectation(description: "data download 1 should be successful")
        let expectation2 = expectation(description: "data download 2 should be successful")
        let downloader = MVLDownloader.shared
        
        downloader.performDataTask(for: source1) { (data, _) in
            result1 = data
            expectation1.fulfill()
        }
        
        downloader.performDataTask(for: source2) { (_, error) in
            error2 = error
            expectation2.fulfill()
        }
        
        downloader.cancelRequest(downloadSource: source2)
        
        let completionBlock1 = downloader.downloadManager.downloadTasks[request1]?.downloaderCompletions.first(where: { $0.requestToken == token1 })
        
        XCTAssertNotNil(completionBlock1, "download 1 should have completion block assigned with download manager")
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(result1, "result 1 should not be nil")
        XCTAssertNotNil(error2, "error 2 should not be nil")
    }
    
    func testDownloadCancel() {
        let url = URL(string: "https://images.unsplash.com/photo-1464550883968-cec281c19761")
        let request = URLRequest(url: url!)
        let token = UUID().uuidString
        let source = MVLDownloadSource(urlRequest: request, requestToken: token)
        let downloader = MVLDownloader.shared
        let expectation = self.expectation(description: "data download should be successful")
        var error: Error?
        
        downloader.performDataTask(for: source) { (_, e) in
            error = e
            expectation.fulfill()
        }
        
        downloader.cancelRequest(downloadSource: source)
        
        waitForExpectations(timeout: timeout, handler: nil)
        XCTAssertNotNil(error, "error should not be nil")
    }
}

