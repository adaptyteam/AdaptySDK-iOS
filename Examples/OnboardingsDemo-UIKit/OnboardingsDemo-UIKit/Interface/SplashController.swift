//
//  SplashController.swift
//  OctoflowsDemo-UIKit
//
//  Created by Aleksey Goncharov on 02.08.2024.
//

import UIKit

final class SplashView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        let imageView = UIImageView(image: UIImage(named: "SplashIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .accent
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        addSubview(imageView)
        addSubview(activityIndicator)
        
        addConstraints([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32)
        ])
        
        imageView.addConstraints([
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SplashController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splashView = SplashView(frame: .zero)
        splashView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(splashView)
        view.addConstraints([
            splashView.topAnchor.constraint(equalTo: view.topAnchor),
            splashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
