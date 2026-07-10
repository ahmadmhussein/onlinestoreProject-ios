//
//  ChangeNameViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 10/07/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChangeNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateUserName(with name: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).updateData(["name": name]) { [weak self] (error) in
            if let error = error {
                self?.showAlert(title: "خطأ", message: "فشل التحديث: \(error.localizedDescription)")
            } else {
                self?.showAlert(title: "نجاح", message: "تم تحديث الاسم بنجاح!") {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else {
            showAlert(title: "تنبيه", message: "الرجاء إدخال الاسم الجديد.")
            return
        }
        
        updateUserName(with: newName)
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
