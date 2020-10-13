//
//  Dog.swift
//  Dogs
//
//  Created by Nick Nguyen on 10/13/20.
//

import Foundation

typealias Dog = String

struct Dogs: Decodable {

    let dogs: [Dog]

    enum CodingKeys: String, CodingKey {
        case dogs = "message"
    }
}
