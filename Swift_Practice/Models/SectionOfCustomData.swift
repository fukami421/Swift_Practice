//
//  SectionOfCustomData.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/01/24.
//  Copyright © 2020 深見龍一. All rights reserved.
//

//import Foundation
import RxDataSources

struct CustomData {
  var anInt: Int
  var aString: String
  var aCGPoint: CGPoint
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
  typealias Item = CustomData

   init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}
