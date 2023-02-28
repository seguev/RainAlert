//
//  WeatherViewModel.swift
//  RainAlert
//
//  Created by segev perets on 26/02/2023.
//

import UIKit
import WeatherKit
import CoreLocation

protocol WeatherViewModelDelegate : MainViewController {
//    var rainForecast : [(Precipitation:PrecipitationType,start:Date,end:Date,isSelected:Bool)]? {get set}
    var rainForecast: [Rain] {get set}
    var currentWeather : CurrentWeather? {get set}
    var dayWeatherArray : [DayWeather]? {get set}
    func updateUI ()
}

extension WeatherViewModelDelegate {
    func updateUI () {
        guard self.currentWeather != nil else {fatalError()}
        DispatchQueue.main.async {
            self.upperActivityIndicator.stopAnimating()
            self.activityIndicator.stopAnimating()
            self.currentTempLabel.isHidden = false
            self.currentConditionLabel.isHidden = false
            self.currentConditionImageLabel.isHidden = false
            self.currentTempLabel.text = self.weatherViewModel.fetchCurrentTempLabel()
            self.currentConditionLabel.text = self.currentWeather!.condition.description
            self.currentConditionImageLabel.text = setImageEmoji(self.currentWeather!.condition)
            self.dayCollectionView.reloadData()
            self.forecastTableView.reloadData()
        }
    }
    
}

class WeatherViewModel {
    
    weak var delegate: WeatherViewModelDelegate?
    
    func fetchCurrentTempLabel () -> String {
        guard let temp = delegate?.currentWeather?.temperature else {fatalError()}
        
            if let unit = UserDefaults.standard.value(forKey: "unit") as? String, let savedUnit = Temp(rawValue: unit), savedUnit == .fahrenheit {
                let tempF = temp.converted(to: .fahrenheit).value
                return String(format: "%.1f", tempF)+" °F"
            } else {
                let tempC = temp.value
                return String(format: "%.1f", tempC)+" °C"
            }
        
    }
  
    func updateWeather (_ location:CLLocation) {
        Task {
            let weather = await Networking.shared.weatherKitFetchWeather(location)
            let forecast = await Networking.shared.fetchForcastFromAPI(location)
            guard let weather = weather else {fatalError()}

            
//            printWeatherData(forecast)
            

            
            DispatchQueue.main.async {
                var rainArray = self.makeRainArray(forecast)

    //            rainArray = rainArray.filter{$0.PrecipitationType == .Rain}

                rainArray = self.groupTogether(rainArray)
                
                self.delegate?.currentWeather = weather.0
                self.delegate?.dayWeatherArray = weather.1.forecast
                self.delegate?.rainForecast = rainArray
                self.delegate?.updateUI()
            }
        }
    }
    
    private func printWeatherData (_ weatherData:WeatherData) {
        weatherData.data.timelines.forEach { t in
            print("timestep: "+t.timestep)
            print("startTime: "+t.startTime)
            print("endTime: "+t.endTime)
            t.intervals.forEach { interval in
                print("interval.startTime "+interval.startTime)
                print("interval.temperature "+interval.values.temperature.description)
                print("interval.precipitationType "+interval.values.precipitationType.description)
                print("interval.weatherCode "+interval.values.weatherCode.description)
            }
            
        }
    }
    
    
    
    private func makeRainArray (_ weatherData:WeatherData) -> [Rain] {
        
        let intervals = weatherData.data.timelines[0].intervals
        var rainArray = [Rain]()
        guard let timestep = Double(weatherData.data.timelines[0].timestep.filter{$0.isNumber}) else {fatalError("could not create timeline")}
        
        for interval in intervals {
            
            let start = formatDateFromTimeline(interval.startTime)
            let end = formatDateFromTimeline(interval.startTime).addingTimeInterval(60*timestep)
            let Precipitation = parsePrecipitationType(interval.values.precipitationType)
            let temperature = interval.values.temperature
            let weatherCode = interval.values.weatherCode
            let description = parseWeatherCode(weatherCode)
            
            rainArray.append(Rain(start: start, end: end, PrecipitationType: Precipitation, temperature: .init(value: temperature, unit: .celsius), isSelected: false,description: description))
        }
        
        return rainArray
        

    }
    
