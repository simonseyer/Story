//
//  DayViewController.swift
//  Story
//
//  Created by COBI on 21.04.16.
//
//

import UIKit
import MobileCoreServices 
import Photos

class DayViewController: UIViewController {
    
    var dayView: DayView?
    private var imagePreviewDelegate: DayImagePreviewDelegate?
    private var isVisible = false
    
    var cachedImage: UIImage?
    var day: Day {
        didSet {
            cacheImage()
            updateDayView()
        }
    }
    
    private func cacheImage() {
        if let image = day.image {
            ImageStore.loadImage(image, thumbnail: true) {[weak self] image in
                if let this = self {
                    this.cachedImage = image
                    if this.isVisible {
                        this.dayView?.image = image
                    }
                }
            }
        }
    }
    
    var changeCommand: (Day -> Void)?
    private var tapGestureRec: UITapGestureRecognizer?
    
    init(model: Day) {
        self.day = model
        super.init(nibName: nil, bundle: nil)
        cacheImage()
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
        
        dayView?.didEndEditTextCommand = {[weak self] text in
            if self?.day.text != nil || (text != nil && !text!.isEmpty) {
                self?.day.text = text
                self?.changeCommand?((self?.day)!)
            }
        }
        
        configureImagePicker()
        
        if let dayView = dayView {
            dayView.imageView.userInteractionEnabled = true
            imagePreviewDelegate = DayImagePreviewDelegate(dayViewController: self)
            registerForPreviewingWithDelegate(imagePreviewDelegate!, sourceView: dayView.imageView)

//            tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(didTouchImage))
//            dayView.imageView.addGestureRecognizer(tapGestureRec!)
        }
    }
    
    private func updateDayView() {
        if isVisible {
            dayView?.imageView.image = cachedImage
            if let livePhoto = day.image?.livePhoto {
                self.dayView?.livePhoto = livePhoto
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
        if let image = day.image {
            ImageStore.loadImage(image, thumbnail: false) {[weak self] image in
                self?.navigationController?.pushViewController(ImageViewController(image: image, fill: false), animated: true)
            }
        }
    }
    
    func preview() {
        dayView?.livePhotoView.startPlaybackWithStyle(.Hint)
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
        dayView?.keyboardConstraint?.constant = keyboarConstant - 8 // TODO: move to view
        dayView?.keyboardMode = keyboarConstant < 0
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationCurve, animations: {[unowned self] in
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        dayView?.setProcessing(true)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let livePhoto = info[UIImagePickerControllerLivePhoto] as! PHLivePhoto?
        let completionBlock: Image? -> Void = { [weak self] image in
            if let this = self {
                this.day.image = image
                this.changeCommand?(this.day)
                this.dayView?.setProcessing(false)
            }
        }
        
        if let assetRef = info[UIImagePickerControllerReferenceURL] as? NSURL {
            ImageStore.storeImage(image, assetRef: assetRef, livePhoto: livePhoto, completion: completionBlock)
        } else {
            ImageStore.storeImage(image, completion: completionBlock)
        }
       
    }
}

@objc class DayImagePreviewDelegate : NSObject, UIViewControllerPreviewingDelegate {
    
    weak var dayViewController: DayViewController?
    private weak var currentImageViewController: ImageViewController?
    
    init(dayViewController: DayViewController) {
        self.dayViewController = dayViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let dayViewController = dayViewController, dayView = dayViewController.dayView {
            previewingContext.sourceRect = dayView.imageView.frame
            
            if let livePhoto = dayViewController.day.image?.livePhoto {
                return LivePhotoViewController(image: dayView.imageView.image, photo: livePhoto)
            } else {
                let viewController = ImageViewController(image: dayView.imageView.image, fill: true)
                currentImageViewController = viewController
                if let image = dayViewController.day.image {
                    ImageStore.loadImage(image, thumbnail: false) {[weak self] image in
                        self?.currentImageViewController?.fullSizeImage = image
                    }
                }
                return viewController
            }
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let dayViewController = dayViewController {
            if viewControllerToCommit.isKindOfClass(LivePhotoViewController) {
                dayViewController.showViewController(viewControllerToCommit, sender: nil)
            } else if let imageViewController = viewControllerToCommit as? ImageViewController  {
                dayViewController.showViewController(ImageViewController(image: imageViewController.fullSizeImage ?? imageViewController.imageView.image, fill: false), sender: nil)
            }
        }
    }

}
