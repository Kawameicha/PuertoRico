//
//  BuildingViewModel.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import Observation

@Observable
final class BuildingViewModel {

    private let allBuildings: [Building]
    private let drawer = BuildingDrawer()

    var drawnBuildings: [Building] = []
    var selectedGames: Set<GameType> = [.reg, .exp, .cit]

    init() {
        self.allBuildings = BuildingRepository.loadBuildings()
        draw()
    }

    func draw() {
        let filtered = allBuildings.filter { selectedGames.contains($0.game) }
        drawnBuildings = drawer.draw(from: filtered)
    }

    var outputText: String {
        drawnBuildings
            .map { "\($0.name) [\($0.game.rawValue)] (Cost: \($0.cost), VP: \($0.vict))" }
            .joined(separator: "\n")
    }
}
