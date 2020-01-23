//
//  ExampleViewController.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/01/23.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ExampleViewController: UIViewController {

    @IBOutlet weak var activityBtn: UIButton!
    
    let activityIndicator = UIActivityIndicatorView()
    var isAnimating:Bool = true

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)

        self.bind()
    }

    func bind()
    {
        // UIActivityIndicatorViewをボタンで表示・非表示切り替える
        self.activityBtn.rx.tap
            .subscribe({_ in
                self.isAnimating.toggle()
                self.isAnimating ? self.activityIndicator.startAnimating(): self.activityIndicator.stopAnimating()
            })
            .disposed(by: self.disposeBag)
    }
}
