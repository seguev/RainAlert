//
//  NotificationModel.swift
//  RainAlert
//
//  Created by segev perets on 06/12/2022.
// xcrun simctl push 00008101-001E15911192001E co.swego26.RainAlert notification.apns

import UIKit
import UserNotifications

protocol NotificationViewModelDelegate : MainViewController {
    var rainForecast: [Rain] {get set}
}

class NotificationViewModel  {

    weak var delegate : NotificationViewModelDelegate?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    

    
    
    
    
    
    
    func pendingRequests () async -> [UNNotificationRequest] {
        let requests = await notificationCenter.pendingNotificationRequests()
        print("Found \(requests.count) pending notifications")
        return requests
    }
    /**
     - feches notificationCenter.pendingRequests
     - hides notification button if  .count == 0
     - updates app.badge
     */
    func pendingNotificationUpdate () {
        
        Task {
            let requests = await pendingRequests()
            do {
                try await notificationCenter.setBadgeCount(requests.count)
                
            } catch {
                print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            }
            guard var rainArray = await delegate?.rainForecast else {fatalError("delegate.rainArray == nil !!!")}
            updateRainForcast(requests, rainArray: &rainArray)
        }
    }
    
    func updateRainForcast (_ requests:[UNNotificationRequest], rainArray: inout [Rain]) {
       
       //cross reference request.identifier and rainArray[i].start
       var table = [String:Bool]()
       
       for i in 0..<requests.count {
           let requestString = requests[i].identifier
           table[requestString] = true
       }
       
       for i in 0..<rainArray.count {
           let rainString = rainArray[i].start.description
           if table[rainString] == true {
               rainArray[i].isSelected = true
           }
       }
   }
    
    func deselectEveryRainForcast (rainArray : inout [Rain]) {
        for r in 0..<rainArray.count {
            rainArray[r].isSelected = false
        }
    }
    
    /**
     identifier = eventTime.description, trigger = eventTime - 30m .
     */
    func notify (when eventTime:Date, type:PrecipitationType) {
        
        let notificationTime = Date(timeInterval: -(60*30), since: eventTime)

        
        print("notification has been set to \(notificationTime.formatted(date: .numeric, time: .shortened))")
        
        let content = UNMutableNotificationContent()
        
        let DF = DateFormatter()
        DF.dateFormat = "HH:mm a"
        let eventTimeFormatted = DF.string(from: eventTime)
        content.title = "\(type.rawValue) at \(eventTimeFormatted)"
        
        let sound = UNNotificationSound(named: UNNotificationSoundName("thunder.wav"))
        content.sound = sound
        content.interruptionLevel = .timeSensitive
        
        let theDateComponents = turnDateToComponent(notificationTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: theDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: eventTime.description, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    
    
    
    func removeNotification (_ date:Date) {
        let notificationTime = Date(timeInterval: -(60*30), since: date)
        print("Removing notification from \(notificationTime)")
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [date.description])
    }
    
    func removeAllNotification () {
        print("all of the notification have been removed!")
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    
    
    
    
    private func turnDateToComponent(_ date:Date) -> DateComponents {
        
        let dateFormatter = DateFormatter()
        let year = dateFormatter.calendar.component(.year, from: date)
        let month = dateFormatter.calendar.component(.month, from: date)
        let day = dateFormatter.calendar.component(.day, from: date)
        let hour = dateFormatter.calendar.component(.hour, from: date)
        let minute = dateFormatter.calendar.component(.minute, from: date)
        
        return DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    }
    
    
    
    let activeNotificationsPathUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("activeNotifications")
    
    var LoadedNotificationArray = [Date]()
    
    
    func saveNotificationData (_ selections:[[Date:Bool]]) {
        guard let path = activeNotificationsPathUrl else {fatalError("no path")}
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(selections)
            try data.write(to: path)
            print("Saved \(selections.count) new items.")
        } catch {
            print("could not save : \(error)")
        }
    }
    
    
    func loadNotificationData () -> [[Date:Bool]]? {
        print(#function)
        guard let path = activeNotificationsPathUrl else {fatalError("no path")}
        let decoder = PropertyListDecoder()
        
        do {
            let data = try Data(contentsOf: path)
            let decodedData = try decoder.decode([[Date:Bool]].self, from: data)
            print("Loaded \(decodedData.count) items")
            return decodedData
        } catch {
            print("could not find load : \(error)")
        }
        return nil
    }
    
    func deleteAllSavedData () {
        guard let path = activeNotificationsPathUrl else {fatalError("no path")}
        print("deleting all saved data")
        do {
            try FileManager.default.removeItem(at: path)
            
        } catch {
            print("could not delete path \(error)")
        }
        
        
    }
    

    
}
