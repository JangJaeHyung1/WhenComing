//
//  SegmentControlView.swift
//  WhenComing
//
//  Created by jh on 10/27/25.
//

import UIKit

final class SegmentControlView: UIControl {

    public private(set) var selectedIndex: Int = 0

    private let stackView = UIStackView()
    private var buttons: [UIButton] = []

    private let baselineView = UIView()   // 전체 바닥 얇은 선
    private let indicatorView = UIView()  // 선택 탭 위 굵은 검정 선

    // indicator 이동용 제약
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?
    
    // 좌우 여백(인디케이터가 버튼 폭보다 조금 작게)
    private let indicatorInset: CGFloat = 20

    // MARK: - Init
    init(titles: [String]) {
        super.init(frame: .zero)
        setup(titles: titles)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Setup
    private func setup(titles: [String]) {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        
        // StackView
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(baselineView)
        addSubview(indicatorView)

        baselineView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        baselineView.backgroundColor = .systemGray4
        indicatorView.backgroundColor = .label

        
        buttons = titles.enumerated().map { idx, title in
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)
            b.tintColor = .label
            b.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            b.tag = idx
            b.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            return b
        }
        buttons.forEach { stackView.addArrangedSubview($0) }

        // Constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            baselineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baselineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            baselineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            baselineView.heightAnchor.constraint(equalToConstant: 1),

            indicatorView.bottomAnchor.constraint(equalTo: baselineView.topAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 3)
        ])

        // 초기 indicator를 첫 버튼에 정렬
        if let first = buttons.first {
            indicatorLeading = indicatorView.leadingAnchor.constraint(equalTo: first.leadingAnchor, constant: indicatorInset)
            indicatorWidth = indicatorView.widthAnchor.constraint(equalTo: first.widthAnchor, constant: -2 * indicatorInset)
            indicatorLeading?.isActive = true
            indicatorWidth?.isActive = true
        }

        // 초기 상태 업데이트
        updateSelection(index: 0, animated: false)
    }

    // MARK: - Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        select(index: sender.tag, animated: true)
    }

    /// 외부에서 인덱스를 선택 (애니메이션 옵션 지원)
    public func select(index: Int, animated: Bool) {
        guard index >= 0, index < buttons.count, index != selectedIndex else { return }
        updateSelection(index: index, animated: animated)
        sendActions(for: .valueChanged)
    }

    
    private func updateSelection(index: Int, animated: Bool) {
        guard !buttons.isEmpty else { return }
        let targetButton = buttons[index]

        // 버튼 폰트 굵기 업데이트
        for (i, b) in buttons.enumerated() {
            b.titleLabel?.font = i == index ? .systemFont(ofSize: 16, weight: .semibold)
                                            : .systemFont(ofSize: 16, weight: .regular)
        }

        // 기존 leading/width 제약 대체
        if animated { self.layoutIfNeeded() } // 현재 레이아웃 확정

        indicatorLeading?.isActive = false
        indicatorWidth?.isActive = false
        indicatorLeading = indicatorView.leadingAnchor.constraint(equalTo: targetButton.leadingAnchor, constant: indicatorInset)
        indicatorWidth = indicatorView.widthAnchor.constraint(equalTo: targetButton.widthAnchor, constant: -2 * indicatorInset)
        indicatorLeading?.isActive = true
        indicatorWidth?.isActive = true

        selectedIndex = index

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }
}
