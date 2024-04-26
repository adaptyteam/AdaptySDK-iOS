//
//  SwiftUIViewController.swift
//  AdaptyUIDemo
//
//  Created by Aleksey Goncharov on 7.2.24..
//

import UIKit

class SwiftUIViewController: UIViewController {
    let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubSwiftUIView(MainView().environmentObject(viewModel),
                          to: view)
    }
}
