# 11 Testing Strategy: DCI ERP

## 1.1 Quality Assurance Goals
Ensure 100% reliability for financial transactions and inventory integrity.

## 1.2 Unit Testing
- **Target**: Domain Entities and Use Cases.
- **Tools**: `flutter_test`, `mockito`.
- **Focus**: Validating tax calculations and stock adjustment logic.

## 1.3 Widget Testing
- **Target**: Reusable atoms in `lib/components`.
- **Focus**: Ensuring `DesignTokens` are applied correctly and widgets respond to user interaction.

## 1.4 Integration Testing (E2E)
- **Target**: Full business flows.
- **Location**: `integration_test/full_flow_test.dart`.
- **Test Scenario**:
    1.  Login.
    2.  Check Inventory.
    3.  Create Customer.
    4.  Generate Invoice.
    5.  Verify balance update.

## 1.5 Performance Testing
- **Benchmarking**: Ensuring list views with 500+ items remain jank-free.
- **Network**: Testing app behavior under "Slow 3G" simulated conditions.
