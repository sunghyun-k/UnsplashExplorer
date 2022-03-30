//
//  VLabeledTextLabel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import UIKit
import SnapKit

class VLabeledTextLabel: UIView {
    private lazy var labelTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    var title: String? {
        get { labelTextLabel.text }
        set { labelTextLabel.text = newValue }
    }
    var text: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [labelTextLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.width.equalTo(valueLabel.snp.width)
        }
    }
}

