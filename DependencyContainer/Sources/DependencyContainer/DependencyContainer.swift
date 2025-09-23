//
//  DependencyContainer.swift
//  DependencyContainer
//
//  Created by Abdelrahman Mohamed on 28.08.2025.
//

import Foundation

@Observable
@MainActor
public final class DIContainer {
    
    private var services: [String: Any] = [:]
    
    public init() {}
    
    public func register<T>(_ service: T.Type, _ implementation: T) {
        let serviceName = String(describing: service)
        services[serviceName] = implementation
    }
    
    public func register<T>(_ service: T.Type, _ implementation: () -> T) {
        let serviceName = String(describing: service)
        services[serviceName] = implementation()
    }
    
    public func resolve<T>(_ service: T.Type) -> T? {
        let serviceName = String(describing: service)
        return services[serviceName] as? T
    }
    
    // Safe resolve with default value
    public func resolve<T>(_ service: T.Type, default defaultValue: T) -> T {
        let serviceName = String(describing: service)
        return services[serviceName] as? T ?? defaultValue
    }
    
    // Safe resolve that throws an error instead of returning nil
    public func requireResolve<T>(_ service: T.Type) throws -> T {
        let serviceName = String(describing: service)
        guard let service = services[serviceName] as? T else {
            throw DIError.serviceNotRegistered(serviceName)
        }
        return service
    }
}

public enum DIError: Error {
    case serviceNotRegistered(String)
}
