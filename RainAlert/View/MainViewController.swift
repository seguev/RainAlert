//
//  MainViewController.swift
//  RainAlert
//
//  Created by segev perets on 25/12/2022.
//

import UIKit
import WeatherKit
import CoreLocation

let settingsDidChangeNotification = Notification.Name("settingsDidChange")

class MainViewController: UIViewController, UICollectionViewDelegate, WeatherViewModelDelegate, NotificationViewModelDelegate {

    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var currentConditionLabel: UILabel!
    @IBOutlet weak var upperActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentConditionImageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dayCollectionView: UICollectionView!
    
    
    let locationManager = CLLocationManager()
    let weatherViewModel = WeatherViewModel()
    let notificationViewModel = NotificationViewModel()
    
    var rainForecast = [Rain]()
    
    var currentWeather: CurrentWeather?
    
    var dayWeatherArray: [DayWeather]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        initialSetup()
        
        weatherViewModel.delegate = self
        notificationViewModel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotAuthorizationAndCanContinue(_:)), name: isAuthorizeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: settingsDidChangeNotification, object: nil)
    }
        
    @objc private func gotAuthorizationAndCanContinue (_ notificaion:Notification) {
        print(#function)
        
        guard let location = notificaion.object as? CLLocation else {return}
        
        weatherViewModel.updateWeather(location)
        
    }
    @objc private func updateUI (_ notificaion:Notification) {
        
        dayCollectionView.reloadData()
        DispatchQueue.main.async {
            self.currentTempLabel.text = self.weatherViewModel.fetchCurrentTempLabel()
        }
        

    }



     private func initialSetup() {
        setCurrentViewShadow()
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
         dayCollectionView.showsHorizontalScrollIndicator = false
        let Layout = UICollectionViewFlowLayout()
        Layout.scrollDirection = .horizontal
        Layout.itemSize = CGSize(width: 100, height: 100)
        dayCollectionView.collectionViewLayout = Layout
  
    }
    
    private func setCurrentViewShadow () {
        currentWeatherView.backgroundColor = #colorLiteral(red: 0.6435242847, green: 0.8330116422, blue: 0.9607843137, alpha: 1)
        currentWeatherView.layer.cornerRadius = 10
        currentWeatherView.layer.shadowColor = UIColor.black.cgColor
        currentWeatherView.layer.shadowOffset = .init(width: 1, height: 1)
        currentWeatherView.layer.shadowOpacity = 0.8
        currentWeatherView.layer.shadowRadius = 3
    }
    

    
    
    
    @IBAction func notificationButtonPressed(_ sender: UIButton) {
        Task {
            let pendingNotifications = await notificationViewModel.pendingRequests()
            
            notificationViewModel.updateRainForcast(pendingNotifications, rainArray: &rainForecast)
        
            let alert = UIAlertController(title: "These are all of the notification you've scheduled", message: "Select a notification you want to cancel", preferredStyle: .actionSheet)
            
            for request in pendingNotifications {
                
                alert.addAction(UIAlertAction(title: "\(request.content.title)", style: .default, handler: { [unowned self] _ in
                    
                    notificationViewModel.notificationCenter.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    
                    if let index = self.rainForecast.firstIndex(where: { $0.start.description == request.identifier }) {
                        self.rainForecast[index].isSelected = false
                    } else { fatalError("could not find rain index")}
                    
                    rainForecast.removeAll { $0.start.description == request.identifier }
                }))
            }
            alert.addAction(UIAlertAction(title: "Delete all", style: .destructive, handler: { _ in
                
                self.notificationViewModel.removeAllNotification()
                
                self.notificationViewModel.deselectEveryRainForcast(rainArray: &self.rainForecast)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    
    

    
    @objc func updateMinuteArrayToNotifyProps (_ notification:Notification) {
        let updatedArray = notification.object as! [Rain]
        rainForecast = updatedArray
        
    }
    
    
    
    
    // MARK: - collectionView delegate funcs

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let scrollIndication = UISelectionFeedbackGenerator()
        scrollIndication.prepare()
        scrollIndication.selectionChanged()
    }
    
}






// MARK: - UICollectionViewDataSource
extension MainViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let dayWeatherArray = dayWeatherArray {
                return dayWeatherArray.count
            }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        if collectionView == self.dayCollectionView {
            let hourCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCollectionViewCell", for: indexPath) as! DayCollectionViewCell
            
            if let forcast = dayWeatherArray {
                hourCell.config(forcast[indexPath.row])
            }

            return hourCell
            
        }

        return UICollectionViewCell()
    }
    
    
}
// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    
    
    
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !rainForecast.isEmpty {
            return rainForecast.count
        } else {
            return 0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !rainForecast.isEmpty else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "rainCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()

        
        let forecast = rainForecast[indexPath.row]
        
        let time = weatherViewModel.formattedCellDate(start: forecast.start, end: forecast.end)
        
        let precipitation = rainForecast[indexPath.row].PrecipitationType
        content.image = pickCellImage(PrecipitationType: precipitation)

        content.text = "\(rainForecast[indexPath.row].description) \(time)"
        
        cell.contentConfiguration = content
        
        
        cell.accessoryType = rainForecast[indexPath.row].isSelected ? .checkmark : .none
        
        
        return cell
    }
    

     
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var isSelected = rainForecast[indexPath.row].isSelected
        let precipitation = rainForecast[indexPath.row].PrecipitationType
        
        isSelected = !isSelected
                
        rainForecast[indexPath.row].isSelected = isSelected
        
        let notificationDate = rainForecast[indexPath.row].start
        if isSelected {
            let scheduledDate = notificationViewModel.notify(when: notificationDate,type: precipitation)
            showNotificationSetPopup("notification has been set to \(scheduledDate!.formatted(date: .omitted, time: .shortened))")

        } else {
            let scheduledDate = notificationViewModel.removeNotification(notificationDate)
            showNotificationSetPopup("notification has been removed from \(scheduledDate!.formatted(date: .omitted, time: .shortened))")
        }
        
        
        tableView.reloadData()
    }

    private func showNotificationSetPopup (_ text:String) {
        let label = UILabel(frame: .init(x: 0, y: 0, width: 180, height: 60))
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        label.center = .init(x: view.center.x, y: view.frame.height - label.frame.height )
        label.backgroundColor = .black
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.alpha = 0
        
        view.addSubview(label)
        label.bringSubviewToFront(view)
        
        UIView.animate(withDuration: 0.2) {
            label.alpha = 0.7
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            UIView.animate(withDuration: 0.2, delay: 1) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }
}


