//
//  PhotoListCollectionViewLayout.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit

protocol PhotoListLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForCellAtIndexPath indexPath: IndexPath
    ) -> CGFloat
}

final class PhotoListCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: PhotoListLayoutDelegate?
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 10
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    private var columnWidth: CGFloat {
        contentWidth / CGFloat(numberOfColumns)
    }
    
    /// column의 가장 아래 좌표를 저장한다. 이 값이 가장 작은 곳에 새로운 cell을 추가한다.
    private lazy var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    
    private lazy var xOffset: [CGFloat] = {
        return (0..<numberOfColumns).map { column in
            CGFloat(column) * columnWidth
        }
    }()
    
    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        
        guard cache.count < collectionView.numberOfItems(inSection: 0) else {
            return
        }
        
        for item in cache.count..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let imageHeight = delegate?.collectionView(
                collectionView,
                heightForCellAtIndexPath: indexPath
            ) ?? 200
            let height = cellPadding * 2 + imageHeight
            
            // yOffset 최솟값 구하기
            let column = yOffset.enumerated().min {
                $0.element < $1.element
            }?.offset ?? 0
            
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] += height
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        cache.filter { attributes in
            attributes.frame.intersects(rect)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        guard !cache.isEmpty else { return nil }
        return cache[indexPath.item]
    }
    
    func removeLayoutCache() {
        cache.removeAll()
        contentHeight = 0
        yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    }
}
