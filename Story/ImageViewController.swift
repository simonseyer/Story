//
//  ImageViewController.swift
//  Story
//
//  Created by COBI on 28.04.16.
//
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    let statusBarAnimationDuration = 0.4
    
    var scrollView = UIScrollView()
    var imageView = UIImageView()
    
    var imageConstraintTop: NSLayoutConstraint!
    var imageConstraintRight: NSLayoutConstraint!
    var imageConstraintLeft: NSLayoutConstraint!
    var imageConstraintBottom: NSLayoutConstraint!
    
    var lastZoomScale: CGFloat = -1
    
    var statusBarHidden: Bool = false
    var fill: Bool
    
    init(image: UIImage?, fill: Bool) {
        self.fill = fill
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints  = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        LayoutUtils.fullInSuperview(scrollView, superView: self.view)
        
        imageConstraintLeft = imageView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor)
        imageConstraintLeft.active = true
        imageConstraintRight = imageView.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor)
        imageConstraintRight.active = true
        imageConstraintTop = imageView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor)
        imageConstraintTop.active = true
        imageConstraintBottom = imageView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor)
        imageConstraintBottom.active = true
        
        view.backgroundColor = UIColor(hexValue: ViewConstants.backgroundColorCode)
        
        scrollView.delegate = self
        
        automaticallyAdjustsScrollViewInsets  = false
        
        updateConstraints()
        updateZoom()
        if !fill {
            updateConstraints()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationController(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        configureNavigationController(false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    
    // Update zoom scale and constraints with animation.
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ [weak self] _ in
            self?.updateZoom()
        }, completion: nil)
    }
    
    func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    
    // Zoom to show as much image as possible unless image is smaller than the scroll view
    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width,
                              scrollView.bounds.size.height / image.size.height)
            
            if minZoom > 1 { minZoom = 1 }
            
            scrollView.minimumZoomScale = minZoom
            
            var newZoomScale = minZoom
            if fill {
                newZoomScale = max(scrollView.bounds.size.width / image.size.width,
                                   scrollView.bounds.size.height / image.size.height)
            }
            
            // Force scrollViewDidZoom fire if zoom did not change
            if newZoomScale == lastZoomScale { newZoomScale += 0.000001 }
            
            scrollView.zoomScale = newZoomScale
            lastZoomScale = newZoomScale
            
            preferredContentSize = CGSize(width: image.size.width * newZoomScale, height: image.size.height * newZoomScale)
        }
    }
    
    // UIScrollViewDelegate
    // -----------------------
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // TODO: copy & paste
    
    private func configureNavigationController(configure: Bool) {
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
            statusBarHidden = navigationController.navigationBarHidden
            let delay = statusBarHidden ? 0 : 0.05
            let animations = {[unowned self] in
                self.setNeedsStatusBarAppearanceUpdate()
            }
            UIView.animateWithDuration(statusBarAnimationDuration, delay: delay, options: UIViewAnimationOptions(), animations: animations, completion: nil)
        }
    }
    
}
