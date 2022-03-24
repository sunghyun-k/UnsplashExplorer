//
//  PhotoListCollectionViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "PhotoListCell"

final class PhotoListCollectionViewController: UIViewController {
    var viewModel: PhotoListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private lazy var backgroundTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 20)
        textView.textColor = .gray
        textView.textAlignment = .center
        textView.text = "검색 결과 없음"
        return textView
    }()
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    var cellPadding: CGFloat = 5
    var numberOfColumns = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind(viewModel: viewModel)
    }
    
    private func bind(viewModel: PhotoListViewModel) {
        // collectionView 데이터 소스
        viewModel.dataSource
            .bind(
                to: collectionView.rx.items(
                    cellIdentifier: reuseIdentifier,
                    cellType: PhotoListCell.self
                )
            ) { index, photoInfo, cell in
                cell.setup(
                    backgroundColor: photoInfo.color.cgColor,
                    username: photoInfo.user.name,
                    thumbnailImageURL: URL(string: photoInfo.photoImageUrls.thumb),
                    profileImageURL: URL(string: photoInfo.user.profileImage.small)
                )
            }
            .disposed(by: disposeBag)
        
        // searchBar 텍스트를 viewModel에 전달한다.
        searchBar.rx.text
            .subscribe(onNext: { text in
                viewModel.searchQuery.onNext(text ?? "")
            })
            .disposed(by: disposeBag)
        
        // dataSource가 비어있는지 여부에 따라 배경 메시지를 토글한다.
        viewModel.dataSource
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if data.isEmpty {
                    self.backgroundTextView.isHidden = false
                } else {
                    self.backgroundTextView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // 스크롤 맨 밑에 도달 시 추가로 결과를 로드한다.
        collectionView.rx.contentOffset
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] contentOffset in
                guard let self = self else {
                    return
                }
                
                let contentHeight = self.collectionView.contentSize.height
                if contentOffset.y > contentHeight - self.collectionView.frame.height {
                    viewModel.loadMore()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        [
            collectionView,
            backgroundTextView,
            searchBar
        ].forEach {
            view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        backgroundTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
    }
}

// MARK: - PhotoListLayoutDelegate

extension PhotoListCollectionViewController: PhotoListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photoInfo = viewModel.dataSource.value[indexPath.item]
        
        let inset = collectionView.contentInset
        let columnWidth = (collectionView.bounds.width - inset.right - inset.bottom - (self.cellPadding * CGFloat(self.numberOfColumns) * 2)) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photoInfo.height) / CGFloat(photoInfo.width)
        return columnWidth * aspectRatio
    }
}
