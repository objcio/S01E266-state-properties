protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

protocol BuiltinView {
    func _buildNodeTree(_ node: Node)
}

extension View {
    func observeObjects(_ node: Node) {
        let m = Mirror(reflecting: self)
        for child in m.children {
            guard let observedObject = child.value as? AnyObservedObject else { return }
            observedObject.addDependency(node)
        }
    }
    
    func equalToPrevious(_ node: Node) -> Bool {
        guard let previous = node.previousView as? Self else { return false }
        let m1 = Mirror(reflecting: self)
        let m2 = Mirror(reflecting: previous)
        for pair in zip(m1.children, m2.children) {
            guard pair.0.label == pair.1.label else { return false }
            let p1 = pair.0.value
            let p2 = pair.1.value
            if p1 is StateProperty { continue }
            if !isEqual(p1, p2) { return false }
        }
        return true
    }
    
    func buildNodeTree(_ node: Node) {
        if let b = self as? BuiltinView {
            node.view = b
            b._buildNodeTree(node)
            return
        }
        
        let shouldRunBody = node.needsRebuild || !self.equalToPrevious(node)
        if !shouldRunBody {
            for child in node.children {
                child.rebuildIfNeeded()
            }
            return
        }
        
        node.view = AnyBuiltinView(self)
        
        self.observeObjects(node)
        self.restoreStateProperties(node)
        
        let b = body
        if node.children.isEmpty {
            node.children = [Node()]
        }
        b.buildNodeTree(node.children[0])
        
        self.storeStateProperties(node)
        node.previousView = self
        node.needsRebuild = false
    }
    
    func restoreStateProperties(_ node: Node) {
        let m = Mirror(reflecting: self)
        for (label, value) in m.children {
            guard let prop = value as? StateProperty else { continue }
            guard let propValue = node.stateProperties[label!] else { continue }
            prop.value = propValue
        }
    }

    func storeStateProperties(_ node: Node) {
        let m = Mirror(reflecting: self)
        for (label, value) in m.children {
            guard let prop = value as? StateProperty else { continue }
            node.stateProperties[label!] = prop.value
        }
    }
}

extension Never: View {
    var body: Never {
        fatalError("We should never reach this")
    }
}

extension BuiltinView {
    var body: Never {
        fatalError("This should never happen")
    }
}

struct Button: View, BuiltinView {
    var title: String
    var action: () -> ()
    init(_ title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }
    
    func _buildNodeTree(_ node: Node) {
        // todo create a UIButton
    }
}
