# MVLDownloader

[![CI Status](https://img.shields.io/travis/niekzy/MVLDownloader.svg?style=flat)](https://travis-ci.org/niekzy/MVLDownloader)
[![Version](https://img.shields.io/cocoapods/v/MVLDownloader.svg?style=flat)](https://cocoapods.org/pods/MVLDownloader)
[![License](https://img.shields.io/cocoapods/l/MVLDownloader.svg?style=flat)](https://cocoapods.org/pods/MVLDownloader)
[![Platform](https://img.shields.io/cocoapods/p/MVLDownloader.svg?style=flat)](https://cocoapods.org/pods/MVLDownloader)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Features

- [x] Asynchronous image/files downloading and caching.
- [x] Loading image from either `URLSession`-based networking.
- [x] Cancelable downloading.

## Requirements
- iOS 10.0+
- Swift 4.0+

## Installation

MVLDownloader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MVLDownloader'
```

## Usage

### Shared Instance

A shared instance of MVDownloader can be use for managing download requests. 

```swift
import MVLDownloader

let downloader = MVLDownloader.shared
```

### Download Image

Use this method to download the image as `UIImage` from given `URL`

```swift
let url = URL(string:  "https://images.unsplash.com/photo-1464550883968-cec281c19761")

MVLDownloader.shared.downloadImage(from: url, completionBlock: { (image, error) in
    guard error == nil else {
        debugPrint("FAILED TO DOWNLOAD IMAGE :\(url!) :", error!)
        return
    }
    
    if let image = image {
        // Use your image
    }
})
```

### Download File

Use this method to download file from given `URL`

```swift
let url = URL(string:  "https://images.unsplash.com/photo-1464550883968-cec281c19761")

MVLDownloader.shared.downloadFile(from: url!, completionBlock: { (data, error) in
    guard error == nil else {
        debugPrint("FAILED TO DOWNLOAD FILE :\(url!) :", error!)
        return
    }
    
    if let unwrappedData = data {
        // Your downloaded file data
    }
})
```

### Download JSON

JSON objects can be downloaded from a given `URL`, the library parses the returned data into the provided `Cdable` data model. 
For example:

```
Raw JSON object
{
  "id": "OevW4fja2No",
  "username": "nicholaskampouris",
  "name": "Nicholas Kampouris"
}
```
Create `Codable` data model 

```swift
struct SampleDataModel: Codable {
    let id, username, name: String
}
```

Pass the model to JSON load method

```swift
let url = URL(string: "https://pastebin.com/raw/wgkJgazE")

MVLDownloader.shared.loadJSON(from: url!, model: SampleDataModel.self, completionBlock: { (model, error) in
    guard error == nil else {
        debugPrint("ERROR: ", error!)
        return
    }
    
    if let model = model {
        // Your json model
    }
})
```

### Cancel Download request example

```swift
let url = URL(string: "https://pastebin.com/raw/wgkJgazE")

let source = MVLDownloader.shared.loadJSON(from: url!, model: SampleDataModel.self, completionBlock: { (model, error) in
    guard error == nil else {
        debugPrint("ERROR: ", error!)
        return
    }
    
    if let model = model {
        // Your json model
    }
})

MVLDownloader.shared.cancelRequest(downloadSource: source)
```

### Manage download cache

#### Set cache size
This library cache request response in cache memory using `URLSession`.
The cache size can be easily configured. 
Default cache size: 50 MB

```swift
let downloader = MVLDownloader(cacheSize: 200 * 1024 * 1024)
```

#### Clear all cache

```swift
MVLDownloader.shared.clearCache()
```

#### Clear cache for specific URL

```swift
let url = URL(string: "https://pastebin.com/raw/wgkJgazE")
MVLDownloader.shared.clearCache(for: url!)
```

## Author

niekzy, `Aniket Sankpal`

## License

MVLDownloader is available under the MIT license. See the LICENSE file for more info.
