//
//  NetworkManager.swift
//  Dogs
//
//  Created by Nick Nguyen on 10/13/20.
//


import UIKit

let baseURL = "https://dog.ceo/api/breeds/image/random/50"

class NetworkManager {

    let jsonDecoder = JSONDecoder()

    func fetchDogs(completion: @escaping (Result<[Dog],Error>) -> Void) {
        let url = URL(string: baseURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
           
            if let error = error {
                print(error.localizedDescription)
            }

            guard let data = data else { return }
            do {
                let dogs = try self.jsonDecoder.decode(Dogs.self, from: data)
                completion(.success(dogs.dogs))

            } catch {
                print(error.localizedDescription)
            }

        }.resume()
    }
}
