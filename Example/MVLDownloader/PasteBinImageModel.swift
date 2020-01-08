//
//  PasteBinImageModel.swift
//  MVLDownloaderExample
//
//  Created by Aniket on 1/7/20.
//  Copyright © 2020 Aniket. All rights reserved.
//

import Foundation

// MARK: - PasteBinImageModel
struct PasteBinImageModel: Codable {
    let user: User
    let urls: Urls

    enum CodingKeys: String, CodingKey {
        case user, urls
    }
}

// MARK: - User
struct User: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}
