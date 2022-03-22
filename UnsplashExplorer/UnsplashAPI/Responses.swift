//
//  Responses.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation

// MARK: - PhotoSearchResult
struct PhotoSearchResult: Decodable {
    let total, totalPages: Int
    let results: [PhotoInfo]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - PhotoInfo
struct PhotoInfo: Decodable {
    let id: String
    let createdAt: String
    let width, height: Int
    let color: String
    let likes: Int
    let likedByUser: Bool
    let photoDescription: String?
    let user: User
    let photoImageUrls: PhotoImageURLs
    let photoLinks: PhotoLinks
    
    enum CodingKeys: String, CodingKey {
        case id, likes, user
        case createdAt = "created_at"
        case width, height, color
        case photoDescription = "description"
        case photoImageUrls = "urls"
        case photoLinks = "links"
        case likedByUser = "liked_by_user"
    }
}

// MARK: - PhotoLinks
struct PhotoLinks: Decodable {
    let api, html, download: String
    let downloadLocation: String
    
    enum CodingKeys: String, CodingKey {
        case api = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - Urls
struct PhotoImageURLs: Decodable {
    let raw, full, regular, small: String
    let thumb, smallS3: String
    
    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

// MARK: - User
struct User: Decodable {
    let id, username, name, firstName: String
    let lastName: String
    let profileImage: ProfileImageURLs
    let userLinks: UserLinks
    
    enum CodingKeys: String, CodingKey {
        case id, username, name
        case userLinks = "links"
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
    }
}

// MARK: - UserLinks
struct UserLinks: Decodable {
    let api, html, photos, likes: String
    let portfolio, following, followers: String
    
    enum CodingKeys: String, CodingKey {
        case api = "self"
        case html, photos, likes, portfolio, following, followers
    }
}

// MARK: - ProfileImage
struct ProfileImageURLs: Decodable {
    let small, medium, large: String
}
