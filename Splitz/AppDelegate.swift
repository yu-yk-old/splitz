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
                    repeat with x from 1 to (count windows)
                        if subrole of window x is "AXStandardWindow" then
                            set position of window x to {x1, y1}
                            set size of window x to {x2, y2}
                            return properties of windows
                        end if

                        #if frontmostApplication is "Google Chrome" then
                        #    if subrole of window x is "AXStandardWindow" then
                        #        set position of window x to {x1, y1}
                        #        set size of window x to {x2, y2}
                        #        return properties of windows
                        #    end if
                        #else
                        #    if subrole of window x is "AXStandardWindow" and focused of window x is true
                        #        set position of window x to {x1, y1}
                        #        set size of window x to {x2, y2}
                        #        return properties of windows
                        #    end if
                        #end if
                    end repeat
                    return properties of windows
                end try
            end tell
            end resizeWindow
        """
            )!
        let success = script.compileAndReturnError(nil)
        assert(success)
        return script
    }()
    
    var mouseDidDragged = false
    var shouldCallForMouseDrag = true
    var originalPos: [String:integer_t] = [:]
    var finalPos: [String:integer_t] = [:]
    
    let windowOptions = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let eventDescriptor = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { [unowned self](mouseEvent) in
            if self.shouldCallForMouseDrag {
                self.shouldCallForMouseDrag = false
                self.mouseDidDragged = true
                let appName = NSWorkspace.shared.frontmostApplication?.localizedName
                print("app name: \(String(describing: appName!))")
                
                let windowList = CGWindowListCopyWindowInfo(self.windowOptions, kCGNullWindowID) as! [NSDictionary]
                for windowInfo in windowList {
                    if windowInfo.value(forKey: "kCGWindowLayer") as? integer_t == 0 && windowInfo.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
                        self.originalPos = windowInfo.value(forKey: "kCGWindowBounds") as! [String:integer_t]
                        return
                    }
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { [unowned self](mouseEvent) in
            if self.mouseDidDragged {
                self.shouldCallForMouseDrag = true
                self.mouseDidDragged = false
                
                print("mouse location: \(NSEvent.mouseLocation)")
                let mainScreen = NSScreen.main!
                if NSEvent.mouseLocation.x <= mainScreen.frame.minX+2.0 {
                    let parameters = self.getPosDescriptor(mainScreen: mainScreen, lfbt: "left")
                    self.callScript(script: self.script, eventDescriptor: eventDescriptor, params: parameters, mousePos: self.originalPos)
//                    eventDescriptor.setDescriptor(NSAppleEventDescriptor(string: "resizeWindow"), forKeyword: AEKeyword(keyASSubroutineName))
//                    eventDescriptor.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
//                    self.windowList = CGWindowListCopyWindowInfo(self.windowOptions, kCGNullWindowID) as! [NSDictionary]
////                    print(self.windowList)
//                    for windowInfo in self.windowList {
//                        if windowInfo.value(forKey: "kCGWindowLayer") as? integer_t == 0 && windowInfo.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
//                            self.finalPos = windowInfo.value(forKey: "kCGWindowBounds") as! [String : integer_t]
////                            print(self.finalPos)
//                            if self.originalPos["X"]! != self.finalPos["X"]! || self.originalPos["Y"]! != self.finalPos["Y"] {
//                                print("window moved!")
//                                var error: NSDictionary? = nil
//                                let result = self.script.executeAppleEvent(eventDescriptor, error: &error) as NSAppleEventDescriptor?
//                                print(result! as Any)
//                                print(error as Any)
//                            }
//                            return
//                        }
//                    }

                } else if NSEvent.mouseLocation.x >= mainScreen.frame.maxX-2.0{
                    let parameters = self.getPosDescriptor(mainScreen: mainScreen, lfbt: "right")
                    self.callScript(script: self.script, eventDescriptor: eventDescriptor, params: parameters, mousePos: self.originalPos)
//                    eventDescriptor.setDescriptor(NSAppleEventDescriptor(string: "resizeWindow"), forKeyword: AEKeyword(keyASSubroutineName))
//                    eventDescriptor.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
//                    self.windowList = CGWindowListCopyWindowInfo(self.windowOptions, kCGNullWindowID) as! [NSDictionary]
////                    print(self.windowList)
//                    for windowInfo in self.windowList {
//                        if windowInfo.value(forKey: "kCGWindowLayer") as? integer_t == 0 && windowInfo.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
//                            self.finalPos = windowInfo.value(forKey: "kCGWindowBounds") as! [String : integer_t]
////                            print(self.finalPos)
//                            if self.originalPos["X"]! != self.finalPos["X"]! || self.originalPos["Y"]! != self.finalPos["Y"] {
//                                print("window moved!")
//                                var error: NSDictionary? = nil
//                                let result = self.script.executeAppleEvent(eventDescriptor, error: &error) as NSAppleEventDescriptor?
//                                print(result as Any)
//                                print(error as Any)
//                            }
//                            return
//                        }
//                    }

                }
            }
        }
        
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
        }
        
        constructMenu()
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
        menu.addItem(NSMenuItem(title: "Left/Right", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: "Top/Bottom", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "4 corner", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Splitz", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func getPosDescriptor(mainScreen: NSScreen, lfbt: String) -> NSAppleEventDescriptor {
        
        let parameters = NSAppleEventDescriptor.list()
        var x, y, width, height: Int32
//        print("minX, Y: \(mainScreen.frame.minX, mainScreen.frame.minY)")
//        print("midX, Y: \(mainScreen.frame.midX, mainScreen.frame.midY)")
//        print("maxX, Y: \(mainScreen.frame.maxX, mainScreen.frame.maxY)")
        if mainScreen.frame.minY != 0.0 {
            y = Int32(mainScreen.frame.minY - mainScreen.frame.maxY)
        } else {
            y = Int32(mainScreen.frame.minY)
        }
        switch lfbt {
        case "left":
            x = Int32(mainScreen.frame.minX)
            y = Int32(y)
            width = Int32(mainScreen.frame.width/2)
            height = Int32(mainScreen.frame.height)
        case "right":
            x = Int32(mainScreen.frame.midX)
            y = Int32(y)
            width = Int32(mainScreen.frame.width/2)
            height = Int32(mainScreen.frame.height)
//        case "bottom":
//            x = Int32(mainScreen.frame.minX)
//            y = Int32(mainScreen.frame.height/2)
//            width = Int32(mainScreen.frame.maxX)
//            height = Int32(mainScreen.frame.height/2)
//        case "top":
//            x = Int32(mainScreen.frame.minX)
//            y = Int32(y)
//            width = Int32(mainScreen.frame.maxX)
//            height = Int32(mainScreen.frame.height/2)
        default:
            x = Int32(mainScreen.frame.minX)
            y = Int32(y)
            width = Int32(mainScreen.frame.maxX)
            height = Int32(mainScreen.frame.height)
        }
        
        parameters.insert(NSAppleEventDescriptor(int32: x), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: y), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: width), at: 0)
        parameters.insert(NSAppleEventDescriptor(int32: height), at: 0)
        
        
        return parameters
    }
    
    func callScript(script: NSAppleScript, eventDescriptor: NSAppleEventDescriptor, params: NSAppleEventDescriptor, mousePos: [String:integer_t]) -> Void {
        eventDescriptor.setDescriptor(NSAppleEventDescriptor(string: "resizeWindow"), forKeyword: AEKeyword(keyASSubroutineName))
        eventDescriptor.setDescriptor(params, forKeyword: AEKeyword(keyDirectObject))
        let windowList = CGWindowListCopyWindowInfo(windowOptions, kCGNullWindowID) as! [NSDictionary]
        for windowInfo in windowList {
            if windowInfo.value(forKey: "kCGWindowLayer") as? integer_t == 0 && windowInfo.value(forKey: "kCGWindowAlpha") as? integer_t == 1 {
                let finalPos = windowInfo.value(forKey: "kCGWindowBounds") as! [String : integer_t]
                print(finalPos)
                if mousePos["X"]! != finalPos["X"]! || mousePos["Y"]! != finalPos["Y"] {
                    print("window moved!")
                    var error: NSDictionary? = nil
                    let result = script.executeAppleEvent(eventDescriptor, error: &error) as NSAppleEventDescriptor?
                    print(result! as Any)
                    print(error as Any)
                }
                return
            }
        }
        
    }
}

