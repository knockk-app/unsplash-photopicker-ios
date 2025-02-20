//
//  UnsplashPhoto.swift
//  Submissions
//
//  Created by Olivier Collet on 2017-04-10.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

/// A struct representing a photo from the Unsplash API.
public struct UnsplashPhoto: Codable {

    public enum URLKind: String, Codable {
        case raw
        case full
        case regular
        case small
        case thumb
    }

    public enum LinkKind: String, Codable {
        case own = "self"
        case html
        case download
        case downloadLocation = "download_location"
    }

    public let identifier: String
    public let height: Int
    public let width: Int
    public let color: UIColor?
    public let exif: UnsplashPhotoExif?
    public let user: UnsplashUser?
    public let urls: [URLKind: URL]
    public let links: [LinkKind: URL]
    public let likesCount: Int
    public let downloadsCount: Int?
    public let viewsCount: Int?

    public func json() -> [String: Any] {
        var data: [String: Any] = [
            "id": self.identifier,
            "height": self.height,
            "width": self.width,
            "likes": self.likesCount
        ]

        if let user = self.user {
            data["user"] = user.json()
        }


        if let color = self.color {
            data["color"] = "#\(color.hexString)"
        }

        if let exif = self.exif {
            data["exif"] = exif.json()
        }

        if let downloadsCount = self.downloadsCount {
            data["downloads"] = downloadsCount
        }

        if let views = self.viewsCount {
            data["views"] = views
        }

        var u: [String: String] = [:]
        for (_, value) in self.urls.enumerated() {
            u[value.key.rawValue] = value.value.absoluteString
        }
        data["urls"] = u

        var l: [String: String] = [:]
        for (_, value) in self.links.enumerated() {
            l[value.key.rawValue] = value.value.absoluteString
        }
        data["links"] = l

        return data
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case height
        case width
        case color
        case exif
        case user
        case urls
        case links
        case likesCount = "likes"
        case downloadsCount = "downloads"
        case viewsCount = "views"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        height = try container.decode(Int.self, forKey: .height)
        width = try container.decode(Int.self, forKey: .width)

        if let hexString = try? container.decode(String.self, forKey: .color) {
            color = UIColor(hexString: hexString)
        } else {
            color = nil
        }

        exif = try? container.decode(UnsplashPhotoExif.self, forKey: .exif)
        user = try? container.decode(UnsplashUser.self, forKey: .user)
        urls = try container.decode([URLKind: URL].self, forKey: .urls)
        links = try container.decode([LinkKind: URL].self, forKey: .links)
        likesCount = (try? container.decode(Int.self, forKey: .likesCount)) ?? 0
        downloadsCount = try? container.decode(Int.self, forKey: .downloadsCount)
        viewsCount = try? container.decode(Int.self, forKey: .viewsCount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(height, forKey: .height)
        try container.encode(width, forKey: .width)
        try? container.encode(color?.hexString, forKey: .color)
        try? container.encode(exif, forKey: .exif)
        try container.encode(user, forKey: .user)
        try container.encode(urls.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .urls)
        try container.encode(links.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .links)
        try container.encode(likesCount, forKey: .likesCount)
        try? container.encode(downloadsCount, forKey: .downloadsCount)
        try? container.encode(viewsCount, forKey: .viewsCount)
    }

}
