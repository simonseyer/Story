//
//  DayViewController.swift
//  Story
//
//  Created by COBI on 21.04.16.
//
//

import UIKit
import MobileCoreServices 

class DayViewController: UIViewController {
    
    var dayView: DayView?
    private var isVisible = false
    
    var day: Day {
        didSet {
            updateDayView()
        }
    }
    
    var changeCommand: (Day -> Void)?
    private var tapGestureRec: UITapGestureRecognizer?
    
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
        
        configureImagePicker()
        
        if let dayView = dayView {
            dayView.imageView.userInteractionEnabled = true
            registerForPreviewingWithDelegate(self, sourceView: dayView.imageView)
//            tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(didTouchImage))
//            dayView.imageView.addGestureRecognizer(tapGestureRec!)
        }
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
    
    func didTouchImage() {
        if let dayView = dayView {
            presentViewController(ImageViewController(image: dayView.imageView.image, fill: false, statusBarHidden: false), animated: true, completion: nil)
        }
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
        
        let keyboarConstant = -(CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame))
        dayView?.keyboardConstraint?.constant = keyboarConstant
        dayView?.keyboardMode = keyboarConstant < 0
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

// Text handling
extension DayViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(textView: UITextView) {
        day.text = textView.text
        changeCommand?(day)
    }

}

// Image handling
extension DayViewController : ImagePickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func configureImagePicker() {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            dayView?.imagePickerView.addSource(.Camera)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            dayView?.imagePickerView.addSource(.PhotoLibrary)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            dayView?.imagePickerView.addSource(.SavedPhotos)
        }
        
        dayView?.imagePickerView.delegate = self
    }
    
    func didSelectSource(source: ImagePickerSource) {
        let imagePicker = UIImagePickerController()
        
        switch source {
        case .Camera:
            imagePicker.sourceType = .Camera
        case .PhotoLibrary:
            imagePicker.sourceType = .PhotoLibrary
        case .SavedPhotos:
            imagePicker.sourceType = .SavedPhotosAlbum
        }
        
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        imagePicker.allowsEditing  = true
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        dayView?.setProcessing(true)
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let completionBlock: Image? -> Void = { [weak self] image in
            if let this = self {
                this.day.image = image
                this.changeCommand?(this.day)
                this.dayView?.setProcessing(false)
            }
        }
        
        if let assetRef = info[UIImagePickerControllerReferenceURL] as? NSURL {
            ImageStore.storeImage(image, assetRef: assetRef, completion: completionBlock)
        } else {
            ImageStore.storeImage(image, completion: completionBlock)
        }
       
    }
}

extension DayViewController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let dayView = dayView {
            previewingContext.sourceRect = dayView.imageView.frame
            return ImageViewController(image: dayView.imageView.image, fill: true, statusBarHidden: false)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let dayView = dayView {
            showViewController(ImageViewController(image: dayView.imageView.image, fill: false, statusBarHidden: false), sender: nil)
        }
    }

}
