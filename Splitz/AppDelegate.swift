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
                    #return properties of window 2
                    #for chrome is window 2
                    #repeat with x from 1 to (count windows)
                        get properties of window 1
                        set position of window 1 to {x1, y1}
                        set size of window 1 to {x2, y2}
                    #end repeat
                end try
                #set position of the first window to {x1, y1}
                #set size of the first window to {x2, y2}
                #set bounds of the first window to {x1, y1, x2, y2}

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
        
        let parameters = NSAppleEventDescriptor.list()
        parameters.insert(NSAppleEventDescriptor(int32: 0), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 0), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 500), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: 500), at: 0)

        let event = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )

        event.setDescriptor(NSAppleEventDescriptor(string: "resizeWindow"), forKeyword: AEKeyword(keyASSubroutineName))
        event.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { (mevent) in
            let appName = NSWorkspace.shared.frontmostApplication?.localizedName
            print("app name: \(String(describing: appName))")
            print(NSEvent.mouseLocation)
            
            let mainScreen = NSScreen.main
            print(NSStringFromRect((mainScreen!.frame)))
            
            var error: NSDictionary? = nil
            let result = self.script.executeAppleEvent(event, error: &error) as NSAppleEventDescriptor?
            print(result as Any)
            print(error as Any)
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

