//
//  LeftIconLabel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import UIKit
import SnapKit

class LeftIconLabel: UIView {
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
    
    var icon: UIImage? {
        get { iconImageView.image }
        set { iconImageView.image = newValue }
    }
    var text: String? {
        get { descriptionLabel.text }
        set { descriptionLabel.text = newValue }
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
            make.width.height.equalTo(18)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }

}
