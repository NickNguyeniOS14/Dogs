//
//  FetchPhotoOperation.swift
//  Dogs
//
//  Created by Nick Nguyen on 10/13/20.
//

import UIKit

final class FetchPhotoOperation: ConcurrentOperation {

    // MARK: Properties

    let dog: Dog
    private let session: URLSession
    private(set) var imageData: Data?
    private var dataTask: URLSessionDataTask?


    init(dog: Dog, session: URLSession = URLSession.shared) {
        self.dog = dog
        self.session = session
        super.init()
    }

    override func start() {
        state = .isExecuting
        let url = URL(string:dog )!

        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.dog): \(error)")
                return
            }

            self.imageData = data
        }
        task.resume()
        dataTask = task
    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
