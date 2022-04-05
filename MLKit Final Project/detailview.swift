//
//  detailview.swift
//  MLKit Final Project
//
//  Created by CLWang on 2021/5/22.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
class detailview: UIViewController{
    @IBOutlet weak var resultView: UITextView!
    var name_ch:String!
    var name_en:String!
    var property:String!
    var acne:Int!
    var pimple:Int!
    override func viewDidLoad() {
        self.title = name_en
        resultView.text = "Chinese: "+"\(name_ch!)\n"+"Property: "+"\(property!)\n"+"Acne point: "+"\(acne!)\n"+"Pimple point: "+"\(pimple!)"
    }
    
}
