//
//  SetRegionViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SetRegionViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var vm = BusStationDIContainer().makeBusStationViewModel()

    private var collectionViewDataSource: UICollectionViewDiffableDataSource<Int, BusCityCodeEntity>!
    private var collectionView: UICollectionView!
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "도시 이름을 검색하세요"
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.backgroundImage = UIImage()
        sb.barTintColor = .clear
        sb.searchTextField.backgroundColor = .secondarySystemBackground
        return sb
    }()
    
    private let nextBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .systemGray4
        btn.isEnabled = false
        btn.tintColor = .white
        btn.setTitle("다음", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - variables
    
    var selectedCityCode: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


extension SetRegionViewController {
    private func setUp() {
        configure()
        setCollectionView()
        setNavi()
        addViews()
        setConstraints()
        bind()
        fetch()
    }
    
    
    
    private func setCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CityCell.self, forCellWithReuseIdentifier: CityCell.cellId)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        
        collectionCellUI()
        
        collectionView.delegate = self
        collectionViewDataSource = UICollectionViewDiffableDataSource<Int, BusCityCodeEntity>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCell.cellId, for: indexPath) as? CityCell
            cell?.configure(with: item)
            return cell
        }
    }
    private func configure() {
        view.backgroundColor = .systemBackground
        if let localCityCode = vm.loadCityCode() {
            nextVC(cityCode: localCityCode)
        }
    }
    
    private func fetch() {
        vm.input.fetchCityCodesTrigger.accept(())
        
    }
    func enableBtn() {
        nextBtn.isEnabled = true
        nextBtn.backgroundColor = .label
    }
    
    private func bind() {
        // MARK: - input
        
        
        // MARK: - items
        vm.output.cityCodes
            .drive(onNext: { [weak self] items in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Int, BusCityCodeEntity>()
                snapshot.appendSections([0])
                snapshot.appendItems(items, toSection: 0)
                collectionViewDataSource.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        vm.output.error.asObservable()
            .subscribe(onNext:{ [weak self] res in
                guard let self else { return }
                print("🔴error:\(res.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: vm.input.searchQuery)
            .disposed(by: disposeBag)
        
        
        // MARK: - btn event
        nextBtn.rx.tap
            .subscribe(onNext:{ [weak self] res in
                guard let self else { return }
                if let selectedCityCode {
                    nextVC(cityCode: selectedCityCode)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setNavi() {
        self.navigationItem.title = "지역이 어디인가요?"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func addViews() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(nextBtn)
    }
    
    private func setConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        nextBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-18)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-12)
        }
    }
}



extension SetRegionViewController: UICollectionViewDelegateFlowLayout,  UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interval:CGFloat = 8
        let width: CGFloat = ( UIScreen.main.bounds.width - interval * 3 - ( 12 * 2)) / 3
        return CGSize(width: width , height: 48 )
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    //collection VC section 마진값
    func collectionCellUI(){
        let interval:CGFloat = 12
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: interval , left: interval, bottom: interval, right: interval)
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let entity = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        print("선택된 지역: \(entity.name), \(entity.code)")
        selectedCityCode = entity.code
        enableBtn()
    }
}

// MARK: - navi
extension SetRegionViewController {
    func nextVC(cityCode: Int) {
        vm.saveCityCode(cityCode)
        let mainVC = MainViewController()
        UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: mainVC)
        
//        let scene = UIApplication.shared.connectedScenes.first
//        if let windowScene = scene as? UIWindowScene,
//           let window = windowScene.windows.first {
//            let mainVC = MainViewController()
//            window.rootViewController = UINavigationController(rootViewController: mainVC)
//            window.makeKeyAndVisible()
//        }
    }
}
