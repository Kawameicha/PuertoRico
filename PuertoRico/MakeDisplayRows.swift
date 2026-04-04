//
//  MakeDisplayRows.swift
//  PuertoRico
//
//  Created by Christoph Freier on 04.04.26.
//

private func iconName(for game: GameType) -> String? {
    switch game {
    case .exp: return "exp"
    case .cit: return "cit"
    case .reg: return nil
    }
}

func makeDisplayRows(from buildings: [Building]) -> [BuildingDisplayRow] {
    buildings.map { b in
        BuildingDisplayRow(
            iconName: iconName(for: b.game),
            text: b.name,
            cost: b.cost,
            vict: b.vict
        )
    }
}
