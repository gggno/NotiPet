import SwiftUI

struct NotiAddDatePicker: View {
    @State var selectedDate: Date = Date()
    @Binding var notiDate: Date
    
    var body: some View {
        DatePicker("",
                   selection: $selectedDate,
                   displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .onChange(of: selectedDate) { oldValue, newValue in
            notiDate = selectedDate
        }
        .onAppear {
            selectedDate = notiDate
        }
    }
}
