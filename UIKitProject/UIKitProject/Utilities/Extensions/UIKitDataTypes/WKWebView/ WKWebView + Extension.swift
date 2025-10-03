//
//  File.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import WebKit

extension WKWebView {

    /// Load HTML string with custom CSS, UTF-8 charset, and disabled zoom
    func loadHTMLStringCustom(description: String, cssFileName: String = "style.css") {
        let cleanDescription = description.replacingOccurrences(of: "&nbsp;", with: " ")
        
        // <meta charset="UTF-8"> = suppport khmer language
        // <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"> = disable zoom in, out
        
        let htmlString = """
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <link rel="stylesheet" type="text/css" href="\(cssFileName)">
        </head>
        <body>
            \(cleanDescription)
        </body>
        </html>
        """
        
        self.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}
