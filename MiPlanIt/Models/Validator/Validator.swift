import Foundation

enum ValidatorType {
    case email, password, phoneNumber, username, productName, location, amount, billDate, couponName, couponCode, couponID, shoppingListName, storeName
}

class ValidationError: Error {
    
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> Bool
}

enum VaildatorFactory {
    
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .username: return UserNameValidator()
        case .phoneNumber: return PhoneNumberValidator()
        case .productName: return ProductNameValidator()
        case .location: return LocationValidator()
        case .amount: return AmountValidator()
        case .billDate: return BillDateValidator()
        case .couponName: return CouponNameValidator()
        case .couponCode: return CouponCodeValidator()
        case .couponID: return CouponIdValidator()
        case .shoppingListName: return ShoppingListName()
        case .storeName: return StoreNameValidator()
        }
    }
}

struct ShoppingListName: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectShoppingListName)
        }
    }
}

struct StoreNameValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectStoreName)
        }
    }
}

struct ProductNameValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectProductName)
        }
    }
}

struct CouponNameValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectCouponName)
        }
    }
}

struct CouponCodeValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectCouponCode)
        }
    }
}

struct CouponIdValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectCouponId)
        }
    }
}

struct LocationValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectLocationName)
        }
    }
}

struct AmountValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectAmount)
        }
    }
}

struct BillDateValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateDate() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectDate)
        }
    }
}

struct EmailValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        guard value.validateString() else {
            throw ValidationError(Message.requiredEmailAddress)
        }
        if value.validateEmail() {
            return true
        }
        else {
            throw ValidationError(Message.invalidEmailAddress)
        }
    }
}

struct UserNameValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectUserName)
        }
    }
}

struct PasswordValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        if value.validateString() {
            return true
        }
        else {
            throw ValidationError(Message.incorrectPassword)
        }
    }
}

struct PhoneNumberValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> Bool {
        guard value.validateString() else {
            throw ValidationError(Message.requiredPhoneNumber)
        }
        if value.validatePhone() {
            return true
        }
        else {
            throw ValidationError(Message.invalidPhoneNumber)
        }
    }
}
