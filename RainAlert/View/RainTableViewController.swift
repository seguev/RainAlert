//
//  RainTableViewController.swift
//  RainAlert
//
//  Created by segev perets on 15/01/2023.
//

import UIKit

class RainTableViewController: UITableViewController {


    var rainForecast: [Rain] = []
    let viewModel = WeatherViewModel()
    let notificationViewModel = NotificationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.overrideUserInterfaceStyle = .light
        title = "6 hours forcast"
        title = "title"
        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        
//        tableView.clearsContextBeforeDrawing = false
        if rainForecast.isEmpty { view.addSubview(viewModel.showNoRainLabel(self.view)) }
    }
    
    
  

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !rainForecast.isEmpty {
            
//            let selections = rainForecast.map { [ $0["date"] as! Date : $0["isSelected"] as! Bool ] }
            
//            NotificationsStorage.shared.saveNotificationData(selections)
            
            update(rainForecast)
        }
    }
    
    private func update(_ updatedArray : [Rain]) {
        
          NotificationCenter.default.post(name: updateChangesInForcastArrayNotification, object: updatedArray)
      }


    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !rainForecast.isEmpty {
            return rainForecast.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !rainForecast.isEmpty else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "rainCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let background = cell.defaultBackgroundConfiguration()
        cell.backgroundConfiguration = background
        
        let forecast = rainForecast[indexPath.row]
        
        let time = viewModel.formattedCellDate(start: forecast.start, end: forecast.end)
        
        let precipitation = rainForecast[indexPath.row].PrecipitationType
        content.image = pickCellImage(PrecipitationType: precipitation)

        content.text = "\(rainForecast[indexPath.row].description) \(time)"
        
        cell.contentConfiguration = content
        
        
        cell.accessoryType = rainForecast[indexPath.row].isSelected ? .checkmark : .none
        
        
        return cell
    }
    
     
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var isSelected = rainForecast[indexPath.row].isSelected
        let precipitation = rainForecast[indexPath.row].PrecipitationType
        
        isSelected = !isSelected
                
        rainForecast[indexPath.row].isSelected = isSelected
        
        let notificationDate = rainForecast[indexPath.row].start
        if isSelected {
            notificationViewModel.notify(when: notificationDate,type: precipitation)
        } else {
            notificationViewModel.removeNotification(notificationDate)
        }
        
        tableView.reloadData()
    }

   
}

