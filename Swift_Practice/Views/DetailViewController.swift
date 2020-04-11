//
//  DetailViewController.swift
//  Swift_Practice
//
//  Created by 深見龍一 on 2020/01/31.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!{
        didSet{
            self.image.tintColor = .red
            print("red")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
