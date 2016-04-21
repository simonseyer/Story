//
//  DayViewController.swift
//  Story
//
//  Created by COBI on 21.04.16.
//
//

import UIKit

class DayViewController: UIViewController {
    
    var dayView: DayView?
    
    let day: Day
    
    init(model: Day) {
        self.day = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        dayView = DayView()
        view = dayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayView?.imageView.image = ImageStore.loadImage(day.image)
        dayView?.textView.text = day.text
    }
    
}