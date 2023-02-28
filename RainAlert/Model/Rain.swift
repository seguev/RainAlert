//
//  Rain.swift
//  RainAlert
//
//  Created by segev perets on 26/02/2023.
//

import Foundation

struct Rain : Equatable, Hashable {
    static func == (lhs: Rain, rhs: Rain) -> Bool {
        if lhs.start == rhs.start && lhs.end == rhs.end && lhs.PrecipitationType == rhs.PrecipitationType {return true}
        else {return false}
    }
    
    var start : Date
    var end : Date
    var PrecipitationType : PrecipitationType = .Rain
    var temperature : Measurement<UnitTemperature>
    var isSelected : Bool = false
    var description : String
}
