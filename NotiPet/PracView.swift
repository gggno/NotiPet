import SwiftUI

struct PracView: View {
    var body: some View {
        VStack {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding()

            Text("Selected Image")
                .font(.headline)
                .padding()
        }
    }
}

struct PracView_Previews: PreviewProvider {
    static var previews: some View {
        PracView()
    }
}
