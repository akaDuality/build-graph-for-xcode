import Foundation
import RequestKit
import OctoKit



public extension Octokit {
    /**
     Returns list of commits
     
     - seealso: [Documentation] (https://docs.github.com/en/rest/reference/repos#list-commits)
     */
    @discardableResult
    func listCommits(_ session: RequestKitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     completion: @escaping (_ response: Response<[Commit]>) -> Void) -> URLSessionDataTaskProtocol? {
        
        let router = CommitsRouter.listCommits(configuration, owner: owner, repo: repository)
        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: [Commit].self) { statuses, error in
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


// MARK: - Router

enum CommitsRouter: JSONPostRouter {
    case listCommits(Configuration, owner: String, repo: String)
    
    var method: HTTPMethod {
        switch self {
        case .listCommits:
            return .GET
        }
    }
    
    var encoding: HTTPEncoding {
        switch self {
        case .listCommits:
            return .json
        }
    }
    
    var configuration: Configuration {
        switch self {
        case .listCommits(let config, _, _):
            return config
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .listCommits:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .listCommits(_, let owner, let repo):
            return "repos/\(owner)/\(repo)/commits"
        }
    }
}

public struct Commit: Codable {
    let sha: String
    
    let commit: CommitInfo
}

public struct CommitInfo: Codable {
    let author: Author
    let committer: Author
    let message: String
    
    struct Author: Codable {
        let name: String
        let email: String
        let date: Date
    }
}


//[
//    {
//        "url": "https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e",
//        "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e",
//        "node_id": "MDY6Q29tbWl0NmRjYjA5YjViNTc4NzVmMzM0ZjYxYWViZWQ2OTVlMmU0MTkzZGI1ZQ==",
//        "html_url": "https://github.com/octocat/Hello-World/commit/6dcb09b5b57875f334f61aebed695e2e4193db5e",
//        "comments_url": "https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e/comments",
//        "commit": {
//            "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e",
//            "author": {
//                "name": "Monalisa Octocat",
//                "email": "support@github.com",
//                "date": "2011-04-14T16:00:49Z"
//            },
//            "committer": {
//                "name": "Monalisa Octocat",
//                "email": "support@github.com",
//                "date": "2011-04-14T16:00:49Z"
//            },
//            "message": "Fix all the bugs",
//            "tree": {
//                "url": "https://api.github.com/repos/octocat/Hello-World/tree/6dcb09b5b57875f334f61aebed695e2e4193db5e",
//                "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e"
//            },
//            "comment_count": 0,
//            "verification": {
//                "verified": false,
//                "reason": "unsigned",
//                "signature": null,
//                "payload": null
//            }
//        },
//        "author": {
//            "login": "octocat",
//            "id": 1,
//            "node_id": "MDQ6VXNlcjE=",
//            "avatar_url": "https://github.com/images/error/octocat_happy.gif",
//            "gravatar_id": "",
//            "url": "https://api.github.com/users/octocat",
//            "html_url": "https://github.com/octocat",
//            "followers_url": "https://api.github.com/users/octocat/followers",
//            "following_url": "https://api.github.com/users/octocat/following{/other_user}",
//            "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
//            "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
//            "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
//            "organizations_url": "https://api.github.com/users/octocat/orgs",
//            "repos_url": "https://api.github.com/users/octocat/repos",
//            "events_url": "https://api.github.com/users/octocat/events{/privacy}",
//            "received_events_url": "https://api.github.com/users/octocat/received_events",
//            "type": "User",
//            "site_admin": false
//        },
//        "committer": {
//            "login": "octocat",
//            "id": 1,
//            "node_id": "MDQ6VXNlcjE=",
//            "avatar_url": "https://github.com/images/error/octocat_happy.gif",
//            "gravatar_id": "",
//            "url": "https://api.github.com/users/octocat",
//            "html_url": "https://github.com/octocat",
//            "followers_url": "https://api.github.com/users/octocat/followers",
//            "following_url": "https://api.github.com/users/octocat/following{/other_user}",
//            "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
//            "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
//            "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
//            "organizations_url": "https://api.github.com/users/octocat/orgs",
//            "repos_url": "https://api.github.com/users/octocat/repos",
//            "events_url": "https://api.github.com/users/octocat/events{/privacy}",
//            "received_events_url": "https://api.github.com/users/octocat/received_events",
//            "type": "User",
//            "site_admin": false
//        },
//        "parents": [
//        {
//        "url": "https://api.github.com/repos/octocat/Hello-World/commits/6dcb09b5b57875f334f61aebed695e2e4193db5e",
//        "sha": "6dcb09b5b57875f334f61aebed695e2e4193db5e"
//        }
//        ]
//    }
//]

