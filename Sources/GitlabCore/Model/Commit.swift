/*
 Copyright 2021 macoonshine
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public struct Commit: Entity {
    public struct Info: Record {
        public let message: String?
        public let error_code: String?
        public let dry_run: String?
    }
    public let id: String
    public let short_id: String
    public let title: String
    public let author_name: String
    public let author_email: String
    public let created_at: Timestamp
    public let message: String
    public let parent_ids: [String]?
    public let web_url: URL
}
