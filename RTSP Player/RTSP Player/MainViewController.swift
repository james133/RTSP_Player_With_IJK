//
//  MainViewController.swift
//  RTSP Player
//
//  Created by Hoang Minh Nhat on 5/24/19.
//  Copyright © 2019 GST. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    enum MainScreenCellEnum: Int {
        case IJKPlayer = 0
        case MainScreenCellEnumCount
    }
    
    @IBOutlet weak var tableViewMain: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "RTSP Player"
        
        setUpTableView(tableViewMain)
        registerTableViewCell(tableViewMain)
    }

    // MARK: - TableView setup
    private func setUpTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerTableViewCell(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
    }
    
    private func mainScreenCellIdentifier(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case MainScreenCellEnum.IJKPlayer.rawValue:
            return "MainTableViewCell"
        default:
            return ""
        }
    }
    
    private func titleForTableViewCell(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case MainScreenCellEnum.IJKPlayer.rawValue:
            return "IJKPlayer"
        default:
            return ""
        }
    }
    
    // MARK: - Push View Controller
    private func pushViewController(for indexPath: IndexPath) {
        switch indexPath.row {
        case MainScreenCellEnum.IJKPlayer.rawValue:
            pushToIJKPlayerScreen()
        default:
            break
        }
    }
    
    private func pushToIJKPlayerScreen() {
        performSegue(withIdentifier: "MainToIJKPlayer", sender: nil)
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  MainScreenCellEnum.MainScreenCellEnumCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = mainScreenCellIdentifier(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let mainCell = cell as? MainTableViewCell {
            mainCell.textLabel?.text = titleForTableViewCell(for: indexPath)
        }
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        pushViewController(for: indexPath)
    }
}
