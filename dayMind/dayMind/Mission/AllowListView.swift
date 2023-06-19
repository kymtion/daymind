import FamilyControls
import SwiftUI
import ManagedSettings

struct AllowListView: View {
    @Binding var isPopupPresented: Bool
    @State var selection = FamilyActivitySelection()
    @State var isPresented = false
    @State var savedStores: [ManagedSettingsStore.Name] = []
    @State var textInputPresented = false
    @State var selectedStore = ""
    @State var showingActionSheet = false
    @State var editingStoreName = false
    
    @ObservedObject var vm = MissionViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(vm.savedStores, id: \.self) { storeName in
                        Button(action: {
                            selectedStore = storeName
                            showingActionSheet = true
                        }) {
                            HStack {
                                Text(storeName)
                                Spacer()
                                if storeName == selectedStore {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("Options for \(selectedStore)"), message: nil, buttons: [
                            .destructive(Text("삭제"), action: {
                                vm.deleteStore(storeName: selectedStore)
                                if selectedStore == selectedStore {
                                    selectedStore = vm.savedStores.first ?? ""
                                }
                                showingActionSheet = false
                            }),
                            .default(Text("이름편집"), action: {
                                editingStoreName = true
                                showingActionSheet = false
                            }),
                            .default(Text("적용"), action: {
                                showingActionSheet = false
                            }),
                            .cancel()
                        ])
                    }
                }
                .sheet(isPresented: $editingStoreName) {
                    TextInputView(textInputPresented: $editingStoreName) { storeName in
                        vm.updateStoreName(oldName: selectedStore, newName: storeName)
                    }
                }
                Button {
                    isPresented = true
                } label: {
                    Text("카테고리 추가 +")
                        .font(.system(size: 20))
                        .padding()
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
            .navigationTitle("앱 허용 리스트")
            .navigationBarItems(trailing: Button("적용") {
                vm.currentStore = selectedStore
                isPopupPresented = false
            })
        }
    }
}
struct AllowListView_Previews: PreviewProvider {
    @State static var isPopupPresented = false
    static var previews: some View {
        AllowListView(isPopupPresented: $isPopupPresented, vm: MissionViewModel())
    }
}
