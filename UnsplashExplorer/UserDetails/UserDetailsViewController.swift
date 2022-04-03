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
    
    var cellPadding: CGFloat = 1
    var numberOfColumns = 3
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.layer.cornerCurve = .circular
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
        }
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var locationLabel: LeftIconLabel = {
        let label = LeftIconLabel()
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = cellPadding
        layout.numberOfColumns = numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: PhotoListCell.reuseId)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var collectionViewHeight: Constraint!
    
//    private lazy var tags: UIView
    
    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind(viewModel: viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    private func layout() {
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, bioLabel, locationLabel])
        textStackView.alignment = .leading
        textStackView.spacing = 5
        textStackView.axis = .vertical
        
        let profileStackView = UIStackView(arrangedSubviews: [profileImageView, textStackView])
        profileStackView.spacing = 10
        profileStackView.alignment = .top
        
        let stackView = UIStackView(arrangedSubviews: [profileStackView, collectionView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        let scrollView = UIScrollView()
        scrollView.addSubview(stackView)
        
        
        view.addSubview(scrollView)
        collectionView.snp.makeConstraints { make in
            make.width.equalTo(view)
            collectionViewHeight = make.height.equalTo(1000).constraint
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view)
        }
        profileStackView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(15)
        }
        
        scrollView.contentInset = view.safeAreaInsets
    }
    
    private func bind(viewModel: UserDetailsViewModel) {
        viewModel.user
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard
                    let self = self,
                    let user = $0
                else { return }
                self.setup(user)
            })
            .disposed(by: disposeBag)
        
        viewModel.photos
            .bind(to: collectionView.rx.items(
                cellIdentifier: PhotoListCell.reuseId,
                cellType: PhotoListCell.self
            )) { index, photo, cell in
                cell.setup(
                    backgroundColor: photo.color.cgColor,
                    username: photo.user.name,
                    thumbnailImageURL: URL(string: photo.imageURLs.regular),
                    profileImageURL: URL(string: photo.user.profileImageURLs.small)
                )
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.collectionViewHeight.update(offset: self.collectionView.contentSize.height)
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

extension UserDetailsViewController: PhotoListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photos = self.viewModel.photos.value
        guard photos.count > indexPath.item else { return 0 }
        let photo = photos[indexPath.item]
        
        let inset = collectionView.contentInset
        let columnWidth = (collectionView.bounds.width - inset.right - inset.bottom - (self.cellPadding * CGFloat(self.numberOfColumns) * 2)) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        return columnWidth * aspectRatio
    }
}
