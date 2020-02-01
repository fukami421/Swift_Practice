//
//  RealmViewController.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/02/01.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class RealmViewController: UIViewController {

    @IBOutlet weak var toDoTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: RealmViewModel = RealmViewModel()
    private let disposeBag = DisposeBag()
    private var data = BehaviorRelay<[RealmModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Realm"
        self.bindViewModel()
        let realm = try! Realm()
        let _data = realm.objects(RealmModel.self)
        self.data.accept(Array(_data))
    }
    
    fileprivate func bindViewModel()
    {
        // dataをUITableViewのCellにbind
        self.viewModel.outputs.dataSource
            .filter({_ in
                self.toDoTextField.text = ""
                return true
            })
            .bind(to: self.tableView.rx.items){tableView, row, element in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
                cell.textLabel?.text = element.memo
                cell.textLabel?.textColor = .black
                return cell
        }
        .disposed(by: self.disposeBag)
        
        // buttonをtapした際のイベント
        self.addBtn.rx.tap
            .filter{
                self.toDoTextField.endEditing(true)
                return self.toDoTextField.text! != ""
            }
            .map{ [unowned self] in self.toDoTextField.text! }
            .bind(to: self.viewModel.inputs.addToDo)
            .disposed(by: self.disposeBag)
        
        // return keyを押したらkeyboardを閉じる
        self.toDoTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe{ _ in
                self.toDoTextField.endEditing(true)
            }
            .disposed(by: self.disposeBag)
        
        // cellのdelete
        self.tableView.rx
            .itemDeleted
            .bind(to: self.viewModel.inputs.itemDeleted)
            .disposed(by: disposeBag)
    }
}
