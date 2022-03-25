//
//  HalfModalViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HalfModalViewController: UIViewController {
    private var dataSource: [(title: String, description: String?)]
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.top = 10
        item.contentInsets.bottom = 10
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(75)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            DetailInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailInfoCollectionViewCell.reuseId
        )
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var modalView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private var dimScale: CGFloat = 0.5
    private var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: Configuration
    private let defaultHeight: CGFloat = 300
    private let dismissThreshold: CGFloat = 200
    private var maxModalHeight: CGFloat {
        UIScreen.main.bounds.height - view.safeAreaInsets.top
    }
    
    // MARK: Properties
    /// 높이를 제스쳐에 따라 업데이트하기 위한 프로퍼티
    private var heightConstraint: Constraint?
    private var currentModalHeight: CGFloat = 300
    
    // MARK: Prepare
    init(photoDetail: PhotoDetailInfo) {
        let iso: String?
        if photoDetail.exif.iso != nil {
            iso = "\(photoDetail.exif.iso!)"
        } else {
            iso = nil
        }
        
        let aperture: String?
        if photoDetail.exif.aperture != nil {
            aperture = "𝑓/\(photoDetail.exif.aperture!)"
        } else {
            aperture = nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let publishedAt: String?
        if let createdAt = dateFormatter.date(from: String(photoDetail.createdAt.dropLast(15))) {
            dateFormatter.dateStyle = .short
            let date = dateFormatter.string(from: createdAt)
            publishedAt = date
        } else {
            publishedAt = nil
        }
        
        self.dataSource = [
            ("Maker", photoDetail.exif.maker),
            ("Focal Length", photoDetail.exif.focalLength),
            ("Model", photoDetail.exif.model),
            ("ISO", iso),
            ("Shutter Speed", photoDetail.exif.exposureTime),
            ("Dimensions", "\(photoDetail.width) x \(photoDetail.height)"),
            ("Aperture", aperture),
            ("Published", publishedAt),
        ]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bindGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animatePresent()
    }
    
    private func layout() {
        [dimmedView, modalView].forEach {
            view.addSubview($0)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        modalView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        // 높이를 나중에 제스쳐에 따라 업데이트 해야한다.
        modalView.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(0).constraint
        }
        
        modalView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(600)
        }
    }
    
    // MARK: Pan Gesture Bind
    private func bindGesture() {
        // Pan Gesture
        let panGesture = UIPanGestureRecognizer()
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        modalView.addGestureRecognizer(panGesture)
        panGesture.rx.event
            .bind(onNext: { [weak self] gesture in
                guard let self = self else { return }
                let translatedPoint = gesture.translation(in: self.view)
                let newHeight = self.currentModalHeight - translatedPoint.y
                
                switch gesture.state {
                case .changed:
                    print(newHeight, self.maxModalHeight)
                    if newHeight < self.maxModalHeight {
                        self.heightConstraint?.update(offset: newHeight)
                    }
                case .ended:
                    if newHeight < self.dismissThreshold {
                        self.animateDismiss()
                    } else {
                        self.animateModal(toHeight: self.defaultHeight)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // Background Tap Gesture
        let tapGesture = UITapGestureRecognizer()
        dimmedView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.animateDismiss()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Animations
    private func animateModal(toHeight height: CGFloat) {
        heightConstraint?.update(offset: height)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0) {
            self.view.layoutIfNeeded()
        }
        currentModalHeight = height
    }
    
    // MARK: Present, Dismiss
    private func animatePresent() {
        dimmedView.alpha = 0
        heightConstraint?.update(offset: defaultHeight)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0) {
            self.view.layoutIfNeeded()
            self.dimmedView.alpha = self.dimScale
        }
    }
    
    private func animateDismiss() {
        heightConstraint?.update(offset: 0)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0) {
            self.view.layoutIfNeeded()
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

extension HalfModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailInfoCollectionViewCell.reuseId, for: indexPath) as! DetailInfoCollectionViewCell
        let item = dataSource[indexPath.item]
        cell.title = item.title
        cell.text = item.description ?? "-"
        return cell
    }
}
