//
//  MainViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {

    private let segmentControlView: SegmentControlView = {
        let view = SegmentControlView(titles: ["출근길", "퇴근길"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // 출퇴근 코멘트 배열 이후 랜덤 처리 예정
    var goWorkComment = "오후 3시 이전은 출근길입니다."
    var leaveWorkComment = "오후 3시 이후는 퇴근길입니다."
    
    private let bottomGuideLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
}



extension MainViewController {
    private func setUp() {
        configure()
        setTableView()
        setNavi()
        addViews()
        setConstraints()
        bind()
        updateSegmentForCurrentTime()
        fetch()
    }
    private func configure() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetch() {
        
    }

    private func setTableView(){
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(NextButtonCell.self, forCellReuseIdentifier: NextButtonCell.cellId)
        
        tableView.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        refreshControl.transform = .init(scaleX: 0.75, y: 0.75)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    /// 03:00 ≤ now < 15:00  => 출근(0)
    /// 15:00 ≤ now < 03:00 => 퇴근(1)
    private func updateSegmentForCurrentTime() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let isCommuteTime = (hour >= 3 && hour < 15)
        let targetIndex = isCommuteTime ? 0 : 1
        segmentControlView.select(index: targetIndex, animated: false)
        setBottomGuideLbl()
    }
    
    private func setBottomGuideLbl() {
        bottomGuideLbl.text = segmentControlView.selectedIndex == 0 ? goWorkComment : leaveWorkComment
    }
    
    private func bind() {
        segmentControlView.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func handleRefresh() {
        fetch()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func segmentChanged(_ sender: SegmentControlView) {
        setBottomGuideLbl()
        switch sender.selectedIndex {
        case 0:
            // 출근길 탭 선택 시 처리
            print("출근길 탭 선택")
        case 1:
            // 퇴근길 탭 선택 시 처리
            print("퇴근길 탭 선택")
        default:
            break
        }
    }
    
    private func setNavi() {
        self.navigationItem.title = "언제오지"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func addViews() {
        view.addSubview(segmentControlView)
        view.addSubview(tableView)
        view.addSubview(bottomGuideLbl)
    }
    
    private func setConstraints() {
        
        segmentControlView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentControlView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomGuideLbl.snp.top).offset(-16)
        }
        
        bottomGuideLbl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastIndex(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NextButtonCell.cellId, for: indexPath) as! NextButtonCell
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Row \(indexPath.row)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLastIndex(indexPath) {
            presentSearchViewController()
        } else {
            
        }
    }
    
    private func isLastIndex(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
    
}

extension MainViewController {
    func presentSearchViewController() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}
