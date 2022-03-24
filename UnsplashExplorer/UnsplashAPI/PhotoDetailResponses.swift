//
//  PhotoDetailResponses.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import Foundation

struct PhotoDetailInfo: Decodable {
    let id: String
    let createdAt: String
    let width, height: Int
    let color: String
    let likes: Int
    let description: String?
    let user: UserInfo
    let exif: Exif
    let location: Location
    let imageURLs: PhotoImageURLs
    let links: PhotoLinks
    let views, downloads: Int
    
    enum CodingKeys: String, CodingKey {
        case id, likes, user, exif, location
        case createdAt = "created_at"
        case width, height, color
        case description
        case imageURLs = "urls"
        case links
        case views, downloads
    }
}

// MARK: - Exif
struct Exif: Codable {
    let maker, model, name: String?
    let exposureTime, aperture, focalLength: String?
    let iso: Int?

    enum CodingKeys: String, CodingKey {
        case maker = "make"
        case model, name
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
}

// MARK: - Location
struct Location: Codable {
    let title, name, city, country: String?
    let position: Position
}

// MARK: - Position
struct Position: Codable {
    let latitude, longitude: Double?
}
