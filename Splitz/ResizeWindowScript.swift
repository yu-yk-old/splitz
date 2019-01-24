//
//  ResizeWindowScript.swift
//  Splitz
//
//  Created by Yu, Yukkuen on 2019/01/24.
//  Copyright © 2019 yu-yk. All rights reserved.
//

import Foundation
import AppleScriptObjC

class ResizeWindowScript {
    static func load() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
    }
    
    static func resizeWindow() -> AnyObject {
        let ScriptObj = NSClassFromString("ResizeWindowScriptObj")
        let obj = ScriptObj!.alloc()
        return obj as AnyObject
    }
}
