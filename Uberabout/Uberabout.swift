

import SwiftUI
import Cocoa
import os.log


fileprivate let logger = Logger(subsystem: "Uberabout", category: "")


struct Uberabout {
    
    static let windowWidth: CGFloat = 268.0
    static let windowHeight: CGFloat = 388.0
    
    static func aboutWindow(for bundle: Bundle = Bundle.main) -> NSWindow {
        
        let origin = CGPoint.zero
        let size = CGSize(width: self.windowWidth, height: self.windowHeight)
        
        let window = NSWindow(contentRect: NSRect(origin: origin, size: size),
                              styleMask: [.titled, .closable, .fullSizeContentView],
                              backing: .buffered,
                              defer: false)
        
        window.setFrameAutosaveName(bundle.appName)
        window.setAccessibilityTitle(bundle.appName)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        
        // Configure here
        let aboutView = UberaboutView(bundle: bundle,
                                      appIconBackside: Image("uberaboutIconBack"),
                                      creditsURL: "http://ixeau.com",
                                      organizationLogo: Image("uberaboutOrgaLogo"))
        
        window.contentView = NSHostingView(rootView: aboutView)
        window.center()
        
        return window
        
    }
    
}


// MARK: - About View
fileprivate struct UberaboutView: View {
    
    let bundle: Bundle
    var appIconBackside: Image? = nil // 128pt × 128pt
    var creditsURL: String? = nil
    var organizationLogo: Image? = nil // 12pt height max & render as template
    
    private let windowWidth: CGFloat = Uberabout.windowWidth
    private let windowHeight: CGFloat = Uberabout.windowHeight
    
    @State private var iconHover: Bool = false
    @State private var foregroundIconVisible: Bool = true
    @State private var backgroundIconVisible: Bool = false
    @State private var copyrightFlipped: Bool = false
    
    var body: some View {
        
        VStack(spacing: .zero) {
            
            Spacer()
            
            // App Icon
            
            ZStack {
                
                // App Icon: Back
                Group {
                    if let backside = self.appIconBackside {
                        backside.resizable()
                    } else {
                        AppIconPlaceholder()
                    }
                }
                .rotation3DEffect(self.backgroundIconVisible ? Angle.zero : Angle(degrees: -90.0),
                                  axis: (x: 0.0, y: 1.0, z: 0.0),
                                  anchor: .center,
                                  anchorZ: 0.0,
                                  perspective: -0.5)
                
                // App Icon: Front
                Group {
                    if let appIcon = NSApp.applicationIconImage {
                        Image(nsImage: appIcon)
                    } else {
                        AppIconPlaceholder()
                    }
                }
                .rotation3DEffect(self.foregroundIconVisible ? Angle.zero : Angle(degrees: 90.0),
                                  axis: (x: 0.0, y: 1.0, z: 0.0),
                                  anchor: .center,
                                  anchorZ: 0.0,
                                  perspective: -0.5)
                
            }
            .frame(width: 128.0, height: 128.0)
            .brightness(self.iconHover ? 0.05 : 0.0)
            .padding([.bottom], 14.0)
            .onHover(perform: {
                state in
                
                let ani = Animation.easeInOut(duration: 0.16)
                withAnimation(ani, {
                    self.iconHover = state
                })
                
                if !state && self.backgroundIconVisible {
                    self.flipIcon()
                }
                
            })
            .onTapGesture(perform: {
                self.flipIcon()
            })
            
            
            
            // App Name
            Text(Bundle.appName)
                .font(Font.title.weight(.semibold))
                .padding([.bottom], 6.0)
            
            
            // App Version & Build
            HStack(spacing: 4.0) {
                
                let versionSuffix = NSLocalizedString("Version",  bundle: self.bundle, comment: "")
                Text("\(versionSuffix)\u{00a0}\(Bundle.appVersionMarketing)")
                    .font(Font.body.weight(.medium))
                    .foregroundColor(.secondary)
                
                Text("(\(Bundle.appVersionBuild))")
                    .font(Font.body.monospacedDigit().weight(.regular))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
                
            }
            
            
            Spacer()
            
            
            // Credits
            Group {
                if let creditsURLString = self.creditsURL {
                    Button(action: {
                        if let url = URL(string: creditsURLString) {
                            NSWorkspace.shared.open(url)
                        }
                    }, label: {
                        Text("Credits", bundle: self.bundle)
                            .lineLimit(1)
                    })
                    .buttonStyle(UberaboutWindowButtonStyle())
                }
            }
            .padding([.top], 20.0)
            .padding([.bottom], 8.0)
            
            
            Spacer()
            
            
            Divider()
                .padding([.top], 16.0)
            
            
            // Copyright
            HStack(spacing: .zero) {
                
                Spacer()
                
                if let orgaLogo = self.organizationLogo {
                    
                    ZStack {
                        
                        orgaLogo
                            .frame(maxHeight: 12.0)
                            .rotation3DEffect(self.copyrightFlipped ? Angle(degrees: -90.0) : Angle.zero,
                                              axis: (x: 1.0, y: 0.0, z: 0.0),
                                              anchor: .center,
                                              anchorZ: 0.0,
                                              perspective: -0.5)
                        
                        Text(Bundle.copyrightHumanReadable)
                            .lineLimit(1)
                            .rotation3DEffect(self.copyrightFlipped ? Angle.zero : Angle(degrees: 90.0),
                                              axis: (x: 1.0, y: 0.0, z: 0.0),
                                              anchor: .center,
                                              anchorZ: 0.0,
                                              perspective: -0.5)
                        
                    }
                    
                } else {
                    
                    Text(Bundle.copyrightHumanReadable)
                        .lineLimit(1)
                    
                }
                
                Spacer()
                
            }
            .font(Font.footnote)
            .foregroundColor(.secondary)
            .opacity(0.7)
            .help(Bundle.copyrightHumanReadable)
            .padding([.top], 12.0)
            .padding([.bottom], 14.0)
            .background(Color.primary.opacity(0.03))
            .onHover(perform: {
                state in
                let ani = Animation.easeInOut(duration: 0.16)
                withAnimation(ani, {
                    self.copyrightFlipped = state
                })
            })
            
        }
        .frame(width: self.windowWidth, height: self.windowHeight)
        
        
    }
    
    
    private func flipIcon() {
        
        let reversed = self.foregroundIconVisible
        
        let inDuration = 0.12
        let inAnimation = Animation.easeIn(duration: inDuration)
        let outAnimation = Animation.easeOut(duration: 0.32)
        
        withAnimation(inAnimation, {
            if reversed {
                self.foregroundIconVisible.toggle()
            } else {
                self.backgroundIconVisible.toggle()
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + inDuration) {
            withAnimation(outAnimation, {
                if !reversed {
                    self.foregroundIconVisible.toggle()
                } else {
                    self.backgroundIconVisible.toggle()
                }
            })
        }
        
    }
    
    
}


// MARK: - App Icon Placeholder
fileprivate struct AppIconPlaceholder: View {
    private let cornerSize: CGSize = CGSize(width: 24.0, height: 24.0)
    var body: some View {
        return RoundedRectangle(cornerSize: self.cornerSize, style: .continuous)
            .foregroundColor(Color.secondary)
            .padding(13.0)
    }
}


// MARK: - Button Style
fileprivate struct UberaboutWindowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let color = Color.accentColor
        let pressed = configuration.isPressed
        return configuration.label
            .font(Font.body.weight(.medium))
            .padding([.leading, .trailing], 8.0)
            .padding([.top], 4.0)
            .padding([.bottom], 5.0)
            .background(color.opacity(pressed ? 0.08 : 0.14))
            .foregroundColor(color.opacity(pressed ? 0.8 : 1.0))
            .cornerRadius(5.0)
            
    }
}


