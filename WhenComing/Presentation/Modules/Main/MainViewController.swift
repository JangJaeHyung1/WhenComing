//
//  MainViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit

class MainViewController: UIViewController {

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
        setNavi()
        addViews()
        setConstraints()
        bind()
        fetch()
    }
    private func configure() {
        view.backgroundColor = .red
    }
    
    private func fetch() {
        
    }
    
    private func bind() {
        
    }
    
    private func setNavi() {
        //        self.navigationItem.title = "<#title#>"
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        //        self.navigationItem.largeTitleDisplayMode = .always
        //        self.navigationItem.setHidesBackButton(true, animated: true)
        //        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //        self.navigationController?.navigationBar.isHidden = false
        //        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func addViews() {
        
    }
    
    private func setConstraints() {
    }
}
