//
//  StorageManager.swift
//  FirebaseDatabase
//
//  Created by Arpit iOS Dev. on 20/06/24.
//

import UIKit
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()

    private let storage = Storage.storage().reference()

    public func uploadProductImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Image Conversion", code: -1, userInfo: nil)))
            return
        }

        let fileName = UUID().uuidString
        let storageRef = storage.child("Images\(fileName).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
}
