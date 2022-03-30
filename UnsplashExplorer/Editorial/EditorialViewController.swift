//
//  EditorialViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class EditorialViewController: UIViewController {
    var viewModel: EditorialViewModel
    
    var cellPadding: CGFloat = 0
    var numberOfColumns = 1
    
    private let disposeBag = DisposeBag()
    
    private let refreshControl = UIRefreshControl()
    private lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCollectionViewCell.self, forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseId)
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    init(viewModel: EditorialViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBarView()
        layout()
        bind(viewModel: viewModel)
    }
    
    private func setupNavigationBarView() {
        let unsplashLogoImage = UIImage(named: "UnsplashLogo.png")?.withRenderingMode(.alwaysOriginal)
        let logoImageView = UIImageView(image: unsplashLogoImage)
        logoImageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Unsplash"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        let navigationBarView = UIView()
        [logoImageView, label].forEach {
            navigationBarView.addSubview($0)
        }
        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        navigationItem.titleView = navigationBarView
        navigationBarView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func layout() {
        [
            collectionView
        ].forEach {
            view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.contentInset = view.safeAreaInsets
    }
    
    private func bind(viewModel: EditorialViewModel) {
        viewModel.photos
            .bind(to: collectionView.rx.items(
                cellIdentifier: PhotoListCollectionViewCell.reuseId,
                cellType: PhotoListCollectionViewCell.self
            )) { index, photo, cell in
                cell.setup(
                    backgroundColor: photo.color.cgColor,
                    username: photo.user.name,
                    thumbnailImageURL: URL(string: photo.imageURLs.regular),
                    profileImageURL: URL(string: photo.user.profileImageURLs.small)
                )
            }
            .disposed(by: disposeBag)
        
        // 이미지 셀 선택 View Model에 전달
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                viewModel.selectPhoto(at: indexPath.item)
            })
            .disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext:{ event in
                switch event {
                case .presentPhoto(let viewModel):
                    let photoDetailsViewController = PhotoDetailsViewController(viewModel: viewModel)
                    self.navigationController?.pushViewController(photoDetailsViewController, animated: true)
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                let contentHeight = self.collectionView.contentSize.height
                if contentOffset.y > contentHeight - self.collectionView.frame.height {
                    viewModel.loadMore()
                }
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { a in
                viewModel.refresh()
            })
            .disposed(by: disposeBag)
        viewModel.photos
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
}

extension EditorialViewController: PhotoListLayoutDelegate {
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
