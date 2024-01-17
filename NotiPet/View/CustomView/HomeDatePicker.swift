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
        .onChange(of: selectedDate) { oldValue, newValue in
//            notiDate = selectedDate
        }
        .onAppear {
//            selectedDate = notiDate
        }
    }
}
