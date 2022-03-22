//
//  PhotoSearcher.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

//import Foundation
import RxSwift
import RxCocoa

protocol PhotoSearchable {
    func searchPhoto(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<PhotoSearchResult, PhotoSearcherError>>
}

class PhotoSearcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension PhotoSearcher: PhotoSearchable {
    func searchPhoto(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<PhotoSearchResult, PhotoSearcherError>> {
        guard let url = makePhotoSearchComponents(
            byKeyword: keyword,
            page: page,
            perPage: perPage
        ).url else {
            return .just(.failure(.url(description:"")))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let photoData = try JSONDecoder().decode(PhotoSearchResult.self, from: data)
                    return .success(photoData)
                } catch {
                    return .failure(.parsing(description: "데이터 파싱 오류"))
                }
            }
            .catch { error in
                    .just(.failure(.network(
                        description: "네트워크 로드 오류: \(error.localizedDescription)"
                    )))
            }
    }
}

private extension PhotoSearcher {
    struct UnsplashAPI {
        static let scheme = "https"
        static let host = "api.unsplash.com"
        static let accessKey: String = {
            let data: [String: String] = load("keys")
            return data["accessKey"]!
        }()
    }
    
    func makePhotoSearchComponents(
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
