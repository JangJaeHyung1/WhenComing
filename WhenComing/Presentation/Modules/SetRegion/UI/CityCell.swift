//
//  CityCell.swift
//  WhenComing
//
//  Created by jh on 9/28/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CityCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    static let cellId = "CityCell"

    private var normalBackgroundColor: UIColor {
        return traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
    private var normalTextColor: UIColor { .label }
    private var invertedBackgroundColor: UIColor { .label }
    private var invertedTextColor: UIColor { .systemBackground }
    
    private let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor { view in
            if view.userInterfaceStyle == .dark {
                return UIColor.secondarySystemBackground
            } else {
                return UIColor.systemBackground
            }
        }
        view.layer.borderColor = UIColor.separator.resolvedColor(with: UITraitCollection.current).cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    private let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textColor = .label
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        isSelected = false
        updateSelectionAppearance()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        //        cellView.setShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        cellView.setShadow()
    }

    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }

    override var isHighlighted: Bool {
        didSet { cellView.alpha = isHighlighted ? 0.9 : 1.0 }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            applyDynamicColors()
            updateSelectionAppearance()
        }
    }

    private func updateSelectionAppearance() {
        if isSelected {
            cellView.backgroundColor = invertedBackgroundColor
            titleLbl.textColor = invertedTextColor
            titleLbl.font = .systemFont(ofSize: 16, weight: .bold)
            cellView.layer.borderColor = UIColor.clear.cgColor
        } else {
            cellView.backgroundColor = normalBackgroundColor
            titleLbl.textColor = normalTextColor
            titleLbl.font = .systemFont(ofSize: 16, weight: .medium)
            cellView.layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        contentView.addSubview(cellView)
        cellView.addSubview(titleLbl)
        setConstraints()
        applyDynamicColors()
        updateSelectionAppearance()
    }
    
    private func setConstraints() {
        cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0).isActive = true
        cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0).isActive = true
        
        titleLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func applyDynamicColors() {
        cellView.layer.borderColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        titleLbl.textColor = .label
    }
    
    func configure(with presentable: BusCityCodeEntity) {
        titleLbl.text = presentable.name
        
    }
}
