//
//  TableViewModel.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/01/26.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TableViewModelInputs {
    var itemDeleted: AnyObserver<IndexPath>{ get }
    var itemMoved: AnyObserver<(sourceIndex: IndexPath, destinationIndex: IndexPath)>{ get }
//    var itemSelected: AnyObserver<IndexPath>{ get }
}

protocol TableViewModelOutputs {
    var dataSource: Observable<[SectionOfCustomData]> { get }
}

protocol TableViewModelType {
    var inputs: TableViewModelInputs { get }
    var outputs: TableViewModelOutputs { get }
}

class TableViewModel: TableViewModelType, TableViewModelInputs, TableViewModelOutputs
{
    // MARK: - Properties
    var inputs: TableViewModelInputs { return self }
    var outputs: TableViewModelOutputs { return self }
    
    let itemDeleted: AnyObserver<IndexPath>
    let itemMoved: AnyObserver<(sourceIndex: IndexPath, destinationIndex: IndexPath)>

    let dataSource: Observable<[SectionOfCustomData]>
    
    var sections = [
        SectionOfCustomData(header: "First section", numbers: [CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero), CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)), CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
//        ,
//        SectionOfCustomData(header: "Second section", numbers: [CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
    ]
    private let disposeBag   = DisposeBag()
    
    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
        let _itemDeleted = BehaviorRelay<IndexPath>(value: [])
        self.itemDeleted = AnyObserver<IndexPath> { event in
            guard let indexPath = event.element else {
                return
            }
            _itemDeleted.accept(indexPath)
        }
        
        let _itemMoved = BehaviorRelay<(sourceIndex: IndexPath, destinationIndex: IndexPath)>(value: ([], []))
        self.itemMoved = AnyObserver<(sourceIndex: IndexPath, destinationIndex: IndexPath)> { event in
            guard let indexPaths = event.element else {
                return
            }
            _itemMoved.accept((indexPaths))
        }
        
        // Ouputのpropertyの初期化
        let _dataSource = BehaviorRelay<[SectionOfCustomData]>(value: self.sections)
        self.dataSource = _dataSource.asObservable()
        
        // 削除された上での配列をdataSourceに流す
        _itemDeleted
            .filter { $0 != [] }
            .subscribe({ indexPath in
                self.sections[indexPath.element!.section].numbers.remove(at: indexPath.element!.row)
                _dataSource.accept(self.sections)
            })
            .disposed(by: self.disposeBag)
        
        //　移動した上での配列をdataSourcenに流す
        _itemMoved
            .filter { $0.0 != [] && $0.1 != []}
            .subscribe({ indexPath in
                let from = indexPath.element?.0
                let to = indexPath.element?.1
                
                let ele = self.sections[from!.section].numbers[from!.row]
                self.sections[from!.section].numbers.remove(at: from!.row)
                self.sections[to!.section].numbers.insert(ele, at: to!.row)
                _dataSource.accept(self.sections)
            })
            .disposed(by: self.disposeBag)
    }
}

