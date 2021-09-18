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

open class Users: API<User> {
    /**
     creates a new api for users.
     */
    public init(gitlab: Gitlab) {
        super.init(gitlab: gitlab, basePath: "/users")
    }
}

public extension Gitlab {
    /**
     creates a new api for users.
     */
    var users: Users {
        return Users(gitlab: self)
    }
}
