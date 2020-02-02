//
//  ApiViewModel.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/02/01.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol ApiViewModelInputs {
    var searchText: AnyObserver<String?>{ get }
}

protocol ApiViewModelOutputs {
    var users: Observable<[ApiModel.Item]> { get }
}

protocol ApiViewModelType {
    var inputs: ApiViewModelInputs { get }
    var outputs: ApiViewModelOutputs { get }
}

class ApiViewModel: ApiViewModelType, ApiViewModelInputs, ApiViewModelOutputs
{
    // MARK: - Properties
    var inputs: ApiViewModelInputs { return self }
    var outputs: ApiViewModelOutputs { return self }
    
    let searchText: AnyObserver<String?>

    let users: Observable<[ApiModel.Item]>

    private let disposeBag   = DisposeBag()
    
    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
        let _searchText = BehaviorRelay<String>(value: "")
        self.searchText = AnyObserver<String?> { event in
            guard let text = event.element else {
                return
            }
            _searchText.accept(text!)
        }
        
        // Ouputのpropertyの初期化
        let _users = PublishRelay<ApiModel>()
        self.users = _users.asObservable()
            .map{ data in data.items }

        // searchTextからAPIを叩き結果を_usersに流す
        _searchText
            .filter{ $0 != "" }
            .flatMap{ self.createSingle(q: $0) }
            .bind(to: _users)
            .disposed(by: self.disposeBag)
    }
    
    func createSingle(q: String) -> Single<ApiModel> {
        return Single<ApiModel>.create { singleEvent in
            let request = Alamofire.request("https://api.github.com/search/users?q=" + q,
                                            method: .get,
                                            parameters: nil)
                .responseJSON { response in
                    switch response.result {
                        case .success:
                            guard let data = response.data else {
                                return
                            }
                            let decoder = JSONDecoder()
                            do
                            {
                                let items: ApiModel = try decoder.decode(ApiModel.self, from: data)
                                singleEvent(.success(items))
                            } catch {
                                print("error:")
                                print(error)
                            }
                        case .failure(let error):
                            singleEvent(.error(error))
                        }
            }
            return Disposables.create { request.cancel() }
        }
    }
}

