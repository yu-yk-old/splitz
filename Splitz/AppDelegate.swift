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
        
        ResizeWindowScript.load()
        let resizeScript = ResizeWindowScript.resizeWindow() as! AppleScriptProtocol
        
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { (mevent) in
            let appName = NSWorkspace.shared.frontmostApplication?.localizedName
            print("app name: \(String(describing: appName))")
            print(NSEvent.mouseLocation)
            
            let mainScreen = NSScreen.main
            print(NSStringFromRect((mainScreen!.frame)))
            
            resizeScript.resizeWindow()

//            let parameters = NSAppleEventDescriptor.list()
//            parameters.insert(NSAppleEventDescriptor(string: "Hello Cruel World!"), at: 0)
//
//            let event = NSAppleEventDescriptor(
//                eventClass: AEEventClass(kASAppleScriptSuite),
//                eventID: AEEventID(kASSubroutineEvent),
//                targetDescriptor: nil,
//                returnID: AEReturnID(kAutoGenerateReturnID),
//                transactionID: AETransactionID(kAnyTransactionID)
//            )
//
//            let urlPath = Bundle.main.url(forResource: "ResizeWindow", withExtension: "scpt")
//            let appleScript = try! NSUserAppleScriptTask(url: urlPath!)
//            appleScript.execute(withAppleEvent: event) { (appleEvent, error) in
//                if let error = error {
//                    print(error)
//                }
//            }
            
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

