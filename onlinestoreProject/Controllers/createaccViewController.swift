//
//  ceateaccViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 06/07/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class createaccViewController: UIViewController {

    @IBOutlet weak var Namelabel: UITextField!
    @IBOutlet weak var EmailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToLoginpageTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAccTapped(_ sender: UIButton) {
        guard let name = Namelabel.text, !name.isEmpty,
              let email = EmailLabel.text, !email.isEmpty,
              let password = passwordLabel.text, !password.isEmpty else {
            showErrorAlert(message: "الرجاء تعبئة جميع الحقول")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "uid": uid,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    self?.showErrorAlert(message: error.localizedDescription)
                } else {
                    self?.navigateToHomeScreen()
                }
            }
        }
    }
    
    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // التغيير هنا: قمنا باستدعاء MainTabBarController بدلاً من HomeViewController
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            // جعل الـ Tab Bar هو الجذر الأساسي للتطبيق
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "تنبيه", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "موافق", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
