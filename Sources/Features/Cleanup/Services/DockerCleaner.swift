import Foundation

/// Docker 정리 가능 용량. 파일 삭제가 아니라 `docker system prune`을 실행한다.
/// 안전을 위해 `-a`(사용 안 하는 전체 이미지 제거) 없이, 댕글링 이미지·중지 컨테이너·
/// 미사용 네트워크·빌드 캐시만 정리한다(named volume은 건드리지 않음). docker 미설치 시 빈 결과.
struct DockerCleaner: CleanerModule {
    let id = "docker"
    let category = ScanCategory.docker
    let displayName = "Docker 캐시"

    func scan(at root: String) async throws -> [ScanItem] {
        guard let docker = Shell.find("docker") else { return [] }
        let bytes = Self.reclaimableBytes(docker: docker)
        guard bytes > 0 else { return [] }
        return [ScanItem(
            path: "docker://reclaimable",
            displayName: "댕글링 이미지·중지 컨테이너·빌드 캐시",
            category: .docker, sizeBytes: bytes,
            isSafeToDelete: true, isSelectedByDefault: false
        )]
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary {
        guard !items.isEmpty, let docker = Shell.find("docker") else {
            return CleanSummary(itemsCleaned: 0, bytesFreed: 0, errors: [], timestamp: Date())
        }
        let before = Self.reclaimableBytes(docker: docker)
        _ = Shell.run(docker, ["system", "prune", "-f"])
        let after = Self.reclaimableBytes(docker: docker)
        return CleanSummary(
            itemsCleaned: 1, bytesFreed: max(0, before - after),
            errors: [], timestamp: Date()
        )
    }

    /// `docker system df`의 Reclaimable 합(바이트). 추정치(요약은 실제 회수량으로 표시).
    static func reclaimableBytes(docker: String) -> Int64 {
        guard let result = Shell.run(docker, ["system", "df", "--format", "{{.Reclaimable}}"]),
              result.exitCode == 0 else { return 0 }
        return result.output
            .split(separator: "\n")
            .reduce(Int64(0)) { $0 + parseSize(String($1)) }
    }

    static func parseSize(_ text: String) -> Int64 {
        let token = text.trimmingCharacters(in: .whitespaces)
            .split(separator: " ").first.map(String.init) ?? ""
        let number = token.prefix { $0.isNumber || $0 == "." }
        let unit = token.dropFirst(number.count).uppercased()
        guard let value = Double(number) else { return 0 }
        let multiplier: Double
        switch unit {
        case "TB": multiplier = pow(1024, 4)
        case "GB": multiplier = pow(1024, 3)
        case "MB": multiplier = pow(1024, 2)
        case "KB": multiplier = 1024
        case "B", "": multiplier = 1
        default: multiplier = 0
        }
        return Int64(value * multiplier)
    }
}
