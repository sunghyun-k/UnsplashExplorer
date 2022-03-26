//
//  DetailInfoCollectionViewCell.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/25.
//

import UIKit
import SnapKit

class DetailInfoCollectionViewCell: UICollectionViewCell {
    static let reuseId = "DetailInfoCollectionViewCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var text: String? {
        get { descriptionLabel.text }
        set { descriptionLabel.text = newValue }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.alignment = .leading
        stackView.axis = .vertical
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
