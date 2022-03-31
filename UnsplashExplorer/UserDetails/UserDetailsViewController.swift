//
//  UserDetailsViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/31.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

class UserDetailsViewController: UIViewController {
    var viewModel: UserDetailsViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var bio: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var location: LeftIconLabel = {
        let label = LeftIconLabel()
        return label
    }()
    
    private lazy var tags: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(_ user: UserDetails) {
        
    }
}
