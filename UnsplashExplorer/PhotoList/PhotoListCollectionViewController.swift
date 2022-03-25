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
    /// 추가 로드 중일 때 true
    private var isLoadingMore = false
    
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
    
    private lazy var autocompletesView: AutocompletesView = AutocompletesView()
    
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
                    thumbnailImageURL: URL(string: photoInfo.imageURLs.small),
                    profileImageURL: URL(string: photoInfo.user.profileImageURLs.small)
                )
            }
            .disposed(by: disposeBag)
        
        // searchBar 텍스트를 viewModel에 전달한다.
        searchBar.rx.text
            .subscribe(onNext: { text in
                viewModel.searchText.onNext(text ?? "")
            })
            .disposed(by: disposeBag)
        
        // autocompletes를 Subscribe한다
        viewModel.autocompletes
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] autocompletes in
                print(autocompletes)
                self?.autocompletesView.texts = autocompletes
            })
            .disposed(by: disposeBag)
        
        // search 버튼이 눌렸을 때 검색을 수행
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                viewModel.searchPhoto()
                self.removeLayoutCache()
                if self.collectionView.numberOfItems(inSection: 0) > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                }
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
            .throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                guard !self.isLoadingMore else { return }
                let contentHeight = self.collectionView.contentSize.height
                if contentOffset.y > contentHeight - self.collectionView.frame.height {
                    self.isLoadingMore = true
                    viewModel.loadMore { [weak self] in
                        self?.isLoadingMore = false
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 셀 선택 동작 바인딩
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let item = viewModel.dataSource.value[indexPath.item]
                viewModel.fetchPhotoDetail(id: item.id)
                let photoDetailView = PhotoDetailViewController(viewModel: viewModel)
                self.navigationController?.pushViewController(photoDetailView, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        [
            collectionView,
            backgroundTextView,
            searchBar,
            autocompletesView
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
        autocompletesView.snp.makeConstraints { make in
            make.top.equalTo(300)
            make.width.equalToSuperview()
        }
        
        backgroundTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
    }
    
    private func removeLayoutCache() {
        guard let layout = collectionView.collectionViewLayout as? PhotoListCollectionViewLayout else {
            return
        }
        layout.removeLayoutCache()
        collectionView.contentSize.height = 0
    }
}

// MARK: - PhotoListLayoutDelegate

extension PhotoListCollectionViewController: PhotoListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let dataSource = self.viewModel.dataSource.value
        guard dataSource.count > indexPath.item else { return 0 }
        let photoInfo = dataSource[indexPath.item]
        
        let inset = collectionView.contentInset
        let columnWidth = (collectionView.bounds.width - inset.right - inset.bottom - (self.cellPadding * CGFloat(self.numberOfColumns) * 2)) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photoInfo.height) / CGFloat(photoInfo.width)
        return columnWidth * aspectRatio
    }
}
