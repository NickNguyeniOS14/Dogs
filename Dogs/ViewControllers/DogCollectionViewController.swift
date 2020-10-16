//
//  ViewController.swift
//  Dogs
//
//  Created by Nick Nguyen on 10/13/20.
//

import UIKit

class DogCollectionViewController: UICollectionViewController {

    let networkingManager = NetworkManager()
    var dogs: [String] = []

    private let cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    private var operations = [Int: Operation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkingManager.fetchDogs { (result) in
            self.dogs = try! result.get()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DogCell
//        loadImage(forCell: cell, forItemAt: indexPath)
        let dog = dogs[indexPath.item]
        cell.dogImageView.imageFromServerURL(dog, placeHolder: nil)
        return cell 
    }

    // MARK:- Load Images

    private func loadImage(forCell cell: DogCell, forItemAt indexPath: IndexPath) {
        let dog = dogs[indexPath.item]

        // Check for image in cache
        if let cachedImageData = cache.value(for: indexPath.item),
           let image = UIImage(data: cachedImageData) {
            cell.dogImageView.image = image
            return
        }

        // Start an operation to fetch image data
        let fetchOp = FetchPhotoOperation(dog: dog)

        let cacheOp = BlockOperation {
            if let data = fetchOp.imageData {
                self.cache.cache(value: data, for: indexPath.item)
            }
        }
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: indexPath.item) }

            if let currentIndexPath = self.collectionView?.indexPath(for: cell),
               currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }

            if let data = fetchOp.imageData {
                cell.dogImageView.image = UIImage(data: data)
            }
        }

        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)

        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)

        operations[indexPath.item] = fetchOp
    }
}

