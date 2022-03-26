//
//  TabBarController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/26.
//

import UIKit

class TabBarController: UITabBarController {
    var viewModel: PhotoListViewModel
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBar() {
        
        let editorialViewController = UINavigationController(rootViewController: UIViewController())
        editorialViewController.tabBarItem.image = UIImage(systemName: "photo.fill")
        editorialViewController.tabBarItem.title = "Editorial"
        
        let searchViewController = UINavigationController(rootViewController: PhotoListCollectionViewController(viewModel: self.viewModel))
        searchViewController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchViewController.tabBarItem.title = "Search"
        
        viewControllers = [
            editorialViewController,
            searchViewController
        ]
    }
    
    
}
