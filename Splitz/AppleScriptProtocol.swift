//
//  AppleScriptProtocol.swift
//  Splitz
//
//  Created by Yu, Yukkuen on 2019/01/24.
//  Copyright © 2019 yu-yk. All rights reserved.
//

import Foundation

@objc(NSObject) protocol AppleScriptProtocol {
    var demoProp: NSString { get set }
    func demoHandler()
    func resizeWindow()
}
