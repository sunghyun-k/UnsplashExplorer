//
//  TagView.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/31.
//

import Foundation
import UIKit
import SnapKit

class TagView: UIView {
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 20)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tags: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
}

extension TagView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    }
}

class TagCell: UICollectionViewCell {
    
}

import SwiftUI
struct TagView_Preview: PreviewProvider {
    static var previews: some View {
        Container()
            .previewLayout(.fixed(width: 300, height: 70))
    }
    
    struct Container: UIViewRepresentable {
        func makeUIView(context: Context) -> TagView {
            let tagView = TagView()
            return tagView
        }
        
        func updateUIView(_ uiView: TagView, context: Context) {
            
        }
        
        typealias UIViewType = TagView
    }
    
}
