//
//  TabBarController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBar() {
        
        let fetcher = UnsplashPhotoFetcher()
        
        let editorialModel = EditorialViewModel(fetcher: fetcher)
        let editorialViewController = UINavigationController(
            rootViewController: EditorialViewController(viewModel: editorialModel)
        )
        editorialViewController.tabBarItem.image = UIImage(systemName: "photo.fill")
        editorialViewController.tabBarItem.title = "Editorial"
        
        let searchModel = SearchViewModel(photoFetcher: fetcher)
        let autocompleteModel = AutocompleteViewModel(fetcher: fetcher)
        let searchViewController = UINavigationController(
            rootViewController: SearchViewController(searchViewModel: searchModel, autocompleteViewModel: autocompleteModel)
        )
        searchViewController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchViewController.tabBarItem.title = "Search"
        
        viewControllers = [
            editorialViewController,
            searchViewController
        ]
    }
    
    
}
