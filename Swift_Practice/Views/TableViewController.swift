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
    
    private let disposeBag = DisposeBag()

    let sections = [
        SectionOfCustomData(header: "First section", items: [CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero), CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)) ]),
        SectionOfCustomData(header: "Second section", items: [CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
    ]
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: configureCell, titleForHeaderInSection: titleForHeaderInSection, canEditRowAtIndexPath: canEditRowAtIndexPath)

    private lazy var configureCell: RxTableViewSectionedReloadDataSource<SectionOfCustomData>.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, item) in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        cell.textLabel?.text = item.aString
        return cell
    }

    private lazy var titleForHeaderInSection: RxTableViewSectionedReloadDataSource<SectionOfCustomData>.TitleForHeaderInSection = { [weak self] (dataSource, indexPath) in
        return dataSource.sectionModels[indexPath].header
    }
    
    private lazy var canEditRowAtIndexPath:
        RxTableViewSectionedReloadDataSource<SectionOfCustomData>.CanEditRowAtIndexPath = { [weak self] (dataSource, indexPath) in
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Table"
        
        self.bind()
    }
    
    func bind()
    {
        Observable.just(self.sections)
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tableView.rx
            .itemDeleted
            .subscribe({
              print("\($0)")
            })
            .disposed(by: disposeBag)
    }
}

