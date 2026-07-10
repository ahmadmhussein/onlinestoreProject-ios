//
//  ProfileViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 09/07/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchingUserData()
    }
    
    private func FetchingUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        DispatchQueue.main.async {
            self.EmailLabel.text = user.email
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let name = data?["name"] as? String {
                    DispatchQueue.main.async {
                        self?.NameLabel.text = name
                    }
                }
            }
        }
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginPageViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        } catch let error {
            print("خطأ في تسجيل الخروج: \(error.localizedDescription)")
        }
    }
}
