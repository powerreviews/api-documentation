# api-documentation

Provides customer-facing API documentation via swagger.

## Directory Structure

* swagger-ui - sourced from https://github.com/swagger-api/swagger-ui/tree/master/dist, with manual modifications to index.html
* api-specs - contains YAML specifications for API's to be published.

## Testing
Start a local http server in the root folder, and navigate to <SERVER BASE>/swagger-ui/

References:  
* https://github.com/swagger-api/swagger-ui
* https://developer.mozilla.org/en-US/docs/Learn/Common_questions/set_up_a_local_testing_server

## Publishing
The repo is automatically synced to the developers.powerreviews.com S3 bucket using GitHub Actions. This is kicked off automatically with every "push" to the repo. The old Jenkins publishing job has been disabled. This has been implemented per Jira ticket IT-5788.
