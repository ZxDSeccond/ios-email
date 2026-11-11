import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var spoofer = SpoofEngine()
    @State private var showWebView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("🛡️ VIRTUAL DEVICE SPOOFER").font(.headline).foregroundColor(.blue)
                        Text("Engine Anti-Risk Google Signup").font(.subheadline).foregroundColor(.gray)
                    }.padding(.top, 10)
                    List {
                        Section(header: Text("Hardware Fingerprint")) {
                            IdRowView(title: "ID DEVICE", value: spoofer.deviceId) { spoofer.randomizeDeviceId() }
                            IdRowView(title: "ID WIFI", value: spoofer.wifiId) { spoofer.randomizeWifiId() }
                            IdRowView(title: "ID BLUETOOTH", value: spoofer.btId) { spoofer.randomizeBtId() }
                            IdRowView(title: "MAC ADDRESS", value: spoofer.macAddress) { spoofer.randomizeMac() }
                            IdRowView(title: "DEVICE MODEL", value: spoofer.deviceModel) { spoofer.randomizeModel() }
                            IdRowView(title: "ID IKLAN", value: spoofer.adId) { spoofer.randomizeAdId() }
                        }
                    }.listStyle(InsetGroupedListStyle())
                    
                    VStack(spacing: 12) {
                        Button(action: { spoofer.randomizeAll() }) {
                            HStack { Image(systemName: "arrow.clockwise.circle.fill"); Text("🔁 AUTO-REPLACE ALL") }
                            .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.orange).cornerRadius(12)
                        }
                        Button(action: { showWebView = true }) {
                            HStack { Image(systemName: "globe"); Text("🚀 BUKA GOOGLE SIGNUP") }
                            .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(12)
                        }
                    }.padding(.horizontal, 16).padding(.bottom, 15)
                }
            }
            .navigationTitle("Spoofer IPA")
            .sheet(isPresented: $showWebView) { GoogleSignupView(spoofer: spoofer) }
        }
    }
}
struct IdRowView: View {
    let title: String
    let value: String
    let onRefresh: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.gray)
                Text(value).font(.system(.body, design: .monospaced))
            }
            Spacer()
            Button(action: onRefresh) { Text("🔁").font(.title3).padding(6).background(Color.blue.opacity(0.1)).cornerRadius(8) }
        }.padding(.vertical, 4)
    }
}

class SpoofEngine: ObservableObject {
    @Published var deviceId = ""
    @Published var wifiId = ""
    @Published var btId = ""
    @Published var macAddress = ""
    @Published var deviceModel = ""
    @Published var adId = ""
    init() { randomizeAll() }
    func randomizeAll() {
        randomizeDeviceId(); randomizeWifiId(); randomizeBtId(); randomizeMac(); randomizeModel(); randomizeAdId()
    }
    func randomizeDeviceId() { deviceId = "HOO" + String(Int.random(in: 1000000000...9999999999)) }
    func randomizeWifiId() { wifiId = "WIFI-" + UUID().uuidString.prefix(8).uppercased() }
    func randomizeBtId() { btId = "BT-" + UUID().uuidString.prefix(8).uppercased() }
    func randomizeMac() {
        let hex = "0123456789ABCDEF"
        macAddress = "02:" + (0..<5).map { _ in String((0..<2).map { _ in hex.randomElement()! }) }.joined(separator: ":")
    }
    func randomizeModel() { deviceModel = ["Pixel 8 Pro", "Galaxy S24 Ultra", "Redmi Note 13"].randomElement()! }
    func randomizeAdId() { adId = UUID().uuidString }
}
struct GoogleSignupView: View {
    @ObservedObject var spoofer: SpoofEngine
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            WebViewWrapper(spoofer: spoofer)
                .navigationTitle("Google Signup")
                .navigationBarItems(leading: Button("Tutup") { presentationMode.wrappedValue.dismiss() })
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let spoofer: SpoofEngine
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {}
        let js = "window.localStorage.setItem('virtual_device_id', '\(spoofer.deviceId)');"
        config.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.customUserAgent = "Mozilla/5.0 (Linux; Android 14; \(spoofer.deviceModel)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36"
        if let url = URL(string: "https://accounts.google.com/signup/v2/createaccount?theme=glif&flowName=GlifWebSignIn&flowEntry=SignUp") {
            wv.load(URLRequest(url: url))
        }
        return wv
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
