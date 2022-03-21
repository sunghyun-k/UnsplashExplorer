//
//  Responses.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation

// MARK: - Search
struct SearchResult: Decodable {
    let total, totalPages: Int
    let results: [Photo]
}

// MARK: - Photo
struct Photo: Decodable {
    let id: String
    let createdAt: Date
    let width, height: Int
    let color, blurHash: String
    let likes: Int
    let likedByUser: Bool
    let photoDescription: String
    let user: User
    let urls: URLs
    let links: PhotoLinks
}

// MARK: - PhotoLinks
struct PhotoLinks: Decodable {
    let linksSelf: String
    let html, download: String
}

// MARK: - Urls
struct URLs: Decodable {
    let raw, full, regular, small: String
    let thumb: String
}

// MARK: - User
struct User: Decodable {
    let id, username, name, firstName: String
    let lastName, instagramUsername, twitterUsername: String
    let portfolioURL: String
    let profileImage: ProfileImageURLs
    let links: UserLinks
}

// MARK: - UserLinks
struct UserLinks: Decodable {
    let linksSelf: String
    let html: String
    let photos, likes: String
}

// MARK: - ProfileImage
struct ProfileImageURLs: Decodable {
    let small, medium, large: String
}
