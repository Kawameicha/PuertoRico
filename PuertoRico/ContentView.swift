//
//  ContentView.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = BuildingViewModel()

    struct iOSCheckboxToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {

            Button(action: {
                configuration.isOn.toggle()
            }, label: {
                HStack {
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    configuration.label
                }
            })
        }
    }

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

                    Toggle("Avoid Hacienda + Lumberyard", isOn: $viewModel.enforceHaciendaLumberyardRule)
                    Toggle("Mix Citizen Buildings into draw", isOn: $viewModel.mixCityIntoRandomDraw)
                    Toggle("Avoid Villa + Large Tailor Shop", isOn: $viewModel.enforceVillaLargeTailorRule)
                        .padding(.horizontal, 12)
                }
                .toggleStyle(iOSCheckboxToggleStyle())
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !viewModel.outputMainText.isEmpty {
                        Text(viewModel.outputMainText)
                    }
                    if !viewModel.outputCityText.isEmpty {
                        Text(viewModel.outputCityText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
