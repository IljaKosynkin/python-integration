//
//  XKCDController.swift
//  python-integration
//
//  Created by Ilja Kosynkin on 19/08/2018.
//  Copyright © 2018 Syllogismobile. All rights reserved.
//

import UIKit

final class XKCDController: UIViewController {    
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var topGear: UIImageView!
    @IBOutlet weak var bottomGear: UIImageView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var comic: UIImageView!
    @IBOutlet weak var comicDescription: UILabel!
    
    @IBOutlet var spinnerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadButton.layer.cornerRadius = 6.0
        self.reloadButton.layer.borderColor = .mist
        self.reloadButton.layer.borderWidth = 1.0
        self.reloadButton.backgroundColor = .clear
        
        self.placeholderLabel.text = NSLocalizedString("loading_failed", comment: "")
        self.reloadButton.setTitle(NSLocalizedString("reload", comment: ""), for: .normal)
        
        self.placeholder.alpha = 1.0
        self.content.alpha = 0.0
        
        self.load()
    }
    
    private func load() {
        self.showLoading()
        AppDelegate.shared?.mediator.load(onSuccess: { [weak self] comic in self?.loaded(comic: comic) }, onError: { [weak self] error in self?.show(message: error) })
    }
    
    private func loaded(comic: AppWebcomic) {
        if let image: URL = comic.image {
            DispatchQueue.global().async { [weak self] in
                if let data: Data = try? Data(contentsOf: image) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.comicDescription.text = comic.desc
                            self?.comic.image = image
                            
                            self?.stopAnimations()
                            
                            UIView.animate(withDuration: 0.2, animations: {
                                self?.placeholder.alpha = 0.0
                                self?.content.alpha = 1.0
                            }, completion: { _ in
                                self?.content.isHidden = false
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func show(message: String) {
        DispatchQueue.main.async {
            self.showPlaceholder()
            print(message)
        }
    }
    
    private func stopAnimations() {
        self.topGear.layer.removeAllAnimations()
        self.bottomGear.layer.removeAllAnimations()
    }
    
    private func showLoading() {
        self.stopAnimations()
        
        self.spinnerBottomConstraint.isActive = true
        UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
        
        let topRotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        topRotationAnimation.fromValue = 0.0
        topRotationAnimation.toValue = -CGFloat.pi * 2.0
        topRotationAnimation.duration = 5.0
        topRotationAnimation.repeatCount = .infinity
        
        let bottomRotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        bottomRotationAnimation.fromValue = 0.0
        bottomRotationAnimation.toValue = CGFloat.pi * 2.0
        bottomRotationAnimation.duration = 5.0
        bottomRotationAnimation.repeatCount = .infinity
        
        self.topGear.layer.add(topRotationAnimation, forKey: nil)
        self.bottomGear.layer.add(bottomRotationAnimation, forKey: nil)
    }
    
    private func showPlaceholder() {
        self.stopAnimations()
        
        self.spinnerBottomConstraint.isActive = false
        UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
        
        let topRotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        topRotationAnimation.fromValue = 0.0
        topRotationAnimation.toValue = -0.3
        topRotationAnimation.duration = 0.5
        topRotationAnimation.repeatCount = .infinity
        
        let bottomRotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        bottomRotationAnimation.fromValue = 0.0
        bottomRotationAnimation.toValue = 0.3
        bottomRotationAnimation.duration = 0.5
        bottomRotationAnimation.repeatCount = .infinity
        
        self.topGear.layer.add(topRotationAnimation, forKey: nil)
        self.bottomGear.layer.add(bottomRotationAnimation, forKey: nil)
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        self.load()
    }
}

