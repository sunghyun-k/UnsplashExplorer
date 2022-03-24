//
//  PhotoDetailViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import SwiftUI

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class PhotoDetailViewController: UIViewController {
    var viewModel: PhotoListViewModel
    
    // MARK: Views
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        return imageView
    }()
    
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Priscilla Du Preez"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@priscilladupreez"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var viewsLabel: TitleInfoLabel = {
        let label = TitleInfoLabel()
        label.setup(title: "Views", info: "1134141241212")
        return label
    }()
    private lazy var downloadsLabel: TitleInfoLabel = {
        let label = TitleInfoLabel()
        label.setup(title: "Downloads", info: "941")
        return label
    }()
    
    private lazy var dateLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.setup(icon: UIImage(systemName: "calendar")!, description: "Published on November 20, 2019")
        return label
    }()
    private lazy var gearLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.setup(icon: UIImage(systemName: "camera")!, description: "Canon, EOS 6D")
        return label
    }()
    private lazy var lisenceLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.setup(icon: UIImage(systemName: "checkmark.shield")!, description: "Free to use under the Unsplash License ㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇ")
        return label
    }()
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind(viewModel: viewModel)
    }
    
    private func bind(viewModel: PhotoListViewModel) {
        
    }
    
    private func layout() {
        // 프로필 이미지 및 이름
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        nameStackView.axis = .vertical
        nameStackView.spacing = 2
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(userProfileImageView.snp.width)
        }
        let profileStackView = UIStackView(arrangedSubviews: [userProfileImageView, nameStackView])
        profileStackView.axis = .horizontal
        profileStackView.spacing = 8
        
        // 조회수, 다운로드 수
        let countRecordStackView = UIStackView(arrangedSubviews: [
            viewsLabel,
            downloadsLabel,
            UIView()
        ])
        countRecordStackView.axis = .horizontal
        countRecordStackView.spacing = 30
        viewsLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
        countRecordStackView.distribution = .fill
        
        // 사진 상세 정보
        let detailStackView = UIStackView(arrangedSubviews: [dateLabel, gearLabel, lisenceLabel])
        detailStackView.axis = .vertical
        detailStackView.spacing = 10
        
        // 최종 StackView
        let stackView = UIStackView(arrangedSubviews: [
            profileStackView,
            photoImageView,
            countRecordStackView,
            detailStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        
        // 사진
        photoImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(photoImageView.snp.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview()
        }
    }
    
}

//struct PhotoDetailViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        Container()
//    }
//    
//    struct Container: UIViewControllerRepresentable {
//        func makeUIViewController(context: Context) -> UIViewController {
//            
//            let viewController = PhotoDetailViewController()
//            return UINavigationController(rootViewController: viewController)
//        }
//        
//        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//            
//        }
//        
//        typealias UIVIewControllerType = UIViewController
//    }
//    
//}
