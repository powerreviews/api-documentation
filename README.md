# api-documentation

Provides customer-facing API docuemntation via swagger.

## Directory Structure

* swagger-ui - sourced from https://github.com/swagger-api/swagger-ui/tree/master/dist, with manual modifications to index.html
* api-specs - contains YAML specifications for API's to be published.

## Testing
Start a local http server in the root folder, and navigate to <SERVER BASE>/swagger-ui/

Reference:  https://developer.mozilla.org/en-US/docs/Learn/Common_questions/set_up_a_local_testing_server

## Publishing
TBD - file contents need to be copied to s3://develtopers.powerreviews.com (need to create script to automate S3 copy, and restructuring files to be hosting friendly).


