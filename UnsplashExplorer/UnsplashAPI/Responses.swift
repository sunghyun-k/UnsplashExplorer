//
//  Responses.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation

// MARK: - SearchPhotosResponse
struct SearchPhotosResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

// MARK: - Photo
struct Photo: Decodable {
    let id: String
    let createdAt: String
    let width, height: Int
    let color: String
    let likes: Int
    let description: String?
    let user: User
    let imageURLs: PhotoImageURLs
    let links: PhotoLinks
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height
        case color
        case likes
        case description
        case user
        case imageURLs = "urls"
        case links
    }
}

// MARK: - PhotoLinks
struct PhotoLinks: Decodable {
    let api, html, download, downloadLocation: String
    
    enum CodingKeys: String, CodingKey {
        case api = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - PhotoImageURLs
struct PhotoImageURLs: Decodable {
    let raw, full, regular, small, thumb, smallS3: String
    
    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

// MARK: - User
struct User: Decodable {
    let id: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String?
    let profileImageURLs: ProfileImageURLs
    let links: UserLinks
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case links = "links"
        case profileImageURLs = "profile_image"
    }
}

// MARK: - UserLinks
struct UserLinks: Decodable {
    let api, html: String
    let photos: String
    let likes: String
    let portfolio: String
    let following, followers: String
    
    enum CodingKeys: String, CodingKey {
        case api = "self"
        case html
        case photos
        case likes
        case portfolio
        case following, followers
    }
}

// MARK: - ProfileImage
struct ProfileImageURLs: Decodable {
    let small, medium, large: String
}

// MARK: - AutocompleteResult
struct AutocompleteResult: Decodable {
    let fuzzy, autocomplete, didYouMean: [Autocomplete]

    enum CodingKeys: String, CodingKey {
        case fuzzy, autocomplete
        case didYouMean = "did_you_mean"
    }
}

// MARK: - Autocomplete
struct Autocomplete: Decodable {
    let query: String
    let priority: Int
}
