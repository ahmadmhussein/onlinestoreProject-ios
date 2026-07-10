//
//  PaymentMethodsViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 09/07/2026.
//

import UIKit

class PaymentMethodsViewController: UIViewController {

    @IBOutlet weak var cashCardView: UIView!
    @IBOutlet weak var creditCardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        cashCardView.layer.cornerRadius = 12
        cashCardView.layer.masksToBounds = true
        
        creditCardView.layer.cornerRadius = 12
        creditCardView.layer.masksToBounds = true
    }
    
   
}
