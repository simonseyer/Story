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
    let model: TripStore
    
    let rowHeight = CGFloat(140)
    
    var selectionCommand: (Trip -> Void)?
    var defaultImage: UIImage?
    var editMode = false
    
    init(model: TripStore) {
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
        tableView.separatorColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        navigationItem.title = "Story Book"
        
        navigationItem.rightBarButtonItem = editButtonItem()
        tableView.allowsSelectionDuringEditing = false

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        model.observers.addObject(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        model.observers.removeObject(self)
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let row = modelIndexForIndex(indexPath.row)
        return row < 0 ? .Insert : .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Insert:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TripCell
            if let text = cell.tripTitleTextView.text where !text.isEmpty {
                let trip = Trip(name: text)
                model.storeTrip(trip)
                cell.tripTitleTextView.text = ""
            }
        case .Delete:
            model.removeTrip(model.trips[modelIndexForIndex(indexPath.row)])
        default:
            break
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let insertCellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if (editing) {
            editMode = true
            tableView.insertRowsAtIndexPaths([insertCellIndexPath], withRowAnimation: .Automatic)
        } else {
            editMode = false
            tableView.deleteRowsAtIndexPaths([insertCellIndexPath], withRowAnimation: .Automatic)
        }
    }
    
    func indexForModelIndex(modelIndex: Int) -> Int {
        return modelIndex + (editing ? 1 : 0)
    }
    
    func modelIndexForIndex(index: Int) -> Int {
        return index - (editing ? 1 : 0)
    }
}

// TableView DataSource
extension TripListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.trips.count + (editMode ? 1 : 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! TripCell
        
        let row = modelIndexForIndex(indexPath.row)
        
        if row < 0 {
            Background.execute({ return UIImage(named: "el_capitan.jpg") }) {[weak self, weak cell] image in
                self?.defaultImage = image
                if cell?.trip == nil {
                    cell?.tripImage = image
                }
            }
            cell.tripImage = defaultImage
            cell.tripTitle = ""
        } else {
            let trip = model.trips[row]
            
            cell.trip = trip
            cell.tripTitle = trip.name
            if let firstDay = model.dayStoreForTrip(trip).days.first, image = firstDay.image {
                ImageStore.loadImage(image) {[weak cell] in
                    if cell?.trip == trip {
                        cell?.tripImage = $0
                    }
                }
            } else {
                Background.execute({ return UIImage(named: "el_capitan.jpg") }) {[weak self, weak cell] image in
                    self?.defaultImage = image
                    if cell?.trip == trip {
                        cell?.tripImage = image
                    }
                }
            }
        }
        
        cell.changeCommand = {[weak self] trip in
            self?.model.storeTrip(trip)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = modelIndexForIndex(indexPath.row)
        if row >= 0 && row < model.trips.count {
            selectionCommand?(model.trips[row])
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension TripListViewController : TripStoreObserver {
    
    func didInsertTrip(trip: Trip, atIndex index: Int) {
        
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexForModelIndex(index), inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func didUpdateTrip(trip: Trip, fromIndex: Int, toIndex: Int) {
        if fromIndex != toIndex {
            tableView.moveRowAtIndexPath(NSIndexPath(forRow: indexForModelIndex(fromIndex), inSection: 0), toIndexPath: NSIndexPath(forRow: indexForModelIndex(toIndex), inSection: 0))
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexForModelIndex(toIndex), inSection: 0)], withRowAnimation: .Automatic)
        }
    }
    
    func didRemoveTrip(trip: Trip, fromIndex index: Int) {
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexForModelIndex(index), inSection: 0)], withRowAnimation: .Automatic)
    }
}

