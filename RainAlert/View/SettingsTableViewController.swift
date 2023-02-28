//
//  TableViewController.swift
//  RainAlert
//
//  Created by segev perets on 27/02/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsViewModelDelegate {
    
    
    
    var settings: [Setting] = Setting.allCases
    
    let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = settings[indexPath.row].rawValue
        
        if settings[indexPath.row] == .temperature {
            cell.addSubview(viewModel.addCellSegmentedControl(cell))
        } else if settings[indexPath.row] == .headsup {
            cell.addSubview(viewModel.addCellSlider(cell))
        }
        
        return cell
    }
    
    // MARK: - saving functionality
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var slider : UISlider?
        var segmentedControl : UISegmentedControl?
        
        for cell in tableView.visibleCells {
            if let cellSlider = cell.subviews.filter({$0 is UISlider}).first as? UISlider {slider = cellSlider}
            if let cellSegmentedControl = cell.subviews.filter({$0 is UISegmentedControl}).first as? UISegmentedControl {segmentedControl = cellSegmentedControl }
        }
        
        if let slider {
            
            UserDefaults.standard.set(Int(slider.value), forKey: "headsup")
        }
        
        if let segmentedControl, let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
            UserDefaults.standard.set(title, forKey: "unit")
        }
        
        NotificationCenter.default.post(name: settingsDidChangeNotification, object: nil)
        
    }
}
