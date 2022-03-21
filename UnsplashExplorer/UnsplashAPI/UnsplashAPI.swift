//
//  UnsplashAPI.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation

struct UnsplashAPI {
    static let scheme = "https"
    static let host = "api.unsplash.com"
    
    func makeSearchComponents(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = "/search/photos"
        
        components.queryItems = [
            ("client_id", UnsplashAPI.accessKey),
            ("query", keyword),
            ("page", "\(page)"),
            ("per_page", "\(perPage)")
        ].map { URLQueryItem(name: $0.0, value: $0.1) }
        
        return components
    }
}
