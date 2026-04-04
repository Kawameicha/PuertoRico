//
//  DataModel.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import Foundation

struct Building: Codable, Identifiable {
    let id = UUID()
    let name: String
    let desc: String
    let cost: Int
    let vict: Int
    let game: GameType
}

enum GameType: String, CaseIterable, Codable {
    case reg
    case exp
    case cit

    var displayName: String {
        switch self {
        case .reg: return "Regular Buildings"
        case .exp: return "Expanded Buildings"
        case .cit: return "Citizen Buildings"
        }
    }
}

extension Building {
    func with(cost: Int? = nil) -> Building {
        Building(
            name: name,
            desc: desc,
            cost: cost ?? self.cost,
            vict: vict,
            game: game
        )
    }
}

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
