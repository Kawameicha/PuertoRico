//
//  MakeSections.swift
//  PuertoRico
//
//  Created by Christoph Freier on 04.04.26.
//

import Foundation
import Observation

func makeSections(from rows: [BuildingDisplayRow]) -> [VPSection] {

    // Group rows by cost
    let rowsByCost = Dictionary(grouping: rows, by: \.cost)

    // Apply draw rules
    let costGroups: [CostGroup] = drawRules.compactMap { rule in
        guard let rows = rowsByCost[rule.cost], !rows.isEmpty else { return nil }
        return CostGroup(cost: rule.cost, rows: Array(rows.prefix(rule.numberOfBuildings)))
    }

    // Group by VP
    let groupsByVP = Dictionary(grouping: costGroups) { group in
        group.rows.first?.vict ?? 0
    }

    // Build final sections
    return groupsByVP
        .map { vp, groups in
            VPSection(
                vp: vp,
                costGroups: groups.sorted { $0.cost < $1.cost }
            )
        }
        .sorted { $0.vp < $1.vp }
}
