//
//  BuildingDrawer.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

struct BuildingDrawer {

    func draw(from buildings: [Building]) -> [Building] {
        var result: [Building] = []

        for rule in drawRules {
            let candidates = buildings.filter { $0.cost == rule.cost }

            guard !candidates.isEmpty else { continue }

            let selected = candidates.shuffled().prefix(rule.numberOfBuildings)
            result.append(contentsOf: selected)
        }

        return result
    }
}
