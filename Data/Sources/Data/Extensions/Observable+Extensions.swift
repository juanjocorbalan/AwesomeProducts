import Foundation

extension Sequence where Iterator.Element: DomainConvertibleEntity {
    func toDomain() -> [Iterator.Element.DomainEntity] {
        map { $0.toDomain() }
    }
}
