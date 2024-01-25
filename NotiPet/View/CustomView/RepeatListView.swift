import SwiftUI

struct RepeatListView: View {
    @Binding var repeatType: RepeatType
    
    var body: some View {
        List {
            ForEach(RepeatType.allCases, id: \.self) { type in
                Button(action: {
                    repeatType = type
                    
                }, label: {
                    HStack {
                        Text(type.displayName)
                            .foregroundStyle(.black)
                        Spacer()
                        if type == repeatType {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("PeachColor"))
                        }
                    }
                })
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("반복")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RepeatListView(repeatType: .constant(.none))
}
