import Foundation
import RequestKit
import OctoKit

/// https://docs.github.com/en/rest/reference/repos#list-repository-tags
public extension Octokit {
    /**
     Returns list of commits
     
     - seealso: [Documentation] (https://docs.github.com/en/rest/reference/repos#list-commits)
     */
    @discardableResult
    func tags(_ session: RequestKitURLSession = URLSession.shared,
              owner: String,
              repository: String,
              completion: @escaping (_ response: Response<[Tag]>) -> Void) -> URLSessionDataTaskProtocol? {
        
        let router = TagsRouter.tags(configuration, owner: owner, repo: repository)
        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: [Tag].self) { statuses, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let statuses = statuses {
                    completion(.success(statuses))
                }
            }
        }
    }
}

enum TagsRouter: JSONPostRouter {
    case tags(Configuration, owner: String, repo: String)
    
    var method: HTTPMethod {
        switch self {
        case .tags:
            return .GET
        }
    }
    
    var encoding: HTTPEncoding {
        switch self {
        case .tags:
            return .json
        }
    }
    
    var configuration: Configuration {
        switch self {
        case .tags(let config, _, _):
            return config
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .tags:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .tags(_, let owner, let repo):
            return "repos/\(owner)/\(repo)/tags"
        }
    }
}

public struct Tag: Codable {
    let name: String
}

//[
//    {
//        "name": "v0.1",
//        "commit": {
//            "sha": "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc",
//            "url": "https://api.github.com/repos/octocat/Hello-World/commits/c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc"
//        },
//        "zipball_url": "https://github.com/octocat/Hello-World/zipball/v0.1",
//        "tarball_url": "https://github.com/octocat/Hello-World/tarball/v0.1",
//        "node_id": "MDQ6VXNlcjE="
//    }
//]


