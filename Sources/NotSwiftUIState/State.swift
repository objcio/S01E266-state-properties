//
//  File.swift
//  
//
//  Created by Chris Eidhof on 24.06.21.
//

import Foundation

protocol StateProperty {
    var value: Any { get nonmutating set }
}

@propertyWrapper
struct State<Value>: StateProperty {
    private var box: Box<Box<Value>>
    
    init(wrappedValue: Value) {
        self.box = Box(Box(wrappedValue))
    }
    
    var wrappedValue: Value {
        get { box.value.value }
        nonmutating set { box.value.value = newValue }
    }
    
    var value: Any {
        get { box.value }
        nonmutating set { box.value = newValue as! Box<Value> }
    }
}

final class Box<Value> {
    var value: Value
    init(_ value: Value) {
        self.value = value
    }
}
