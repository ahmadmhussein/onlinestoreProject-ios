//
//  ChangePasswordViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 10/07/2026.
//

import UIKit
import FirebaseAuth
class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func updatePasswordTapped(_ sender: UIButton) {
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty,
                      let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
                    showAlert(title: "تنبيه", message: "الرجاء إدخال كلمة المرور الحالية والجديدة.")
                    return
                }
                
                guard newPassword.count >= 6 else {
                    showAlert(title: "تنبيه", message: "كلمة المرور الجديدة يجب أن تتكون من 6 أحرف على الأقل.")
                    return
                }
                
                guard let user = Auth.auth().currentUser, let email = user.email else { return }
                
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                
                user.reauthenticate(with: credential) { [weak self] authResult, error in
                    if let error = error {
                        self?.showAlert(title: "خطأ", message: "كلمة المرور الحالية غير صحيحة.")
                        return
                    }
                    
                    user.updatePassword(to: newPassword) { error in
                        if let error = error {
                            self?.showAlert(title: "خطأ", message: "حدث خطأ أثناء التحديث: \(error.localizedDescription)")
                        } else {
                            self?.showAlert(title: "نجاح", message: "تم تحديث كلمة المرور بنجاح!") {
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
        
    }
    
    
    
    
    
    
    
    
    
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "حسناً", style: .default) { _ in
                completion?()
            }
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    

}
