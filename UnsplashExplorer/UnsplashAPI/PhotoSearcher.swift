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
    func searchPhotos(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<SearchPhotosResponse, PhotoSearcherError>>
    
    func photoDetail(id: String) -> Observable<Result<PhotoDetailInfo, PhotoSearcherError>>
    
    func autocomplete(byKeyword keyword: String) -> Observable<[String]>
}

class PhotoSearcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension PhotoSearcher: PhotoSearchable {
    func autocomplete(byKeyword keyword: String) -> Observable<[String]> {
        guard let url = makeAutocompleteComponents(keyword: keyword).url else {
            return .just([])
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return session.rx.data(request: request)
            .map { data -> AutocompleteResult? in
                do {
                    return try JSONDecoder().decode(AutocompleteResult.self, from: data)
                } catch {
                    return nil
                }
            }
            .map { result -> [String] in
                guard let result = result else { return [] }
                return result.autocomplete.map { $0.query }
            }
            
    }
    
    func searchPhotos(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<SearchPhotosResponse, PhotoSearcherError>> {
        guard !keyword.isEmpty else {
            return .just(.failure(.query(description: "쿼리 내용 없음")))
        }
        guard let url = makePhotoSearchComponents(
            byKeyword: keyword,
            page: page,
            perPage: perPage
        ).url else {
            return .just(.failure(.network(description:"URL 생성 오류")))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let photoData = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                    return .success(photoData)
                } catch let error {
                    return .failure(.parsing(description: error.localizedDescription))
                }
            }
            .catch { error in
                    return .just(.failure(.network(description: error.localizedDescription)))
            }
    }
    
    func photoDetail(id: String) -> Observable<Result<PhotoDetailInfo, PhotoSearcherError>> {
        guard let url = makePhotoDetailComponents(id: id).url else {
            return .just(.failure(.network(description: "URL 생성 오류")))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let photoDetail = try JSONDecoder().decode(PhotoDetailInfo.self, from: data)
                    return .success(photoDetail)
                } catch let error {
                    return .failure(.parsing(description: error.localizedDescription))
                }
            }
            .catch { error in
                    return .just(.failure(.network(description: error.localizedDescription)))
            }
    }
}

private extension PhotoSearcher {
    struct UnsplashAPI {
        static let scheme = "https"
        static let apiHost = "api.unsplash.com"
        static let accessKey: String = {
            let data: [String: String] = load("keys.json")
            return data["accessKey"]!
        }()
        static let host = "unsplash.com"
    }
    
    func makePhotoSearchComponents(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.apiHost
        components.path = "/search/photos"
        
        components.queryItems = [
            ("client_id", UnsplashAPI.accessKey),
            ("query", keyword),
            ("page", "\(page)"),
            ("per_page", "\(perPage)")
        ].map { URLQueryItem(name: $0.0, value: $0.1) }
        
        return components
    }
    
    func makePhotoDetailComponents(id: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.apiHost
        components.path = "/photos/\(id)"
        components.queryItems = [URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)]
        return components
    }
    
    func makeAutocompleteComponents(keyword: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = "/nautocomplete/\(keyword)"
        return components
    }
}
