// Oil Timer for the desktop: shows index.html?desktop=1 in a transparent,
// borderless window that floats above other windows. No background at all,
// just the timer. Opened from the web page through the oiltimer:// link.
import Cocoa
import WebKit

final class FloatingWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler {
    var window: FloatingWindow!
    var web: WKWebView!
    var query = ""

    func applicationWillFinishLaunching(_ notification: Notification) {
        // oiltimer://open?design=…&palette=…&duration=…
        NSAppleEventManager.shared().setEventHandler(
            self, andSelector: #selector(handleURL(_:reply:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let size = NSSize(width: 280, height: 560)
        let rect = NSRect(x: screen.maxX - size.width - 40, y: screen.midY - size.height / 2, width: size.width, height: size.height)

        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "oiltimer")
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        web = WKWebView(frame: NSRect(origin: .zero, size: size), configuration: config)
        web.setValue(false, forKey: "drawsBackground")
        if #available(macOS 12.0, *) { web.underPageBackgroundColor = .clear }
        web.autoresizingMask = [.width, .height]

        window = FloatingWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = web
        load()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func handleURL(_ event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        guard let s = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let comps = URLComponents(string: s) else { return }
        query = comps.percentEncodedQuery ?? ""
        if web != nil { load(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
    }

    // the page in the project folder (always the latest), else the copy inside the app
    func htmlURL() -> URL {
        if let p = Bundle.main.object(forInfoDictionaryKey: "OTProjectHTML") as? String,
           FileManager.default.fileExists(atPath: p) { return URL(fileURLWithPath: p) }
        return Bundle.main.url(forResource: "index", withExtension: "html")!
    }

    func load() {
        let file = htmlURL()
        var comps = URLComponents(url: file, resolvingAgainstBaseURL: false)!
        comps.percentEncodedQuery = "desktop=1" + (query.isEmpty ? "" : "&" + query)
        web.loadFileURL(comps.url!, allowingReadAccessTo: file.deletingLastPathComponent())
    }

    // messages from the page: move the window, resize it, close
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "move":
            let dx = (body["dx"] as? Double) ?? 0, dy = (body["dy"] as? Double) ?? 0
            var origin = window.frame.origin
            origin.x += dx; origin.y -= dy
            window.setFrameOrigin(origin)
        case "size":
            let k = (body["k"] as? Double) ?? 1
            let f = window.frame
            let w = min(700, max(160, f.width * k)), h = min(1400, max(320, f.height * k))
            window.setFrame(NSRect(x: f.midX - w / 2, y: f.midY - h / 2, width: w, height: h), display: true, animate: true)
        case "close":
            NSApp.terminate(nil)
        case "log":
            let line = "\(Date()) \((body["msg"] as? String) ?? "")\n"
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("oiltimer-desktop.log")
            if let h = try? FileHandle(forWritingTo: url) { h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); try? h.close() }
            else { try? line.write(to: url, atomically: true, encoding: .utf8) }
        default: break
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)      // a desktop object: no Dock icon
app.run()
