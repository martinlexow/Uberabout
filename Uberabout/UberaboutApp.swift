

import SwiftUI


@main
struct UberaboutApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        
        WindowGroup {
            
            Button(action: {
                NSApp.sendAction(#selector(AppDelegate.openAboutWindow), to: nil, from: nil)
            }, label: {
                let aboutSuffix = NSLocalizedString("About", comment: "")
                Image(systemName: "questionmark.square.fill")
                Text("\(aboutSuffix)\u{00a0}\(Bundle.main.appName)").padding([.trailing], 3.0)
            })
            .buttonStyle(PlainButtonStyle())
            .font(Font.title)
            .foregroundColor(Color.blue)
            .padding(4.0)
            .background(Color.blue.opacity(0.16).cornerRadius(6.0))
            .padding(60.0)
            .fixedSize()
            
        }
        .commands {
            CommandGroup(replacing: .appInfo, addition: {
                Button(action: {
                    NSApp.sendAction(#selector(AppDelegate.openAboutWindow), to: nil, from: nil)
                }, label: {
                    let aboutSuffix = NSLocalizedString("About", comment: "")
                    Text("\(aboutSuffix)\u{00a0}\(Bundle.main.appName)")
                })
            })
        }
        
    }
}


fileprivate final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var aboutWindow: NSWindow = Uberabout.aboutWindow()
    
    @objc func openAboutWindow() {
        self.aboutWindow.makeKeyAndOrderFront(nil)
    }
    
}
