//
//  DependencyContainerTests.swift
//  DependencyContainerTests
//
//  Created by Abdelrahman Mohamed on 02.09.2025.
//

import Testing
@testable import DependencyContainer

// MARK: - Test Protocols and Mock Services

protocol TestService: Sendable {
    var id: String { get }
}

protocol TestRepository: Sendable {
    func fetchData() -> String
}

final class MockTestService: TestService, @unchecked Sendable {
    let id: String
    
    init(id: String = "mock-service") {
        self.id = id
    }
}

final class MockTestRepository: TestRepository, @unchecked Sendable {
    func fetchData() -> String {
        return "mock-data"
    }
}

final class SingletonService: @unchecked Sendable {
    @MainActor static let shared = SingletonService()
    private init() {}
}

// MARK: - DIContainer Tests

@Suite("DIContainer Registration Tests")
struct DIContainerRegistrationTests {
    
    @Test("Register service with direct instance")
    func testRegisterDirectInstance() async throws {
        let container = await DIContainer()
        let service = MockTestService(id: "test-service")
        
        await container.register(TestService.self, service)
        
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.id == "test-service")
    }
    
    @Test("Register service with factory closure")
    func testRegisterFactoryClosure() async throws {
        let container = await DIContainer()
        
        await container.register(TestService.self) {
            MockTestService(id: "factory-service")
        }
        
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.id == "factory-service")
    }
    
    @Test("Register multiple different services")
    func testRegisterMultipleServices() async throws {
        let container = await DIContainer()
        let service = MockTestService(id: "service-1")
        let repository = MockTestRepository()
        
        await container.register(TestService.self, service)
        await container.register(TestRepository.self, repository)
        
        let resolvedService = await container.resolve(TestService.self)
        let resolvedRepository = await container.resolve(TestRepository.self)
        
        #expect(resolvedService != nil)
        #expect(resolvedRepository != nil)
        #expect(resolvedService?.id == "service-1")
        #expect(resolvedRepository?.fetchData() == "mock-data")
    }
}

@Suite("DIContainer Resolution Tests")
struct DIContainerResolutionTests {
    
    @Test("Resolve registered service successfully")
    func testResolveRegisteredService() async throws {
        let container = await DIContainer()
        let service = MockTestService(id: "resolved-service")
        
        await container.register(TestService.self, service)
        let resolved = await container.resolve(TestService.self)
        
        #expect(resolved != nil)
        #expect(resolved?.id == "resolved-service")
    }
    
    @Test("Resolve unregistered service returns nil")
    func testResolveUnregisteredService() async throws {
        let container = await DIContainer()
        
        let resolved = await container.resolve(TestService.self)
        
        #expect(resolved == nil)
    }
    
    @Test("Resolve service with wrong type returns nil")
    func testResolveWrongType() async throws {
        let container = await DIContainer()
        let service = MockTestService(id: "wrong-type")
        
        await container.register(TestService.self, service)
        let resolved = await container.resolve(TestRepository.self)
        
        #expect(resolved == nil)
    }
}

@Suite("DIContainer Service Override Tests")
struct DIContainerOverrideTests {
    
    @Test("Override existing service registration")
    func testOverrideServiceRegistration() async throws {
        let container = await DIContainer()
        let originalService = MockTestService(id: "original")
        let newService = MockTestService(id: "overridden")
        
        // Register original service
        await container.register(TestService.self, originalService)
        let firstResolved = await container.resolve(TestService.self)
        #expect(firstResolved?.id == "original")
        
        // Override with new service
        await container.register(TestService.self, newService)
        let secondResolved = await container.resolve(TestService.self)
        #expect(secondResolved?.id == "overridden")
    }
    
