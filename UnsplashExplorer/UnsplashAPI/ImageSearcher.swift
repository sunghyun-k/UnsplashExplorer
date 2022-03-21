//
//  ImageSearcher.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation
import RxSwift

protocol ImageSearchable {
    func search(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Single<Result<SearchResult, ImageSearcherError>>
}

class ImageSearcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension ImageSearcher: ImageSearchable {
    func search(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Single<Result<SearchResult, ImageSearcherError>> {
        guard let url = makeSearchComponents(
            byKeyword: keyword,
            page: page,
            perPage: perPage
        ).url else {
            return .just(.failure(.url(description:"")))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
    }
}

private extension ImageSearcher {
    struct UnsplashAPI {
        static let scheme = "https"
        static let host = "api.unsplash.com"
        static let accessKey: String = {
            let data: [String: String] = load("keys")
            return data["accessKey"]!
        }()
    }
    
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
