import Foundation

extension Sequence where Iterator.Element: ToDomainConvertible {
    func toDomain() -> [Iterator.Element.DomainEntity] {
        map { $0.toDomain() }
    }
}
