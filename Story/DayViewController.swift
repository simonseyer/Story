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
    private var isVisible = false
    
    var day: Day {
        didSet {
            updateDayView()
        }
    }
    
    var changeCommand: (Day -> Void)?
    
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
        
        dayView?.topLayoutGuide = topLayoutGuide
        dayView?.editTextView.delegate = self
    }
    
    private func updateDayView() {
        if isVisible {
            if let image = day.image {
                ImageStore.loadImage(image) {[weak self] image in
                    self?.dayView?.image = image
                }
            }
            dayView?.text = day.text
            dayView?.setEditing(editing, animated: false)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        dayView?.setEditing(editing, animated: animated)
    }
    
}


// Keyboard handling
extension DayViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        isVisible = true
        updateDayView()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateKeyboardLayoutGuide), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateKeyboardLayoutGuide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func updateKeyboardLayoutGuide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve) | UIViewAnimationOptions.BeginFromCurrentState.rawValue)
        
        dayView?.keyboardConstraint?.constant = -(CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame))
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension DayViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(textView: UITextView) {
        day.text = textView.text
        changeCommand?(day)
    }
    
}
