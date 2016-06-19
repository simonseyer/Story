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
    
    var changeCommand: ((Day) -> Void)?
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
            dayView.imageView.isUserInteractionEnabled = true
            imagePreviewDelegate = DayImagePreviewDelegate(dayViewController: self)
            registerForPreviewing(with: imagePreviewDelegate!, sourceView: dayView.imageView)

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
            dayView?.setEditing(isEditing, animated: false)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
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
        dayView?.livePhotoView.startPlayback(with: .hint)
    }
}


// Keyboard handling
extension DayViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isVisible = true
        updateDayView()

        NotificationCenter.default().addObserver(self, selector: #selector(updateKeyboardLayoutGuide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(updateKeyboardLayoutGuide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func updateKeyboardLayoutGuide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue()
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve) | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        
        let keyboarConstant = -(view.bounds.maxY - convertedKeyboardEndFrame.minY)
        dayView?.keyboardConstraint?.constant = keyboarConstant - 8 // TODO: move to view
        dayView?.keyboardMode = keyboarConstant < 0
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {[unowned self] in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

// Image handling
extension DayViewController : ImagePickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func configureImagePicker() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            dayView?.imagePickerView.addSource(.Camera)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            dayView?.imagePickerView.addSource(.PhotoLibrary)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            dayView?.imagePickerView.addSource(.SavedPhotos)
        }
        
        dayView?.imagePickerView.delegate = self
    }
    
    func didSelectSource(_ source: ImagePickerSource) {
        let imagePicker = UIImagePickerController()
        
        switch source {
        case .Camera:
            imagePicker.sourceType = .camera
        case .PhotoLibrary:
            imagePicker.sourceType = .photoLibrary
        case .SavedPhotos:
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeLivePhoto as String]
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismiss(animated: true, completion: nil)
        dayView?.setProcessing(true)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let livePhoto = info[UIImagePickerControllerLivePhoto] as! PHLivePhoto?
        let completionBlock: (Image?) -> Void = { [weak self] image in
            if let this = self {
                this.day.image = image
                this.changeCommand?(this.day)
                this.dayView?.setProcessing(false)
            }
        }
        
        if let assetRef = info[UIImagePickerControllerReferenceURL] as? URL {
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let dayViewController = dayViewController {
            if viewControllerToCommit.isKind(of:LivePhotoViewController.self) {
                dayViewController.show(viewControllerToCommit, sender: nil)
            } else if let imageViewController = viewControllerToCommit as? ImageViewController  {
                dayViewController.show(ImageViewController(image: imageViewController.fullSizeImage ?? imageViewController.imageView.image, fill: false), sender: nil)
            }
        }
    }

}
