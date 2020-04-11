//
//  TableViewController.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/01/23.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var editBarButton: UIBarButtonItem!

    private let viewModel: TableViewModel = TableViewModel()
    private let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>!
    
    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "")
        cell.textLabel?.text = item.aString
        cell.textLabel?.textColor = Asset.Colors.Folder0.testWhite.color
        return cell
    }

    private lazy var titleForHeaderInSection: RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>.TitleForHeaderInSection = { [weak self] (dataSource, indexPath) in
        return dataSource.sectionModels[indexPath].header
    }
    
    private lazy var canEditRowAtIndexPath:
    RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>.CanEditRowAtIndexPath = { _, _ in
        return true
    }
    
    private lazy var canMoveRowAtIndexPath: RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>.CanMoveRowAtIndexPath = { _, _ in
           return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Table"
        self.setupDataSource()
        self.setupNavigationBar()
        self.bindViewModel()
        self.tableView.isEditing = false
    }

    private func setupNavigationBar() {
        editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        navigationItem.rightBarButtonItems = [editBarButton]
    }

    private func setupDataSource() {
        self.dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .right,
                                                           reloadAnimation: .none,
                                                           deleteAnimation: .fade),
            configureCell: configureCell,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath
        )
    }

    func bindViewModel()
    {
        // viewModelのdataSourceをtableViewにbind
        self.viewModel.outputs.dataSource
            .bind(to: tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        // cellのdelete
        self.tableView.rx
            .itemDeleted
            .bind(to: self.viewModel.inputs.itemDeleted)
            .disposed(by: disposeBag)
        
        // cellのmove
        self.tableView.rx
            .itemMoved
            .bind(to: self.viewModel.inputs.itemMoved)
            .disposed(by: self.disposeBag)
        
        // editBarButtonの情報をtableView.setEditingに伝える
        self.editBarButton.rx.tap
            .map{ [unowned self] in self.tableView.isEditing }
            .subscribe(onNext: { [unowned self] result in
                self.tableView.setEditing(!result, animated: true)
            })
            .disposed(by: self.disposeBag)
                
        // cellをタップしてページ遷移
        self.tableView.rx.modelSelected(CustomData.self)
            .subscribe({ data in
                let vc = DetailViewController.init(nibName: nil, bundle: nil)
                vc.title = data.element?.aString
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
}
