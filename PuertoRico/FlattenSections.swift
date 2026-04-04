//
//  FlattenRows.swift
//  PuertoRico
//
//  Created by Christoph Freier on 04.04.26.
//


import Foundation
import Observation

func flattenSections(_ sections: [VPSection]) -> [FlatRow] {
    var rows: [FlatRow] = []

    for section in sections {
        var isFirstVP = true

        for group in section.costGroups {
            var isFirstCost = true

            for row in group.rows {
                rows.append(
                    FlatRow(
                        vp: isFirstVP ? section.vp : nil,
                        cost: isFirstCost ? group.cost : nil,
                        name: row.text,
                        iconName: row.iconName
                    )
                )
                isFirstVP = false
                isFirstCost = false
            }
        }
    }

    return rows
}