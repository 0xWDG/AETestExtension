//
//  Test.swift
//  TestExtension
//
//  Created by Wesley de Groot on 6 October 2022.
//

import Foundation
import AEExtensionKit
import SwiftUI

public class TestExtension: ExtensionInterface {
    var api: ExtensionAPI
    var AuroraAPI: AuroraAPI = { _, _ in }

    init(api: ExtensionAPI) {
        self.api = api
        print("Hello from TestExtension: \(api)!")
    }

    public func register() -> ExtensionManifest {
        return .init(
            name: "TestExtension",
            displayName: "TestExtension",
            version: "1.0",
            minAEVersion: "1.0"
        )
    }

    public func respond(action: String, parameters: [String: Any]) -> Bool {
        print("respond(action: String, parameters: [String: Any])", action, parameters)

        if action == "registerCallback" {
            if let api = parameters["callback"] as? AuroraAPI {
                AuroraAPI = api
            }

            for i in 0...9 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {

                    if i == 5 {
                        self.AuroraAPI(
                            "showWarning",
                            ["message": "a wild warning encountered!"]
                        )
                    }

                    print("Waiting for \(10 - i) seconds...")

                    self.AuroraAPI(
                        "showNotification",
                        [
                            "title":"showNotification",
                            "message": "Waiting for \(10 - i) seconds..."
                        ]
                    )
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.AuroraAPI(
//                    "openWindow", // Uses default size 500x500
//                    ["view": myWindow()]
//                )
                self.AuroraAPI(
                    "openSheet", // Fails to size.
                    ["view": myWindow()]
                )
//                self.AuroraAPI(
//                    "openTab", // Not done.
//                    ["view": myWindow()]
//                )
//                self.AuroraAPI(
//                    "openSettings",
//                    [:]
//                )
                self.AuroraAPI(
                    "showError",
                    ["message": "Ok, settings should be opened right now?"]
                )
            }
        }


        return true
    }
}

struct myWindow: View {
    var body: some View {
        VStack {
            Text("Hello, from extension")
            Divider()
            Text("SwiftUI View.")
            Divider()
            Button {
                let _ = print("DID CLICK BUTTON")
            } label: {
                Text("Button")
            }

        }
    }
}

@objc(TestBuilder)
public class TestBuilder: ExtensionBuilder {
    public override func build(withAPI api: ExtensionAPI) -> ExtensionInterface {
        return TestExtension(api: api)
    }
}
