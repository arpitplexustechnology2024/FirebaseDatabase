//
//  ViewController.swift
//  FirebaseDatabase
//
//  Created by Arpit iOS Dev. on 19/06/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSaveProduct: UIButton!
    @IBOutlet weak var btnShowProduct: UIButton!
    @IBOutlet var weightKg: [UIButton]!
    @IBOutlet weak var weightsDrop: UIButton!
    @IBOutlet weak var weightsStackView: UIStackView!
    @IBOutlet weak var weightsView: UIView!
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView()
        activityIndicator.isHidden = true
        activityIndicator.style = .large
        self.imageView.layer.cornerRadius = 20
        self.descriptionTextView.layer.cornerRadius = 5
        self.titleTextField.layer.cornerRadius = 5
        self.descriptionTextView.layer.borderWidth = 1
        self.titleTextField.layer.borderWidth = 1
        self.descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        self.titleTextField.layer.borderColor = UIColor.systemGray4.cgColor
        self.btnSaveProduct.layer.cornerRadius = 20
        self.btnShowProduct.layer.cornerRadius = 20
        self.weightsView.layer.borderWidth = 1
        self.weightsView.layer.borderColor = UIColor.systemGray4.cgColor
        self.weightsView.layer.cornerRadius = 5
        self.weightsStackView.layer.borderWidth = 1
        self.weightsStackView.layer.borderColor = UIColor.systemGray4.cgColor
        self.weightsStackView.layer.cornerRadius = 5
        
        weightKg.forEach { btn in
            btn.isHidden = true
            btn.alpha = 0
        }
    }
    
    @IBAction func btnDSaveProduct(_ sender: UIButton) {
        guard let name = titleTextField.text, !name.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              let weight = weightTextField.text, !weight.isEmpty,
              let image = selectedImage else {
            print("Missing data")
            return
        }
        
        // Upload image to Firebase Storage
        DispatchQueue.global().async {
            StorageManager.shared.uploadProductImage(image: image) { result in
                switch result {
                case .success(let imageURL):
                    // Save product data to Firestore
                    FirestoreManager.shared.saveProductData(name: name, description: description, weight: weight, imageURL: imageURL) { result in
                        switch result {
                        case .success:
                            self.showLoader()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2 ) {
                                self.dataEmpty()
                                let snackbar = TTGSnackbar(message: "Product saved successfully.", duration: .middle)
                                snackbar.show()
                                self.hideLoader()
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.hideLoader()
                                print("Failed to save product data: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.hideLoader()
                        print("Failed to upload image: \(error)")
                    }
                }
            }
        }
    }
    
    @IBAction func btnShowProductTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let productListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController {
                self.navigationController?.pushViewController(productListVC, animated: true)
            }
        }
    }
    
    func showLoader() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func dataEmpty() {
        self.titleTextField.text = ""
        self.descriptionTextView.text = ""
        self.weightTextField.text = ""
        self.imageView.image = nil
    }
    
    
    // MARK: - Select Image -
    @IBAction func selectImage(_ sender: UIButton) {
        checkPhotoLibraryPermission { granted in
            if granted {
                self.showImagePickerController(sourceType: .photoLibrary)
            } else {
                self.showSettingsAlert()
            }
        }
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        case .limited: break
        @unknown default:
            completion(false)
        }
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("\(sourceType) not available")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func showSettingsAlert() {
        let alertController = UIAlertController(
            title: "Photo Library Access Needed",
            message: "Please allow access to the photo library in settings to select a photo.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)")
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ pickerController: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImages = info[.originalImage] as? UIImage {
            imageView.image = selectedImages
            selectedImage = selectedImages
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func wightsKg(_ sender: Any) {
        if let btn1 = (sender as AnyObject).titleLabel?.text {
            self.weightTextField.text = btn1
            animate(toggel: false)
        }
    }
    
    
    @IBAction func weightsDrop(_ sender: UIButton) {
        weightKg.forEach { btn in
            UIView.animate(withDuration: 0.5) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
            }
            
        }
    }
    
    // MARK: - Animation Function
    func animate(toggel: Bool) {
        if toggel {
            weightKg.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = false
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        } else {
            weightKg.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = true
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        }
    }
}

extension ViewController {
    
    func shadowView() {
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowOffset = CGSize(width: 5, height: 5)
        backgroundView.layer.shadowRadius = 10
        backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath
        backgroundView.layer.cornerRadius = 20
    }
}
