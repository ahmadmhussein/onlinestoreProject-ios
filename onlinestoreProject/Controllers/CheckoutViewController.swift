//
//  CheckoutViewController.swift
//  onlinestoreProject
//
//  Created by Ahmad on 10/07/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class CheckoutViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    
    var orderTotal: Double = 0.0
    var orderedItems: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmOrderTapped(_ sender: UIButton) {
        guard let phone = phoneTextField.text, !phone.isEmpty,
              let city = cityTextField.text, !city.isEmpty,
              let street = streetTextField.text, !street.isEmpty else {
            showAlert(title: "تنبيه", message: "الرجاء تعبئة جميع حقول التوصيل.")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDate = formatter.string(from: Date())
        
        var itemsArray: [[String: Any]] = []
        for item in orderedItems {
            itemsArray.append([
                "id": item.id,
                "name": item.name,
                "price": item.price
            ])
        }
        
        let orderData: [String: Any] = [
            "phone": phone,
            "city": city,
            "street": street,
            "date": currentDate,
            "total": orderTotal,
            "status": "قيد المعالجة",
            "items": itemsArray
        ]
        
        db.collection("users").document(uid).collection("orders").addDocument(data: orderData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "خطأ", message: "حدث خطأ: \(error.localizedDescription)")
            } else {
                self?.clearCart(for: uid)
                self?.showAlert(title: "تم بنجاح! 🎉", message: "تم تأكيد طلبك بنجاح وسيتواصل معك المندوب قريباً.") {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func clearCart(for uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("cart").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                document.reference.delete()
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
