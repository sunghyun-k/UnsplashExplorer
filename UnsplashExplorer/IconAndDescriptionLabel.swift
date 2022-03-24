//
//  IconAndDescriptionLabel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import UIKit
import SnapKit

class IconAndDescriptionLabel: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func setup(icon: UIImage, description: String) {
        iconImageView.image = icon
        descriptionLabel.text = description
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, descriptionLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        self.addSubview(stackView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(18)
            make.height.equalTo(iconImageView.snp.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
