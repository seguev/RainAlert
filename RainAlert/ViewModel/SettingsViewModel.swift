//
//  SettingsViewModel.swift
//  RainAlert
//
//  Created by segev perets on 27/02/2023.
//

import UIKit

protocol SettingsViewModelDelegate : SettingsTableViewController {
    var settings : [Setting] {get set}
    
}

enum Setting : String, CaseIterable {
    case temperature = "temperature"
    
}
enum Temp : String, CaseIterable  {
    case fahrenheit = "fahrenheit"
    case celcius = "celcius"
}

class SettingsViewModel {
    weak var delegate : SettingsViewModelDelegate?
    var sliderLabel : UILabel!


    func addCellSlider (_ cell:UITableViewCell) -> UISlider {
        let slider = UISlider(frame: cell.frame)
        slider.bounds = .init(x: 0, y: 0, width: 100, height: cell.bounds.height*0.9)
        slider.center.y = cell.frame.height/2
        slider.center.x = cell.frame.width - (slider.frame.width/2) - 20
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(sliderDidSlide(_:)), for: .valueChanged)
        slider.isUserInteractionEnabled = true
    
        addSliderLabel(cell, slider: slider)
        
        return slider
    }
    
    
    @objc private func sliderDidSlide (_ sender:UISlider) {
        let value = Int(sender.value)
        sliderLabel.text = String(value)
        
    }
    
    
    private func addSliderLabel (_ cell:UITableViewCell, slider:UISlider)  {
        sliderLabel = UILabel(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 30, height: 30))
            
        
        sliderLabel.center = .init(x: cell.frame.width/2, y: cell.frame.height/2)
        sliderLabel.text = String(Int(slider.value))
        
        cell.addSubview(sliderLabel)
        
        
    }
    
    func addCellSegmentedControl (_ cell:UITableViewCell) -> UISegmentedControl {
        let items = Temp.allCases.map{$0.rawValue}
        
        let seg = UISegmentedControl(items: items)
        
        seg.center.y = cell.frame.height/2
        seg.center.x = cell.frame.width - (seg.frame.width/2) - 20
        if let existingUnit = UserDefaults.standard.value(forKey: "unit") as? String {
            let chosenTemp = Temp(rawValue: existingUnit)
            let index = Temp.allCases.firstIndex(of: chosenTemp!)!
            seg.selectedSegmentIndex = index
        } else {
            seg.selectedSegmentIndex = 0
        }
        
//        seg.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        return seg
    }
    
/*
    @objc private func segmentedControlDidChange (_ sender:UISegmentedControl) {
    
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "hah??"

    }
*/
    
}


