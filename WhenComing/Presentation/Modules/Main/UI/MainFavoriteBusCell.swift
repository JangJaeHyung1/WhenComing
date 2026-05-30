//
//  MainFavoriteBusCell.swift
//  WhenComing
//
//  Created by Codex on 5/30/26.
//

import UIKit
import SnapKit

final class MainFavoriteBusCell: UITableViewCell {
    static let cellId = "MainFavoriteBusCell"

    private let busLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let arrivalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemOrange
        label.textAlignment = .right
        label.lineBreakMode = .byClipping
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(
        busNumber: String,
        busType: String,
        arrivalTime: Int?,
        stationCount: Int?
    ) {
        busLabel.text = "\(busNumber)   \(busType)"

        guard let arrivalTime, let stationCount else {
            arrivalLabel.text = "정보 없음"
            arrivalLabel.textColor = .secondaryLabel
            return
        }

        let minutes = arrivalTime / 60
        let seconds = arrivalTime % 60

        if minutes == 0 {
            arrivalLabel.text = "곧 도착"
        } else if minutes > 9 {
            arrivalLabel.text = "\(minutes)분 (\(stationCount)역 전)"
        } else {
            arrivalLabel.text = "\(minutes)분 \(seconds)초 (\(stationCount)역 전)"
        }
        arrivalLabel.textColor = .systemOrange
    }

    private func setupView() {
        selectionStyle = .none

        contentView.addSubview(busLabel)
        contentView.addSubview(arrivalLabel)

        busLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(arrivalLabel.snp.leading).offset(-12)
        }

        arrivalLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}
