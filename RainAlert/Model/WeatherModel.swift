//
//  WeatherModel.swift
//  RainAlert
//
//  Created by segev perets on 05/12/2022.
//

import UIKit
import WeatherKit
import CoreLocation

let errorNotification = NSNotification.Name(rawValue: UUID().uuidString)
let gotWeatherNotification = NSNotification.Name(rawValue: "gotWeather")
let saveNotification = Notification.Name("save")


    
    enum PrecipitationType : String {
        case Clear = "Clear"
        case Rain = "Rain"
        case Snow = "Snow"
        case FreezingRain = "FreezingRain"
        case Sleet = "Sleet"
    }
    
    enum PrecipitationImages {
        static let ClearImage = UIImage(systemName: "sun.max")!
        static let RainImage = UIImage(systemName: "cloud.rain")!
        static let SnowImage = UIImage(systemName: "cloud.snow")!
        static let FreezingRainImage = UIImage(systemName: "snowflake")!
        static let SleetImage = UIImage(systemName: "cloud.sleet")!
    }
    
    
    func parsePrecipitationType (_ n:Int) -> PrecipitationType {
        switch n {
        case 0:
            return .Clear
        case 1:
            return .Rain
        case 2:
            return .Snow
        case 3:
            return .FreezingRain
        case 4:
            return .Sleet
        default:
            return .Clear
        }
    }
    
    func pickCellImage (PrecipitationType:PrecipitationType) -> UIImage {
        switch PrecipitationType {
        case .Clear:
            return PrecipitationImages.ClearImage
        case .Rain:
            return PrecipitationImages.RainImage
        case .Snow:
            return PrecipitationImages.SnowImage
        case .FreezingRain:
            return PrecipitationImages.FreezingRainImage
        case .Sleet:
            return PrecipitationImages.SleetImage
        }
    }
    
    
     func parseWeatherCode (_ code:Int) -> String {
        switch code {
        case 0:
            return "Unknown"
        case 1000:
            return "Sunny"
        case 1100:
            return "Mostly Clear"
        case 1101:
            return "Partly Cloudy"
        case 1102:
            return "Mostly Cloudy"
        case 1001:
            return "Cloudy"
        case 2000:
            return "Fog"
        case 2100:
            return "Light Fog"
        case 4000:
            return "Drizzle"
        case 4001:
            return "Rain"
        case 4200:
            return "Light Rain"
        case 4201:
            return "Heavy Rain"
        case 5000:
            return "Snow"
        case 5001:
            return "Flurries"
        case 5100:
            return "Light Snow"
        case 5101:
            return "Heavy Snow"
        case 6000:
            return "Freezing Drizzle"
        case 6001:
            return "Freezing Rain"
        case 6200:
            return "Light Freezing Rain"
        case 6201:
            return "Heavy Freezing Rain"
        case 7000:
            return "Ice Pellets"
        case 7101:
            return "Heavy Ice Pellets"
        case 7102:
            return "Light Ice Pellets"
        case 8000:
            return "Thunderstorm"
        default :
            return ""
        }
    }
    
    
    
    

