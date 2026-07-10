//
//  loginPageViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 05/07/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class loginPageViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("user signed in")
            self.navigateToHomeScreen()
        }
        
    }
    private func navigateToHomeScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else { return }
                
                // جعل الـ Tab Bar هو الجذر الأساسي للتطبيق
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
            }
        } // <-- هذا القوس يغلق دالة الانتقال

        // دالة عرض التنبيهات (الآن أصبحت بشكل صحيح داخل الكلاس)
        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "تنبيه", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "موافق", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

    } // <-- هذا هو القوس الوحيد والأخير الذي يجب أن يغلق الكلاس بأكمله
    

