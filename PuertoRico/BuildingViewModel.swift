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
    var enforceVillaLargeTailorRule: Bool = false
    var enforceHaciendaLumberyardRule: Bool = false

    init() {
        self.allBuildings = BuildingRepository.loadBuildings()
        draw()
    }

    func draw() {
        // We may need to redraw to satisfy pairing rules; cap attempts to prevent infinite loops
        let maxAttempts = 50
        var attempt = 0
        while attempt < maxAttempts {
            attempt += 1

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

            // Combine results
            let combined = randomlyDrawn + cityAdditions

            // Check pairing rules if enabled
            let names = Set(combined.map { $0.name })
            let hasVillaAndLargeTailor = names.contains("Villa") && names.contains("Large Tailor Shop")
            let hasHaciendaAndLumberyard = names.contains("Hacienda") && names.contains("Lumberyard")
            let violatesVillaTailor = enforceVillaLargeTailorRule && hasVillaAndLargeTailor
            let violatesHaciendaLumber = enforceHaciendaLumberyardRule && hasHaciendaAndLumberyard

            if !(violatesVillaTailor || violatesHaciendaLumber) {
                self.drawnBuildings = combined
                break
            }

            // If last attempt, accept candidate to avoid infinite loop
            if attempt == maxAttempts {
                self.drawnBuildings = combined
            }
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
}
