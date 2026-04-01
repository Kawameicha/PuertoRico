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
        // Build the pool for random drawing: always include .reg; include .exp only if selected
        var randomPool: [Building] = []
        // Always include base game (.reg)
        randomPool += allBuildings.filter { $0.game == .reg }
        // Include expansion (.exp) only when selected
        if selectedGames.contains(.exp) {
            randomPool += allBuildings.filter { $0.game == .exp }
        }

        // Draw randomly from the combined pool of .reg and optional .exp
        let randomlyDrawn = drawer.draw(from: randomPool)

        // If .cit is selected, include ALL city buildings without randomization
        let cityAdditions: [Building] = selectedGames.contains(.cit)
            ? allBuildings.filter { $0.game == .cit }
            : []

        // Combine results and deduplicate by name to avoid duplicates
        let combined = randomlyDrawn + cityAdditions
        var seenNames = Set<String>()
        self.drawnBuildings = combined.filter { building in
            if seenNames.contains(building.name) { return false }
            seenNames.insert(building.name)
            return true
        }
    }

    var outputMainText: String {
        drawnBuildings
            .filter { $0.game == .reg || $0.game == .exp }
            .map { "\($0.name) [\($0.game.rawValue)] (Cost: \($0.cost), VP: \($0.vict))" }
            .joined(separator: "\n")
    }

    var outputCityText: String {
        drawnBuildings
            .filter { $0.game == .cit }
            .map { "\($0.name) [\($0.game.rawValue)] (Cost: \($0.cost), VP: \($0.vict))" }
            .joined(separator: "\n")
    }

    var outputText: String {
        switch (outputCityText.isEmpty) {
        case (false):
            return outputMainText + "\n\n" + outputCityText
        default:
            return outputMainText
        }
    }
}
