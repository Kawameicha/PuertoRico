//
//  BuildingViewModel.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import Foundation
import Observation

struct DrawSettings {
    var selectedGames: Set<GameType>
    var enforceVillaLargeTailorRule: Bool
    var enforceHaciendaLumberyardRule: Bool
    var mixCityIntoRandomDraw: Bool
    var swapSchoolFactoryCosts: Bool
}

struct BuildingDisplayRow: Identifiable {
    let id = UUID()
    let iconName: String?
    let text: String
    let cost: Int
    let vict: Int
}

struct CostGroup: Identifiable {
    let id = UUID()
    let cost: Int
    let rows: [BuildingDisplayRow]
}

struct VPSection: Identifiable {
    let id = UUID()
    let vp: Int
    let costGroups: [CostGroup]
}

struct FlatRow: Identifiable {
    let id = UUID()
    let vp: Int?
    let cost: Int?
    let name: String
    let iconName: String?
}

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

    private func iconName(for game: GameType) -> String? {
        switch game {
        case .exp: return "exp"
        case .cit: return "cit"
        case .reg: return nil
        }
    }

    var outputMainText: String {
        let source: [Building] = appliedSettings.mixCityIntoRandomDraw
            ? drawnBuildings
            : drawnBuildings.filter { $0.game == .reg || $0.game == .exp }

        return source
            .map { "\($0.name) [\($0.game.rawValue)] (Cost: \($0.cost), VP: \($0.vict))" }
            .joined(separator: "\n")
    }

    var outputCityText: String {
        guard !appliedSettings.mixCityIntoRandomDraw else { return "" }

        return drawnBuildings
            .filter { $0.game == .cit }
            .map { "\($0.name) [\($0.game.rawValue)] (Cost: \($0.cost), VP: \($0.vict))" }
            .joined(separator: "\n")
    }

    var mainDisplayRows: [BuildingDisplayRow] {
        let source: [Building] = appliedSettings.mixCityIntoRandomDraw
            ? drawnBuildings
            : drawnBuildings.filter { $0.game == .reg || $0.game == .exp }
        return source.map { b in
            BuildingDisplayRow(
                iconName: iconName(for: b.game),
                text: "\(b.name)",
                cost: b.cost,
                vict: b.vict
            )
        }
    }

    var mainGroupedSections: [VPSection] {
        // Group available rows by cost
        let rowsByCost = Dictionary(grouping: mainDisplayRows, by: { $0.cost })

        // Build cost groups in the order of drawRules (respecting limits)
        let costGroups: [CostGroup] = drawRules.compactMap { rule in
            guard let rows = rowsByCost[rule.cost], !rows.isEmpty else { return nil }
            let picked = Array(rows.prefix(rule.numberOfBuildings))
            return CostGroup(cost: rule.cost, rows: picked)
        }

        // Group those cost groups by victory points from the rows' vict
        let groupsByVP = Dictionary(grouping: costGroups, by: { group in
            group.rows.first?.vict ?? 0
        })

        // Map into sections sorted by VP ascending, with costs ascending inside
        return groupsByVP
            .map { vp, groups in
                VPSection(
                    vp: vp,
                    costGroups: groups.sorted(by: { $0.cost < $1.cost })
                )
            }
            .sorted(by: { $0.vp < $1.vp })
    }

    var cityDisplayRows: [BuildingDisplayRow] {
        guard !appliedSettings.mixCityIntoRandomDraw else { return [] }
        return drawnBuildings
            .filter { $0.game == .cit }
            .map { b in
                BuildingDisplayRow(
                    iconName: iconName(for: b.game),
                    text: "\(b.name)",
                    cost: b.cost,
                    vict: b.vict
                )
            }
    }

    var cityGroupedSections: [VPSection] {
        // Group available rows by cost
        let rowsByCost = Dictionary(grouping: cityDisplayRows, by: { $0.cost })

        // Build cost groups in the order of drawRules (respecting limits)
        let costGroups: [CostGroup] = drawRules.compactMap { rule in
            guard let rows = rowsByCost[rule.cost], !rows.isEmpty else { return nil }
            let picked = Array(rows.prefix(rule.numberOfBuildings))
            return CostGroup(cost: rule.cost, rows: picked)
        }

        // Group those cost groups by victory points from the rows' vict
        let groupsByVP = Dictionary(grouping: costGroups, by: { group in
            group.rows.first?.vict ?? 0
        })

        // Map into sections sorted by VP ascending, with costs ascending inside
        return groupsByVP
            .map { vp, groups in
                VPSection(
                    vp: vp,
                    costGroups: groups.sorted(by: { $0.cost < $1.cost })
                )
            }
            .sorted(by: { $0.vp < $1.vp })
    }
}
