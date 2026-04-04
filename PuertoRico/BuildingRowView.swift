import SwiftUI

struct BuildingRowView: View {
    let row: FlatRow

    var body: some View {
        HStack(alignment: .firstTextBaseline) {

            Text(row.vp.map { "VP \($0)" } ?? "")
                .frame(width: 60, alignment: .leading)

            Text(row.cost.map { "Cost \($0)" } ?? "")
                .frame(width: 60, alignment: .leading)

            HStack(spacing: 4) {
                Text(row.name)

                if let icon = row.iconName {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.primary)
                        .aspectRatio(contentMode: .fit)
                        .offset(y: 0.5)
                }
            }

            Spacer()
        }
    }
}