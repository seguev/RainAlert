//
//  Networking.swift
//  RainAlert
//
//  Created by segev perets on 26/02/2023.
//

import UIKit
import WeatherKit
import CoreLocation

struct Networking {
    static let shared = Networking()
    
    
    
    //    private let geoCoder = CLGeocoder()
    private let weatherService = WeatherService()
    let locationManager = CLLocationManager()
    
    
    
    func weatherKitFetchWeather (_ location:CLLocation) async -> (CurrentWeather, Forecast<DayWeather>)? {
        do {
            return try await weatherService.weather(for: location, including: .current, .daily)
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            return nil
        }
    }
    
    /**call makeRainDictionary(decodedData)**/
     func fetchForcastFromAPI (_ location:CLLocation) async -> WeatherData {
         
         await withUnsafeContinuation({ continuation in
             
        let baseString = "https://api.tomorrow.io/v4/timelines?"
        let coordinate = location.coordinate
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        
        let parameters = "location=\(lat),\(lon)&fields=precipitationType,temperature,weatherCode&timesteps=30m&units=metric&apikey="
        
        let completeString = baseString+parameters+Keys.apiKey
        
             URLSession.shared.dataTask(with: URL(string: completeString)!) { data, _, error in
                 if let error {
                     print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
                 } else if let data {
//                print("*** Data : \(String(data: data, encoding: .utf8)!)")
                     guard let decodedData = try? JSONDecoder().decode(WeatherData.self, from: data) else {print("could not decode data!");return}
                     
                     continuation.resume(returning: decodedData)
                     
                 }
             }.resume()
         })
    }
   
    
    
}
