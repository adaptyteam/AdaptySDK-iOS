//
//  InAppContainersTableViewController.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 03/01/2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import UIKit
import Adapty

class InAppContainersTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var containers: [PurchaseContainerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func loadData() {
        Adapty.getPurchaseContainers { (containers, error) in
            self.tableView.refreshControl?.endRefreshing()
            self.containers = containers ?? []
            self.tableView.reloadData()
        }
    }
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        setUI(enabled: false)
        Adapty.restorePurchases { (error) in
            self.setUI(enabled: true)
            self.showAlert(for: error)
        }
    }

}

extension InAppContainersTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        
        cell.textLabel?.text = containers[indexPath.row].developerId
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return containers.count
    }
    
}

extension InAppContainersTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "\(InAppTableViewController.self)") as? InAppTableViewController else {
            return
        }
        
        vc.containerToShow = containers[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
