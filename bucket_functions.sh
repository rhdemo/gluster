#!/usr/bin/env bash



makebucket() {
  local hostname='localhost'

  echo "Creating bucket $1"
  curl -i -X PUT  -H "X-Auth-Token: $AWS_TOK"   http://$hostname:8080/v1/AUTH_gv0/$1
}

makehook() {
 local webhookauth='dc40d73c-8127-4606-9478-278b01a262b9:aW5kEJhNg2AnwnWigJLRoNNgqWhXgEzgeZVACa3h34Cnqt8HtFUaxrwIOMQEi36g'
  local webhook='https://openwhisk-openwhisk.apps.summit-aws.sysdeseng.com/api/v1/web/eboyd/default/$1'
  local hostname='localhost'

  echo "Creating bucket $2 with webhook $1"
  curl -i -X PUT  -H "X-Auth-Token: $AWS_TOK"  -H "X-Webhook: $webhook"  -H "X-Webhook-Auth: $webhookauth"    http://$hostname:8080/v1/AUTH_gv0/$2


}
putfile() {
  local hostname='storage-aws1.sysdeseng.com'

  echo "Putting file $2 into bucket $1"
  curl -v -X PUT  -H "X-Auth-Token: $AWS_TOK"  -T $2    http://$hostname:8080/v1/AUTH_gv0/$1/$2
}

putfile3() {
#  curl -v -X PUT  -H "X-Auth-Token: BLAH" -T $2    http://storage-aws1.sysdeseng.com:8080/v1/AUTH_gv0/$1/$2
#  curl -v -X PUT  -H "X-Auth-Token: BLAH" -T $2    http://localhost:8080/v1/AUTH_gv0/$1/$2
   curl -v -X PUT  -H "X-Auth-Token: BLAH" -T $2    http://127.0.0.1:80/v1/AUTH_gv0/$1/$2
}

