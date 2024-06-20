//
//  FirestoreManager.swift
//  FirebaseDatabase
//
//  Created by Arpit iOS Dev. on 20/06/24.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()

    private let db = Firestore.firestore()

    public func saveProductData(name: String, description: String, weight: String, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let productData: [String: Any] = [
            "name": name,
            "description": description,
            "weight": weight,
            "imageURL": imageURL,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("products").addDocument(data: productData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func fetchAllProducts(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
            db.collection("products").getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let products = snapshot.documents.map { $0.data() }
                    completion(.success(products))
                }
            }
        }
    }
