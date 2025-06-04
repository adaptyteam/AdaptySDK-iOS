//
//  ViewController.swift
//  OctoflowsDemo-UIKit
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func logoutPressed(_ sender: UIButton) {
        UserDefaults.standard.didFinishOnboarding = false
        OnboardingManager.shared.resolveApplicationState()
    }
}

extension ViewController {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    static func instantiate() -> UIViewController {
        storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
    }
}
