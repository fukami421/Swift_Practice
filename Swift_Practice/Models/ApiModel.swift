//
//  ApiModel.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/02/01.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation

struct ApiModel: Codable
{
    let total_count: Int
    let items: [Item]
    
    struct Item: Codable{
        let login: String
        let avatar_url: String
    }
}

