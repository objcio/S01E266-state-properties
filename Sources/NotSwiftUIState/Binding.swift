//
//  File.swift
//  
//
//  Created by Chris Eidhof on 24.06.21.
//

import Foundation

@propertyWrapper
public struct Binding<Value> {
    var get: () -> Value
    var set: (Value) -> ()
    
    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}
