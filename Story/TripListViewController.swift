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
    
    var selectionCommand: ((Trip) -> Void)?
    var editMode = false
    
    init(model: TripStore) {
        self.model = model
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        tableView.rowHeight = rowHeight
        tableView.register(TripCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        navigationItem.title = "Story Book"
        
        navigationItem.rightBarButtonItem = editButtonItem()
        tableView.allowsSelectionDuringEditing = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        model.observers.add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.observers.remove(self)
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditing
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let row = modelIndexForIndex((indexPath as NSIndexPath).row)
        return row < 0 ? .insert : .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            let cell = tableView.cellForRow(at: indexPath) as! TripCell
            if let text = cell.tripTitleTextView.text where !text.isEmpty {
                let trip = Trip(name: text)
                model.storeTrip(trip)
                cell.tripTitleTextView.text = ""
            }
        case .delete:
            model.removeTrip(model.trips[modelIndexForIndex((indexPath as NSIndexPath).row)])
        default:
            break
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if self.isEditing == editing {
            return
        }
        
        super.setEditing(editing, animated: animated)
        
        let insertCellIndexPath = IndexPath(row: 0, section: 0)
        if (editing) {
            editMode = true
            tableView.insertRows(at: [insertCellIndexPath], with: .automatic)
        } else {
            editMode = false
            tableView.deleteRows(at: [insertCellIndexPath], with: .automatic)
        }
    }
    
    func indexForModelIndex(_ modelIndex: Int) -> Int {
        return modelIndex + (isEditing ? 1 : 0)
    }
    
    func modelIndexForIndex(_ index: Int) -> Int {
        return index - (isEditing ? 1 : 0)
    }
}

// TableView DataSource
extension TripListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.trips.count + (editMode ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TripCell
        
        let row = modelIndexForIndex((indexPath as NSIndexPath).row)
        
        if row < 0 {
            Background.execute({[unowned self] in return self.randomDefaultImage() }) {[weak cell] image in
                if cell?.trip == nil {
                    cell?.tripImage = image
                }
            }
            cell.tripImage = nil
            cell.tripTitle = ""
            cell.doneCommand = {[weak self] in
                if let text = cell.tripTitleTextView.text where !text.isEmpty {
                    let trip = Trip(name: text)
                    self?.model.storeTrip(trip)
                    cell.tripTitleTextView.text = ""
                } else {
                    self?.setEditing(false, animated: true)
                }
            }
        } else {
            let trip = model.trips[row]
            
            cell.trip = trip
            cell.tripTitle = trip.name
            if let firstDay = model.dayStoreForTrip(trip).days.first, image = firstDay.image {
                ImageStore.loadImage(image, thumbnail: true) {[weak cell] in
                    if cell?.trip == trip {
                        cell?.tripImage = $0
                    }
                }
            } else {
                Background.execute({[unowned self] in return self.randomDefaultImage() }) {[weak cell] image in
                    if cell?.trip == trip {
                        cell?.tripImage = image
                    }
                }
            }
            
            cell.doneCommand = {[weak self] trip in
                self?.setEditing(false, animated: true)
            }
        }
        
        cell.changeCommand = {[weak self] trip in
            self?.model.storeTrip(trip)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = modelIndexForIndex((indexPath as NSIndexPath).row)
        if row >= 0 && row < model.trips.count {
            selectionCommand?(model.trips[row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func randomDefaultImage() -> UIImage? {
        let number = Int(arc4random_uniform(5) + 1)
        return UIImage(named: "nw\(number).JPG")
    }
}

extension TripListViewController : TripStoreObserver {
    
    func didInsertTrip(_ trip: Trip, atIndex index: Int) {
        tableView.insertRows(at: [IndexPath(row: indexForModelIndex(index), section: 0)], with: .automatic)
        if isEditing {
            self.selectionCommand?(trip)
            setEditing(false, animated: false)
        }
    }
    
    func didUpdateTrip(_ trip: Trip, fromIndex: Int, toIndex: Int) {
        DispatchQueue.main.async {[unowned self] in
            if fromIndex != toIndex {
                self.tableView.moveRow(at: IndexPath(row: self.indexForModelIndex(fromIndex), section: 0), to: IndexPath(row: self.indexForModelIndex(toIndex), section: 0))
            } else {
                let cell = self.tableView.cellForRow(at: IndexPath(row: self.indexForModelIndex(fromIndex), section: 0)) as! TripCell
                cell.tripTitle = trip.name
            }
        }
    }
    
    func didRemoveTrip(_ trip: Trip, fromIndex index: Int) {
        tableView.deleteRows(at: [IndexPath(row: indexForModelIndex(index), section: 0)], with: .automatic)
    }
}

