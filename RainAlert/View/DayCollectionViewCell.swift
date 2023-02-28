//
//  currentCollectionViewCell.swift
//  RainAlert
//
//  Created by segev perets on 25/12/2022.
//

import UIKit
import WeatherKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var conditionImageLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    func config(_ dayForcast:DayWeather) {
        
        layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        layer.masksToBounds = false
        contentView.layer.masksToBounds = true
        addShadow()
        UISetup(dayForcast)
    }
    
    private func UISetup (_ dayForcast:DayWeather) {
        
        let highTemperature = dayForcast.highTemperature
        let lowTemperature = dayForcast.lowTemperature
        
        if let unit = UserDefaults.standard.value(forKey: "unit") as? String, let savedUnit = Temp(rawValue: unit), savedUnit == .fahrenheit {
            let high = String(format: "%.1f", highTemperature.converted(to: .fahrenheit).value)
            let low = String(format: "%.1f", lowTemperature.converted(to: .fahrenheit).value)
            tempLabel.text = "\(high)°F - \(low)°F"
            
        } else {
            let high = String(format: "%.1f", highTemperature.value)
            let low = String(format: "%.1f", lowTemperature.value)
            tempLabel.text = "\(high)°C - \(low)°C"
        }
        
        contentView.backgroundColor = setColor(with: dayForcast.precipitation)
        
        timeLabel.text = formatDate(dayForcast.date)
        conditionImageLabel.text = setImageEmoji(dayForcast.condition)
        conditionLabel.text = dayForcast.condition.description
    }
    
    
    
    private func setColor (with precipitation:Precipitation) -> UIColor {
        switch precipitation {
            
        case .none:
            return #colorLiteral(red: 0.80400002, green: 0.8740000129, blue: 0.9440000057, alpha: 1)
        case .hail:
            return #colorLiteral(red: 0.4519999921, green: 0.72299999, blue: 0.949000001, alpha: 1)
        case .mixed:
            return #colorLiteral(red: 0.6439999938, green: 0.8330000043, blue: 0.9610000253, alpha: 1)
        case .rain:
            return #colorLiteral(red: 0.6439999938, green: 0.8330000043, blue: 0.9610000253, alpha: 1)
        case .sleet:
            return #colorLiteral(red: 0.4519999921, green: 0.72299999, blue: 0.949000001, alpha: 1)
        case .snow:
            return #colorLiteral(red: 0.4519999921, green: 0.72299999, blue: 0.949000001, alpha: 1)
        @unknown default:
            return #colorLiteral(red: 0.80400002, green: 0.8740000129, blue: 0.9440000057, alpha: 1)
        }
    }
    
    private func formatDate (_ date:Date) -> String {
        let isToday = date.formatted(date: .numeric, time: .omitted) == Date().formatted(date: .numeric, time: .omitted)
        if isToday {return "Today"}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
        
    }
    
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 5, height: 4)
        layer.shadowRadius = 7
    }
    
    
    
}

func setImageEmoji (_ condition:WeatherCondition) -> String {
    switch condition {
        
    case .blizzard, .snow, .heavySnow, .blowingSnow:
        return "🌨️"
    case .blowingDust, .windy:
        return "🌬️"
    case .breezy:
        return "🌤️"
    case .clear, .hot:
        return "☀️"
    case .cloudy:
        return "🌥️"
    case .drizzle, .sleet,.wintryMix:
        return "🌦️"
    case .flurries:
        return "⛈️"
    case .foggy, .smoky:
        return "🌫️"
    case .freezingDrizzle:
        return "🌨️"
    case .freezingRain:
        return "🌨️"
    case .frigid:
        return "❄️"
    case .hail:
        return "🌨️"
    case .haze:
        return "🌫️"
    case .heavyRain, .rain:
        return "🌧️"
    case .hurricane:
        return "🌪️"
    case .mostlyClear:
        return "🌥️"
    case .mostlyCloudy:
        return "🌥️"
    case .partlyCloudy:
        return "🌤️"
    case .scatteredThunderstorms, .thunderstorms, .isolatedThunderstorms, .strongStorms, .tropicalStorm:
        return "⛈️"
    case .sunFlurries:
        return "🌦️"
    case .sunShowers:
        return "🌦️"
    @unknown default:
        return "🌤️"
    }
}
