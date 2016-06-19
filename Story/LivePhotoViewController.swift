//
//  ImageViewController.swift
//  Story
//
//  Created by COBI on 28.04.16.
//
//

import PhotosUI

// TODO: join with ImageViewController

class LivePhotoViewController: UIViewController, UIScrollViewDelegate, PHLivePhotoViewDelegate {

    let statusBarAnimationDuration = 0.4
    
    var photoView = PHLivePhotoView()
    var imageView = UIImageView()
    
    var statusBarHidden: Bool = false
    
    var image: UIImage?
    var livePhoto: PHLivePhoto?
    
    init(image: UIImage?, photo: PHLivePhoto?) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        self.livePhoto = photo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints  = false
        
        view.addSubview(imageView)
        view.addSubview(photoView)
        
        LayoutUtils.fullInSuperview(photoView, superView: self.view)
        LayoutUtils.fullInSuperview(imageView, superView: self.view)

        view.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)

        
        automaticallyAdjustsScrollViewInsets  = false
        
        imageView.contentMode = .scaleAspectFit
        photoView.contentMode = .scaleAspectFit
        
        imageView.image = image
        photoView.livePhoto = livePhoto
        
        if let size = livePhoto?.size {
            preferredContentSize = size
        }
        
        photoView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.photoView.startPlayback(with: .full)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        photoView.startPlayback(with: .full)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        configureNavigationController(false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    
    // TODO: copy & paste
    
    private func configureNavigationController(_ configure: Bool) {
        if configure {
            Background.delay(0.5) {
                self.navigationController?.hidesBarsOnTap = configure
            }
        } else {
            navigationController?.hidesBarsOnTap = configure
        }

        if configure {
            navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: #selector(updateStatusBarVisibility))
            updateStatusBarVisibility()
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.barHideOnTapGestureRecognizer.removeTarget(self, action: #selector(updateStatusBarVisibility))
        }
    }
    
    func updateStatusBarVisibility() {
        if let navigationController = navigationController {
            statusBarHidden = navigationController.isNavigationBarHidden
            let delay = statusBarHidden ? 0 : 0.05
            let animations = {[unowned self] in
                self.setNeedsStatusBarAppearanceUpdate()
            }
            UIView.animate(withDuration: statusBarAnimationDuration, delay: delay, options: UIViewAnimationOptions(), animations: animations, completion: nil)
        }
    }
    
}
