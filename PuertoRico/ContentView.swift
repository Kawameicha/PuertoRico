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
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.mainDisplayRows.isEmpty {
                        ForEach(viewModel.mainDisplayRows) { row in
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(row.text)
                                if let icon = row.iconName {
                                    Image(icon)
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.primary)
                                        .aspectRatio(contentMode: .fit)
                                        .offset(y: 2)
                                }
                            }
                        }
                    }

                    Spacer()

                    if !viewModel.cityDisplayRows.isEmpty {
                        ForEach(viewModel.cityDisplayRows) { row in
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(row.text)
                                if let icon = row.iconName {
                                    Image(icon)
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.primary)
                                        .aspectRatio(contentMode: .fit)
                                        .offset(y: 2)
                                }
                            }
                        }
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