// MARK: - Bundle Extension
extension Bundle {
    
    var appName: String {
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        } else {
            logger.debug("Unable to determine 'appName'")
            return ""
        }
    }
    
    static var appName: String {
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        } else {
            logger.debug("Unable to determine 'appName'")
            return ""
        }
    }
    
    static var appVersionMarketing: String {
        if let name = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return name
        } else {
            logger.debug("Unable to determine 'appVersionMarketing'")
            return ""
        }
    }
    
    static var appVersionBuild: String {
        let bundleKey = kCFBundleVersionKey as String
        if let version = Bundle.main.object(forInfoDictionaryKey: bundleKey) as? String {
            return version
        } else {
            logger.debug("Unable to determine 'appVersionBuild'")
            return "0"
        }
    }
    
    static var copyrightHumanReadable: String {
        if let name = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String {
            return name
        } else {
            logger.debug("Unable to determine 'copyrightHumanReadable'")
            return ""
        }
    }
    
}


// MARK: - Preview
struct UberaboutView_Previews: PreviewProvider {
    static var previews: some View {
        return UberaboutView(bundle: Bundle.main,
                             appIconBackside: Image("uberaboutIconBack"),
                             creditsURL: "http://ixeau.com",
                             organizationLogo: Image("uberaboutOrgaLogo"))
    }
}
