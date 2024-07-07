//
//  PublishedPersist.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Combine
import Foundation

protocol PersistProvider {
    func data(forKey: String) -> Data?
    func set(_ data: Data?, forKey: String)
}

class UserDefaultPersistProvider: PersistProvider {
    func data(forKey: String) -> Data? {
        UserDefaults.standard.data(forKey: forKey)
    }

    func set(_ data: Data?, forKey: String) {
        UserDefaults.standard.set(data, forKey: forKey)
    }
}

private let valueEncoder = JSONEncoder()
private let valueDecoder = JSONDecoder()

@propertyWrapper
struct Persist<Value: Codable> {
    private let subject: CurrentValueSubject<Value, Never>
    private let cancellables: Set<AnyCancellable>

    public var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    public init(key: String, defaultValue: Value, engine: PersistProvider) {
        if let data = engine.data(forKey: key),
           let object = try? valueDecoder.decode(Value.self, from: data)
        {
            subject = CurrentValueSubject<Value, Never>(object)
        } else {
            subject = CurrentValueSubject<Value, Never>(defaultValue)
        }

        var cancellables: Set<AnyCancellable> = .init()
        subject
            .receive(on: DispatchQueue.global())
            .map { try? valueEncoder.encode($0) }
            .removeDuplicates()
            .sink { engine.set($0, forKey: key) }
            .store(in: &cancellables)
        self.cancellables = cancellables
    }

    public var wrappedValue: Value {
        get { subject.value }
        set { subject.send(newValue) }
    }
}

@propertyWrapper
struct PublishedPersist<Value: Codable> {
    @Persist private var value: Value

    public var projectedValue: AnyPublisher<Value, Never> { $value }

    @available(*, unavailable, message: "accessing wrappedValue will result undefined behavior")
    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedPersist<Value>>
    ) -> Value {
        get { object[keyPath: storageKeyPath].value }
        set {
            (object.objectWillChange as? ObservableObjectPublisher)?.send()
            object[keyPath: storageKeyPath].value = newValue
        }
    }

    public init(key: String, defaultValue: Value, engine: PersistProvider) {
        _value = .init(key: key, defaultValue: defaultValue, engine: engine)
    }
}

extension Persist {
    init(key: String, defaultValue: Value) {
        self.init(key: key, defaultValue: defaultValue, engine: UserDefaultPersistProvider())
    }
}

extension PublishedPersist {
    init(key: String, defaultValue: Value) {
        self.init(key: key, defaultValue: defaultValue, engine: UserDefaultPersistProvider())
    }
}
