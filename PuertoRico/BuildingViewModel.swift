//
//  BuildingViewModel.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import Foundation
import Observation

@Observable
final class BuildingViewModel {

    private let allBuildings: [Building]
    private let drawer = BuildingDrawer()

    var drawnBuildings: [Building] = []

    // UI state (editable anytime)
    var selectedGames: Set<GameType> = [.reg, .exp, .cit]
    var enforceVillaLargeTailorRule: Bool = false
    var enforceHaciendaLumberyardRule: Bool = false
    var mixCityIntoRandomDraw: Bool = false
    var swapSchoolFactoryCosts: Bool = false

    // Snapshot used for current output
    private var appliedSettings = DrawSettings(
        selectedGames: [.reg, .exp, .cit],
        enforceVillaLargeTailorRule: false,
        enforceHaciendaLumberyardRule: false,
        mixCityIntoRandomDraw: false,
        swapSchoolFactoryCosts: false
    )

    init() {
        self.allBuildings = BuildingRepository.loadBuildings()
        draw()
    }

    func draw() {
        // Freeze current UI state
        appliedSettings = DrawSettings(
            selectedGames: selectedGames,
            enforceVillaLargeTailorRule: enforceVillaLargeTailorRule,
            enforceHaciendaLumberyardRule: enforceHaciendaLumberyardRule,
            mixCityIntoRandomDraw: mixCityIntoRandomDraw,
            swapSchoolFactoryCosts: swapSchoolFactoryCosts
        )

        // We may need to redraw to satisfy pairing rules; cap attempts to prevent infinite loops
        let maxAttempts = 50
        var attempt = 0
        while attempt < maxAttempts {
            attempt += 1

            // Build the pool for random drawing: always include .reg; include .exp only if selected
            var randomPool: [Building] = []
            // Always include base game (.reg)
            randomPool += allBuildings.filter { $0.game == .reg }
            // Include .exp only when selected
            if selectedGames.contains(.exp) {
                randomPool += allBuildings.filter { $0.game == .exp }
            }
            // Optionally also include .cit if mixing into random pool
            if mixCityIntoRandomDraw {
                randomPool += allBuildings.filter { $0.game == .cit }
            }

            // Optionally swap costs for School and Factory for alternative rule
            let adjustedRandom: [Building]
            if swapSchoolFactoryCosts {
                adjustedRandom = randomPool.map {
                    switch $0.name {
                    case "School":
                        return $0.with(cost: 7)
                    case "Factory":
                        return $0.with(cost: 8)
                    default:
                        return $0
                    }
                }
            } else {
                adjustedRandom = randomPool
            }

            // Draw randomly from the combined pool of .reg and optional .exp and optional .cit
            let randomlyDrawn = drawer.draw(from: adjustedRandom)

            // If .cit is selected and not mixing into random pool, include ALL its buildings without randomization
            let cityAdditions: [Building] = (selectedGames.contains(.cit) && !mixCityIntoRandomDraw)
                ? allBuildings.filter { $0.game == .cit }
                : []

            // Combine and sort results
            let combinedUnsorted = randomlyDrawn + cityAdditions
            let combined = combinedUnsorted.sorted {
                ($0.cost, $0.name) < ($1.cost, $1.name)
            }

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

    var mainGroupedSections: [VPSection] {
        let buildings: [Building] = appliedSettings.mixCityIntoRandomDraw
            ? drawnBuildings
            : drawnBuildings.filter { $0.game == .reg || $0.game == .exp }

        return makeSections(from: makeDisplayRows(from: buildings))
    }

    var mainFlatRows: [FlatRow] {
        flattenSections(mainGroupedSections)
    }

    var cityGroupedSections: [VPSection] {
        guard !appliedSettings.mixCityIntoRandomDraw else { return [] }

        let buildings = drawnBuildings.filter { $0.game == .cit }

        return makeSections(from: makeDisplayRows(from: buildings))
    }

    var cityFlatRows: [FlatRow] {
        flattenSections(cityGroupedSections)
    }
}
