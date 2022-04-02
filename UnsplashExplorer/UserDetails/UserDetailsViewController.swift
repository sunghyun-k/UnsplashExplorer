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
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var locationLabel: LeftIconLabel = {
        let label = LeftIconLabel()
        return label
    }()
    
//    private lazy var tags: UIView
    
    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, bioLabel, locationLabel])
        textStackView.alignment = .leading
        textStackView.spacing = 5
        textStackView.axis = .vertical
        
        let profileStackView = UIStackView(arrangedSubviews: [profileImageView, textStackView])
        profileStackView.spacing = 10
        profileStackView.alignment = .top
        
        view.addSubview(profileStackView)
        profileStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func bind(viewModel: UserDetailsViewModel) {
        viewModel.user
            .subscribe(onNext: { [weak self] in
                guard
                    let self = self,
                    let user = $0
                else { return }
                self.setup(user)
            })
            .disposed(by: disposeBag)
    }
    
    private func setup(_ user: UserDetails) {
        profileImageView.kf.setImage(with: URL(string: user.profileImageURLs.large))
        nameLabel.text = user.name
        bioLabel.text = user.bio
        locationLabel.text = user.location
    }
}
