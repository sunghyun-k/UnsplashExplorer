//
//  UserDetails.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/30.
//

import Foundation

// MARK: - UserDetails
struct UserDetails: Decodable {
    let id: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String?
    let totalLikes, totalPhotos, totalCollections: Int
    let followersCount, followingCount, downloads: Int
    let profileImageURLs: ProfileImageURLs
    let links: UserLinks
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case downloads
        case links
        case profileImageURLs = "profile_image"
    }
}
