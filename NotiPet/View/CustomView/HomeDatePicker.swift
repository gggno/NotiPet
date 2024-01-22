import SwiftUI

struct HomeDatePicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker("",
                   selection: $selectedDate,
                   displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .tint(Color("PeachColor"))
        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
    }
}
