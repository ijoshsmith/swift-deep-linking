//
//  DemoTabBarController.swift
//  DeepLinking
//
//  Created by Joshua Smith on 5/18/17.
//  Copyright © 2017 iJoshSmith. All rights reserved.
//

import UIKit

class DemoTabBarController: UITabBarController {
    
    @IBAction func handleOpenModal(_ sender: Any) {
        let rabbitImage = UIImage(named: "rabbit")!
        showPhoto(image: rabbitImage, animated: true)
    }
    
    func showPhoto(image: UIImage, animated: Bool) {
        if let modal = storyboard?.instantiateViewController(withIdentifier: "modal") as? DemoModalViewController {
            modal.configure(with: image)
            present(modal, animated: animated, completion: nil)
        }
    }
    
}