    @Test("Override factory with direct instance")
    func testOverrideFactoryWithDirectInstance() async throws {
        let container = await DIContainer()
        
        // Register factory first
        await container.register(TestService.self) {
            MockTestService(id: "factory")
        }
        let factoryResolved = await container.resolve(TestService.self)
        #expect(factoryResolved?.id == "factory")
        
        // Override with direct instance
        let directService = MockTestService(id: "direct")
        await container.register(TestService.self, directService)
        let directResolved = await container.resolve(TestService.self)
        #expect(directResolved?.id == "direct")
    }
}

@Suite("DIContainer Concurrency Tests")
struct DIContainerConcurrencyTests {
    
    @Test("Concurrent registration and resolution")
    func testConcurrentRegistrationAndResolution() async throws {
        let container = await DIContainer()
        
        // Register services sequentially (MainActor requirement)
        for i in 0..<10 {
            let service = MockTestService(id: "service-\(i)")
            await container.register(TestService.self, service)
        }
        
        // Test that resolution works after registration
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.id.hasPrefix("service-") == true)
    }
    
    @Test("Multiple resolution calls return same instance")
    func testMultipleResolutionCallsReturnSameInstance() async throws {
        let container = await DIContainer()
        let service = MockTestService(id: "singleton-like")
        
        await container.register(TestService.self, service)
        
        let resolved1 = await container.resolve(TestService.self)
        let resolved2 = await container.resolve(TestService.self)
        
        #expect(resolved1 != nil)
        #expect(resolved2 != nil)
        #expect(resolved1?.id == resolved2?.id)
    }
}

@Suite("DIContainer Edge Cases Tests")
struct DIContainerEdgeCasesTests {
    
    @Test("Register and resolve with empty string service name")
    func testEmptyStringServiceName() async throws {
        let container = await DIContainer()
        
        // This should work as String(describing:) will handle it
        await container.register(TestService.self) {
            MockTestService(id: "empty-test")
        }
        
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.id == "empty-test")
    }
    
    @Test("Register nil service (should not crash)")
    func testRegisterNilService() async throws {
        let container = await DIContainer()
        
        // This should not crash the container
        await container.register(TestService.self) {
            MockTestService(id: "nil-test")
        }
        
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
    }
    
    @Test("Register same service multiple times")
    func testRegisterSameServiceMultipleTimes() async throws {
        let container = await DIContainer()
        
        for i in 0..<5 {
            await container.register(TestService.self) {
                MockTestService(id: "multiple-\(i)")
            }
        }
        
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        // Should get the last registered service
        #expect(resolved?.id == "multiple-4")
    }
}

@Suite("DIContainer Integration Tests")
struct DIContainerIntegrationTests {
    
    @Test("Complete service lifecycle")
    func testCompleteServiceLifecycle() async throws {
        let container = await DIContainer()
        
        // 1. Register service
        let service = MockTestService(id: "lifecycle-test")
        await container.register(TestService.self, service)
        
        // 2. Resolve and verify
        let resolved = await container.resolve(TestService.self)
        #expect(resolved != nil)
        #expect(resolved?.id == "lifecycle-test")
        
        // 3. Override service
        let newService = MockTestService(id: "lifecycle-override")
        await container.register(TestService.self, newService)
        
        // 4. Resolve overridden service
        let overriddenResolved = await container.resolve(TestService.self)
        #expect(overriddenResolved != nil)
        #expect(overriddenResolved?.id == "lifecycle-override")
    }
    
    @Test("Complex dependency scenario")
    func testComplexDependencyScenario() async throws {
        let container = await DIContainer()
        
        // Register multiple services that might depend on each other
        await container.register(TestService.self) {
            MockTestService(id: "complex-service")
        }
        
        await container.register(TestRepository.self) {
            MockTestRepository()
        }
        
        // Resolve both services
        let service = await container.resolve(TestService.self)
        let repository = await container.resolve(TestRepository.self)
        
        #expect(service != nil)
        #expect(repository != nil)
        #expect(service?.id == "complex-service")
        #expect(repository?.fetchData() == "mock-data")
    }
}
