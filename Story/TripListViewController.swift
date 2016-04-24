//
//  TripListViewController.swift
//  Story
//
//  Created by COBI on 24.04.16.
//
//

import UIKit

class TripListViewController: UITableViewController {

    let cellReuseIdentifier = "trippCell"
    let model: [Trip]
    
    let rowHeight = CGFloat(120)
    
    var selectionCommand: (Trip -> Void)?
    
    init(model: [Trip]) {
        self.model = model
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        tableView.rowHeight = rowHeight
        tableView.registerClass(TripCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.separatorStyle = .None
        
        navigationItem.title = "Story"
    }
    
}

// TableView DataSource
extension TripListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as? TripCell {
            let trip = model[indexPath.row]
            
            cell.tripTitle = trip.name
            if let firstDay = trip.days.first {
                cell.tripImage = ImageStore.loadImage(firstDay.image)
            }
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectionCommand?(model[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}