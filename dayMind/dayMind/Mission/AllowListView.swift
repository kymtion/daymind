import FamilyControls
import SwiftUI
import ManagedSettings

struct AllowListView: View {
    @State var selection = FamilyActivitySelection()
    @State var isPresented = false
    @State var savedStores: [ManagedSettingsStore.Name] = []
    @State var textInputPresented = false
    
    @ObservedObject var vm = MissionViewModel()
    
    var body: some View {
        List {
            ForEach(vm.savedStores, id: \.self) { storeName in
                Text(storeName)
            }.onDelete { indexSet in
                vm.deleteStore(at: indexSet)
            }
        }
        Button {
            isPresented = true
        } label: {
            Text("카테고리 추가 +")
        }
        .familyActivityPicker(isPresented: $isPresented, selection: $selection)
        .onChange(of: selection) { newSelection in
            let applications = selection.applications
            let categories = selection.categories
            let webDomains = selection.webDomains
            textInputPresented = true
        }
        .sheet(isPresented: $textInputPresented) {
            TextInputView(textInputPresented: $textInputPresented) { storeName in
                let store = ManagedSettingsStore.Name(rawValue: storeName)
                vm.addStore(store)
            }
        }
    }
}

struct AllowListView_Previews: PreviewProvider {
    static var previews: some View {
        AllowListView()
    }
}
