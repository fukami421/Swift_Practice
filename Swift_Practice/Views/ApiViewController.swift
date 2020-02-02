//
//  ApiViewController.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/02/01.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class ApiViewController: UIViewController {

    private let viewModel: ApiViewModel = ApiViewModel()
    private let disposeBag = DisposeBag()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Call API"
        self.bindViewModel()
    }
    
    fileprivate func bindViewModel()
    {
        self.searchBar.rx.text
            .bind(to: self.viewModel.inputs.searchText)
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs.users
            .filter{ $0.count > 0 }
            .bind(to: self.tableView.rx.items){tableView, row, element in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
                cell.textLabel?.text = element.login
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.text = element.avatar_url
                return cell
        }
        .disposed(by: self.disposeBag)
    }
}