    private func groupTogether (_ rainArray: [Rain]) -> [Rain] {
            guard rainArray.count > 2 else {return rainArray}
            
            
    //        let debugArray = rainArray.map { rain in
    //            let formatter = DateFormatter()
    //            formatter.dateFormat = "hh:mm a"
    //            let start = formatter.string(from: rain.start)
    //            let end = formatter.string(from: rain.end)
    //            return (s:start,e:end)
    //        }
    //        print(debugArray)
    //        print("totalCount: \(rainArray.count), last index is \(rainArray.count-1)")
            
            var groupedRainArray = [Rain]()

            var start = rainArray.first!.start

            for i in 0..<rainArray.count-1 {
                
                let isTrailing = rainArray[i].end == rainArray[i+1].start
                let isSameWeather = rainArray[i].description == rainArray[i+1].description
                let isLast = i == rainArray.count-2
                
                var end : Date?
                
                if !isTrailing && !isSameWeather || isLast  {
                    
                    end = rainArray[i].end
                    
                    //save
                    groupedRainArray.append(Rain(start: start,
                                                 end: end!,
                                                 PrecipitationType: rainArray[i].PrecipitationType,
                                                 temperature: rainArray[i].temperature,
                                                 isSelected: rainArray[i].isSelected,
                                                 description: rainArray[i].description))
                    
                    start = rainArray[i+1].start
                }

            }
            
            return groupedRainArray
        }
    /*
     func groupTogether (_ forecasts:[Rain]) -> [Rain] {
        
        var groups = [Rain]()
        
        var start : Date?
        var end  : Date?
        var inGroup = false
        var updatedType : PrecipitationType = .Clear
        
        func save() {
            groups.append(Rain(start: start!, end: end!, PrecipitationType: .Rain, temperature: .init(value: 0, unit: .celsius), isSelected: false))
        }
        
        func clear () { start = nil
            end = nil
            updatedType = .Clear
            inGroup = false }
        
        let last = forecasts.count - 1
        var current = 0
        for forecast in forecasts {
            
            let currentType = forecast.PrecipitationType
            
            let isPrecipitation = currentType != .Clear
            
            let isSamePrecipitation = isPrecipitation && currentType == updatedType; if isSamePrecipitation {print("isSamePrecipitation")}
            
            let isLast = current == last; if isLast {print("Last!")}
            
            if isPrecipitation && !inGroup {
                print("isPrecipitation && !inGroup")
                updatedType = currentType
                start = forecast.start
                end = forecast.end
                inGroup = true
                
            } else if isLast && inGroup {
                save()
                clear()
            } else if isSamePrecipitation && inGroup {
                print("isSamePrecipitation && inGroup")
                end = forecast.end
                
            } else if !isSamePrecipitation && inGroup {
                print("!isSamePrecipitation && inGroup")
                save()
                clear()
            } else if !isPrecipitation && !inGroup {
                print("!isPrecipitation && !inGroup")
                //do nothing
            } else {
                fatalError()
            }
            current += 1
        }
        return groups
    }
     */
    
    
    

    
    
    

  //old function in case new one wont work
    /*
    private func updateRainForcast (_ requests:[UNNotificationRequest]) {

        guard rainForecast != nil else {fatalError()}

        print(rainForecast!.count)
        print(requests.count)

        for forcast in rainForecast! {
            for request in requests {

                if forcast.start.description == request.identifier {
                    let forcastIndex = rainForecast!.firstIndex(where: { $0.start == forcast.start })
                    rainForecast![forcastIndex!].isSelected = true

                }
            }
        }
    }
*/

    
    func formattedCellDate (start:Date, end:Date) -> String {
        let DF = DateFormatter()
        DF.dateFormat = "HH:mm a"
        
        let startsToday = start.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted)
        let endsToday = end.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted)
        
        let startTime = DF.string(from: start)
        let endTime = DF.string(from: end)
        
        if startsToday && endsToday {
            return "at \(startTime) until \(endTime)"
        } else if startsToday && !endsToday {
            return "at \(startTime) until Tomorrow at \(endTime)"
        } else if !startsToday && !endsToday {
            return "Tomorrow at \(startTime) until \(endTime)"
        } else {
            fatalError()
        }
        
    }
        
    private func formatDateFromTimeline (_ timeline:String) -> Date {
        let DF = DateFormatter()
        DF.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDate = DF.date(from: timeline)
        return formattedDate!
    }


    func redirectAlertController () -> UIAlertController {
        let alert = UIAlertController(title: "Cant get your location..", message: "redirecting to setting so you can change it to 'Always'", preferredStyle: .alert)
        let action = UIAlertAction(title: "Oh shit, ok.", style: .default) { _ in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alert.addAction(action)
        return alert
    }
    
    func showNoRainLabel (_ superView:UIView) -> UILabel {
        
        let label = UILabel(frame: superView.frame)
        
        label.text = "Not gonna rain in the next 6 hours"
        label.textAlignment = .center

        label.center.y = superView.frame.origin.y + 200
        label.layer.shadowOpacity = 0.6
        label.layer.shadowRadius = 6
        label.layer.shadowOffset = .init(width: 2, height: 2)
        
        return label
    }
    
    init(delegate: WeatherViewModelDelegate? = nil) {
        self.delegate = delegate
    }
}
