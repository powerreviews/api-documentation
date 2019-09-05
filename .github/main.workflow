workflow "deploy help site" {
  on = "push"
  resolves = ["deploy"]
}

action "is-master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "deploy" {
  needs = "is-master"
  uses = "actions/aws/cli@master"
  args = "s3 sync . s3://developers.powerreviews.com/ --storage-class REDUCED_REDUNDANCY --delete"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}