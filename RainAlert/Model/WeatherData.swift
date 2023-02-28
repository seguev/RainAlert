//
//  WeatherData.swift
//  RainAlert
//
//  Created by segev perets on 26/01/2023.
//

import Foundation

class WeatherData: Decodable {
    var data: Weather
}

class Weather: Decodable {
    var timelines: [Timeline]
}

class Timeline: Decodable {
    var timestep: String
    var startTime: String
    var endTime: String
    var intervals: [Interval]
}

class Interval: Decodable {
    var startTime: String
    var values: Values
}

class Values: Decodable {
    var weatherCode: Int
    var precipitationType: Int
    var temperature: Double
}



