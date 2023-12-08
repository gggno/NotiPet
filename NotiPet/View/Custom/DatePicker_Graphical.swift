import SwiftUI

struct DatePicker_Graphical: View {
    @State var currentDate: Date = Date()
    
    var body: some View {
        DatePicker("", selection: $currentDate)
            .datePickerStyle(.graphical)
    }
}

#Preview {
    DatePicker_Graphical()
}
