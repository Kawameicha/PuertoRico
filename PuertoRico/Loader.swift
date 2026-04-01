//
//  Loader.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import Foundation

final class BuildingRepository {

    static func loadBuildings() -> [Building] {

        guard let url = Bundle.main.url(forResource: "buildings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let buildings = try? JSONDecoder().decode([Building].self, from: data)

        else {
            return []
        }

        return buildings
    }
}
