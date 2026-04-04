//
//  ContentView.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = BuildingViewModel()

    private func label(for game: GameType) -> String {
        switch game {
        case .exp: return "Expanded Buildings"
        case .cit: return "Citizen Buildings"
        default: return game.rawValue.capitalized
        }
    }

    var body: some View {
        VStack(spacing: 24) {

            Text("Drawn Buildings")
                .font(.title)

            GroupBox{
                VStack(alignment: .leading) {
                    Text("Include:")
                        .font(.headline)

                    ForEach([GameType.exp, GameType.cit], id: \.self) { game in
                        Toggle(label(for: game), isOn: Binding(
                            get: { viewModel.selectedGames.contains(game) },
                            set: { isOn in
                                if isOn { viewModel.selectedGames.insert(game) }
                                else { viewModel.selectedGames.remove(game) }
                            }
                        ))
                    }

                    Divider()
                        .padding(.vertical, 4)

                    Text("Alternative Game Rules:")
                        .font(.headline)

                    Toggle("Swap School and Factory costs", isOn: $viewModel.swapSchoolFactoryCosts)

                    // Avoid Hacienda + Lumberyard (only when .exp is selected)
                    let haciendaEnabled = viewModel.selectedGames.contains(.exp)
                    Toggle("Avoid Hacienda + Lumberyard", isOn: $viewModel.enforceHaciendaLumberyardRule)
                        .disabled(!haciendaEnabled)
                        .opacity(haciendaEnabled ? 1.0 : 0.5)

                    // Mix Citizen Buildings into draw (only when .cit is selected)
                    let mixEnabled = viewModel.selectedGames.contains(.cit)
                    Toggle("Mix Citizen Buildings into draw", isOn: $viewModel.mixCityIntoRandomDraw)
                        .disabled(!mixEnabled)
                        .opacity(mixEnabled ? 1.0 : 0.5)

                    // Avoid Villa + Large Tailor Shop (only when Mix is enabled)
                    let villaEnabled = viewModel.mixCityIntoRandomDraw
                    Toggle("Avoid Villa + Large Tailor Shop", isOn: $viewModel.enforceVillaLargeTailorRule)
                        .disabled(!villaEnabled)
                        .opacity(villaEnabled ? 1.0 : 0.5)
                        .padding(.horizontal, 12)
                }
                .toggleStyle(iOSCheckboxToggleStyle())
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.mainFlatRows) { row in
                        BuildingRowView(row: row)
                    }

                    if !viewModel.cityFlatRows.isEmpty {
                        Spacer()

                        Text("Additional Citizen Buildings")
                            .font(.headline)

                        ForEach(viewModel.cityFlatRows) { row in
                            BuildingRowView(row: row)
                        }
                    }
                }
            }

            Button("Redraw") {
                viewModel.draw()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
