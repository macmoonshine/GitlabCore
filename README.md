# GitlabCore

a small Swift library to the Gitlab API. The API are executed via `URLSession` and Combine Publishers.

**Note:** Currently, GitlabCore only contains the most important basic functions for api access. However, further functions and object structs can easily be added. This can be done both outside and inside the library.

## Structure

Besides the [Gitlab](Sources/GitlabCore/Gitlab.swift) class, this library contains two main class hierarchies:

* The api classes contain functions to access the Gitlab api.
* Model classes describe objects which are returned by the api.

### Parameters

Many API functions in Gitlab support a wide range of parameters. It makes less sense to map all parameters directly into methods of GitlabCore. Therefore, many parameters are mapped as generic parameters via a dictionary. Basically, the following rules were used for the method parameters:

* Required parameters are represented by direct parameters, e. g. `MergeRequests.create(source: String, target: String, title: String, _ parameters: Parameters = [:])`.
* For API functions with few parameters, all parameters are specified directly, e. g. `Commits.cherryPick(commit: String, into branch: String, dryRun: Bool = false, message: String? = nil)`.
* All other parameters are given as generic parameters.

## Installation

you can include GitlabCore in your Xcode project via _File_ | _Swift Packages_ | _Add Package Dependencies..._. In the first step of the wizard use the URL [https://github.com/macmoonshine/GitlabCore](https://github.com/macmoonshine/GitlabCore), press _Next_ and following the remaining steps of the wizard.

## Setup

The setup for accessing a Gitlab repository is very simple. You need the following data:

* The URL to the Gitlab repository. This is for example https://gitlab.com/api/v4 if you use the public repository of Gitlab.
* You also need to create an _Access Token_ for yourself via the web interface under Profile of the Gitlab repository. For https://gitlab.com you can find this page at [https://gitlab.com/-/profile/personal\_access\_tokens](https://gitlab.com/-/profile/personal_access_tokens). You should at least select the scopes _api_ and _read\_repository_ for the token.

With the URL and the token you can create a new [Gitlab](Sources/GitlabCore/Gitlab.swift) object.

```
import GitlabCore

let url = "..."
let token = "..."
if let gitlab = Gitlab(url, token: token) {
    ...
}
```

## Examples

Projects are a basis for many operations. You can fetch a single object by its id with the following code:

```
let cancellable = gitlab.projects.get(id: 1234)
    .sink(receiveCompletion: {error in
        // handle error
    }) {project in
        // do something with project
    }
```
But often you don't know the id of the project but only its name. With this code you can get a project by its name:

```
let cancellable = gitlab.projects.list([ "search": "MyProject"])
    .sink(receiveCompletion: {error in
        // handle error
    }) {projects in
        // do something with first project in projects
    }
```
This looks a little bit complicate to just making one api call. But for multiple, consecutive calls, the advantages of Combine come into play. For example, if you want to create a new branch in a project, you can do the following:

```
let cancellable = gitlab.projects.list([ "search": "MyProject"])
    .flatMap { projects -> Branches.Publisher in
        return self.gitlab.branches(for: projects[0])
            .create(name: "newTestBranch", 
               reference: "main")
    }
    .sink(...)
```
This can be done in several steps, e.g. create a merge request and rebase it:

```
let cancellable = gitlab.projects.list([ "search": "MyProject"])
    .flatMap { projects -> MergeRequests.Publisher in
        return self.gitlab.mergeRequests(for: projects[0])
            .create(source: "main", target: "staging", title: "Merge main to staging")
    }
    .flatMap { mergeRequest -> MergeRequests.RebaseResponsePublisher in
        return self.gitlab.mergeRequests
            .rebase(mergeRequest: mergeRequest, skipCI: true)
    }
    .sink(receiveCompletion: {error in
   		  // handle error
    }) {response in
        if response.rebase_in_progress {
            print("Rebase in progress")
        }
        else if let message = response.error_message {
            print("Rebase failed with error: \(message).")
        }
        else {
            print("Rebase succeeded and finished.")
        }
    }
```

## License

Copyright 2021 macoonshine

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
