//
//  DemoModalViewController.swift
//  DeepLinking
//
//  Created by Joshua Smith on 5/23/17.
//  Copyright © 2017 iJoshSmith. All rights reserved.
//

import Foundation
import UIKit

class DemoModalViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var navBar: UINavigationBar!
    
    private var image: UIImage?
    
    func configure(with image: UIImage) {
        if isViewLoaded {
            imageView.image = image
        }
        else {
            self.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction func handleDone(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
