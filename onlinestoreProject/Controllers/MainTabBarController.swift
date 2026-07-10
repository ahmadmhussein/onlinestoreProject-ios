//
//  MainTabBarController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 06/07/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.selectedIndex = 3
        setupCartBadgeListener()
    }
    
    private func setupCartBadgeListener() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("cart").addSnapshotListener { [weak self] (querySnapshot, error) in
            
            let cartCount = querySnapshot?.documents.count ?? 0
            
            DispatchQueue.main.async {
                
                if let cartTab = self?.tabBar.items?[1] {
                    
                    if cartCount > 0 {
                        cartTab.badgeValue = "\(cartCount)"
                    } else {
                        cartTab.badgeValue = nil 
                    }
                }
            }
        }
    }
}
