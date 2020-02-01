//
//  RealmViewModel.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/02/01.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

protocol RealmViewModelInputs {
    var addToDo: AnyObserver<String>{ get }
    var itemDeleted: AnyObserver<IndexPath>{ get }
//    var itemSelected: AnyObserver<IndexPath>{ get }
}

protocol RealmViewModelOutputs {
    var dataSource: Observable<[RealmModel]> { get }
}

protocol RealmViewModelType {
    var inputs: RealmViewModelInputs { get }
    var outputs: RealmViewModelOutputs { get }
}

class RealmViewModel: RealmViewModelType, RealmViewModelInputs, RealmViewModelOutputs
{
    
    // MARK: - Properties
    var inputs: RealmViewModelInputs { return self }
    var outputs: RealmViewModelOutputs { return self }
    
    let addToDo: AnyObserver<String>
    let itemDeleted: AnyObserver<IndexPath>

    let dataSource: Observable<[RealmModel]>
    var realmData: [RealmModel]?
    
    private let disposeBag   = DisposeBag()
    
    let realm = try! Realm()

    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
        let _addToDo = BehaviorRelay<String>(value: "")
        self.addToDo = AnyObserver<String> { event in
            guard let str = event.element else {
                return
            }
            _addToDo.accept(str)
        }
        
        let _itemDeleted = BehaviorRelay<IndexPath>(value: [])
        self.itemDeleted = AnyObserver<IndexPath> { event in
            guard let indexPath = event.element else {
                return
            }
            _itemDeleted.accept(indexPath)
        }
                
        // Ouputのpropertyの初期化
        let _dataSource = BehaviorRelay<[RealmModel]>(value: [])
        self.dataSource = _dataSource.asObservable()
        
        
        // buttonをtapした際にtextFieldの値をRealmに登録
        _addToDo
            .filter{ $0 != "" }
            .subscribe(onNext: { memo in
                let realmModel: RealmModel = RealmModel()
                realmModel.memo = memo

                // dataを追加
                try! self.realm.write {
                    self.realm.add(realmModel)
                }
                // tableViewに表示用のdataを更新
                let _data = self.realm.objects(RealmModel.self)
                _dataSource.accept(Array(_data))
            })
            .disposed(by: self.disposeBag)

        // 削除された上での配列をdataSourceに流す
        _itemDeleted
            .filter { $0 != [] }
            .subscribe({ indexPath in
                try! self.realm.write {
                    self.realm.delete(_dataSource.value[indexPath.element!.row])
                }
                self.realmData?.remove(at: indexPath.element!.row)
                _dataSource.accept(self.realmData!)
            })
            .disposed(by: self.disposeBag)
        
        // 画面表示時の値を設定
        let _data = realm.objects(RealmModel.self)
        self.realmData = Array(_data)
        _dataSource.accept(self.realmData!)
    }
}

