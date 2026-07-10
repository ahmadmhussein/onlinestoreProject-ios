//
//  AccountSettingsViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 10/07/2026.
//

import UIKit

class AccountSettingsViewController: UIViewController {

    @IBOutlet weak var deleteAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    

    private func setupUI() {
        deleteAccountButton.layer.borderWidth = 1.5
        deleteAccountButton.layer.borderColor = UIColor.systemRed.cgColor
        deleteAccountButton.layer.cornerRadius = 12
        deleteAccountButton.setTitleColor(.systemRed, for: .normal)
        deleteAccountButton.tintColor = .systemRed
    }

}
