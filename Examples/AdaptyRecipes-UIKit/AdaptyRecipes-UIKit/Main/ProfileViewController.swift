//
//  ProfileViewController.swift
//  AdaptyRecipes-UIKit
//
//  Created by Aleksey Goncharov on 08.08.2024.
//

import UIKit

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubSwiftUIView(
            ProfileView()
                .environmentObject(MainViewModel.shared),
            to: view)
    }
}
