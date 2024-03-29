//
//  SectionHeader.swift
//  TrackerYandexPracticum
//
//  Created by admin on 04.12.2023.
//

import UIKit

final class SectionHeader: UICollectionReusableView {
    
    static let Identifer = "trackersCollectionHeaderIdentifer"
    
    private let spacing: CGFloat = 16
    private let spacingToTracker: CGFloat = 12
    private let leadingSection: CGFloat = 28
    
    let sectionTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(sectionTitle)
        
        NSLayoutConstraint.activate([
            sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingSection),
            sectionTitle.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            sectionTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacingToTracker)
        ])
    }
}
