//
//  AppDelegate.swift
//  Splitz
//
//  Created by Yu, Yukkuen on 2019/01/22.
//  Copyright © 2019 yu-yk. All rights reserved.
//

import Cocoa
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    var script: NSAppleScript = {
        let script = NSAppleScript(source: """
            on resizeWindow(x1, y1, x2, y2)
            tell application "System Events"
                set frontmostApplication to name of the first process whose frontmost is true
            end tell

            tell application "System Events" to tell application process frontmostApplication
                try
                    if frontmostApplication is "Google Chrome" then
                        set position of window 2 to {x1, y1}
                        set size of window 2 to {x2, y2}
                    else
                        set position of window 1 to {x1, y1}
                        set size of window 1 to {x2, y2}
                    end if

                    #return properties of windows
                end try
            end tell
            end resizeWindow
        """
            )!
        let success = script.compileAndReturnError(nil)
        assert(success)
        return script
    }()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
        }
        
        constructMenu()
        
//        let screens = NSScreen.screens
//        for screen in screens {
//            print(NSStringFromRect(screen.visibleFrame))
//        }
        

        let eventDescriptor = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        
        let parameters = NSAppleEventDescriptor.list()
        parameters.insert(NSAppleEventDescriptor(int32: 0), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 0), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 500), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 500), at: 0)
        
        eventDescriptor.setDescriptor(NSAppleEventDescriptor(string: "resizeWindow"), forKeyword: AEKeyword(keyASSubroutineName))
        eventDescriptor.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
        
        var mainScreen: NSScreen = NSScreen.main!
        var mouseDidDragged = false
        var shouldCallForMouseDrag = true
        
        let windowOptions = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        var windowList = CGWindowListCopyWindowInfo(windowOptions, kCGNullWindowID)
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { (mouseEvent) in
            
                shouldCallForMouseDrag = true
                mouseDidDragged = false
                let appName = NSWorkspace.shared.frontmostApplication?.localizedName
                print("app name: \(String(describing: appName!))")
                
                windowList = CGWindowListCopyWindowInfo(windowOptions, kCGNullWindowID)
                for window in windowList as! [NSDictionary]{
                    if window.value(forKey: "kCGWindowLayer") as? integer_t == 0 && window.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
                        print(window)
                        return
                    }
                }
            
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { (mouseEvent) in
            if shouldCallForMouseDrag {
                shouldCallForMouseDrag = false
                mouseDidDragged = true
//                let appName = NSWorkspace.shared.frontmostApplication?.localizedName
//                print("app name: \(String(describing: appName!))")
                
//                windowList = CGWindowListCopyWindowInfo(windowOptions, kCGNullWindowID)
//                for window in windowList as! [NSDictionary]{
//                    if window.value(forKey: "kCGWindowLayer") as? integer_t == 0 && window.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
//                        print(window)
//                        return
//                    }
//                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { (mouseEvent) in
            if mouseDidDragged {
                shouldCallForMouseDrag = true
                mouseDidDragged = false
                
//                print(NSEvent.mouseLocation)
//                mainScreen = NSScreen.main!
//                print(NSStringFromRect(mainScreen.frame))
                
                windowList = CGWindowListCopyWindowInfo(windowOptions, kCGNullWindowID)
                for windowInfo in windowList as! [NSDictionary]{
                    if windowInfo.value(forKey: "kCGWindowLayer") as? integer_t == 0 && windowInfo.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
                        print(windowInfo)
                        return
                    }
                }
                
//                var error: NSDictionary? = nil
//                let result = self.script.executeAppleEvent(eventDescriptor, error: &error) as NSAppleEventDescriptor?
//                print(result! as Any)
//                print(error! as Any)
            }
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
}

