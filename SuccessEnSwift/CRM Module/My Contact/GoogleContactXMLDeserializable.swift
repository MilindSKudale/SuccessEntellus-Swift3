//
//  GoogleContactXMLDeserializable.swift
//  Quorg
//
//  Created by Nitesh I on 26/04/17.
//  Copyright © 2017 Nitesh Isave. All rights reserved.
//

struct GoogleContacts: XMLIndexerDeserializable {
    let fullName: String
    let email: String
    
    static func deserialize(_ node: XMLIndexer) throws -> GoogleContacts {
        if node["gd:name"].element != nil {
            return try GoogleContacts(
                fullName: node["gd:name"]["gd:fullName"].value(),
                email: "test"
                //email: node["gd:email"].value(ofAttribute: "address")
            )
        }
        else {
            return GoogleContacts(
                fullName: "no name for this contact",
                email: "test"
            )
        }
    }
}

