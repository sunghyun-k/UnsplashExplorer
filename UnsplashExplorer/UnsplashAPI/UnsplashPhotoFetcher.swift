//
//  PhotoSearcher.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

//import Foundation
import RxSwift
import RxCocoa

protocol PhotoFetchable {
    func searchPhotos(
        byQuery keyword: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<SearchPhotosResponse, PhotoSearcherError>>
    
    func photoDetails(byId: String) -> Observable<Result<PhotoDetails, PhotoSearcherError>>
    
    func autocompleteResults(forQuery keyword: String) -> Observable<[String]>
    
    func editorials() -> Observable<Result<[Photo], PhotoSearcherError>>
    
//    func userDetailInfo(byUsername username: String) -> Observable
}

class UnsplashPhotoFetcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension UnsplashPhotoFetcher: PhotoFetchable {
    func autocompleteResults(forQuery query: String) -> Observable<[String]> {
        guard let url = makeAutocompleteResultsComponents(forQuery: query).url else {
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
        byQuery query: String,
        page: Int,
        perPage: Int
    ) -> Observable<Result<SearchPhotosResponse, PhotoSearcherError>> {
        guard !query.isEmpty else {
            return .just(.failure(.query(description: "쿼리 내용 없음")))
        }
        guard let url = makeSearchPhotosComponents(
            byQuery: query,
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
    
    func photoDetails(byId id: String) -> Observable<Result<PhotoDetails, PhotoSearcherError>> {
        guard let url = makePhotoDetailsComponents(byId: id).url else {
            return .just(.failure(.network(description: "URL 생성 오류")))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let photoDetail = try JSONDecoder().decode(PhotoDetails.self, from: data)
                    return .success(photoDetail)
                } catch let error {
                    return .failure(.parsing(description: error.localizedDescription))
                }
            }
            .catch { error in
                    return .just(.failure(.network(description: error.localizedDescription)))
            }
    }
    
    func editorials() -> Observable<Result<[Photo], PhotoSearcherError>> {
        guard let url = makeEditorialsComponents().url else {
            return .just(.failure(.network(description: "URL 생성 오류")))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: data)
                    return .success(photos)
                } catch let error {
                    print(error)
                    return .failure(.parsing(description: error.localizedDescription))
                }
            }
            .catch { error in
                    return .just(.failure(.network(description: error.localizedDescription)))
            }
    }
}

private extension UnsplashPhotoFetcher {
    struct UnsplashAPI {
        static let scheme = "https"
        static let apiHost = "api.unsplash.com"
        static let accessKey: String = {
            let data: [String: String] = load("keys.json")
            return data["accessKey"]!
        }()
        static let host = "unsplash.com"
    }
    
    func makeSearchPhotosComponents(
        byQuery query: String,
        page: Int,
        perPage: Int
    ) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.apiHost
        components.path = "/search/photos"
        
        components.queryItems = [
            ("client_id", UnsplashAPI.accessKey),
            ("query", query),
            ("page", "\(page)"),
            ("per_page", "\(perPage)")
        ].map { URLQueryItem(name: $0.0, value: $0.1) }
        
        return components
    }
    
    func makePhotoDetailsComponents(byId id: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.apiHost
        components.path = "/photos/\(id)"
        components.queryItems = [URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)]
        return components
    }
    
    func makeAutocompleteResultsComponents(forQuery query: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = "/nautocomplete/\(query)"
        return components
    }
    
    func makeEditorialsComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.apiHost
        components.path = "/photos"
        components.queryItems = [URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)]
        return components
    }
}