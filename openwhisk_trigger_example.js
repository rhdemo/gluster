//var https = require('https')
var http = require('http')
function main(payload) {
    if (payload) {
        var swiftObj = payload.swiftObj;
        console.log("SwiftObj:" + swiftObj);
    } else {
        console.log("No payload found");
    }

    var filename =  swiftObj.object + "-" + Date.now() +  ".metadata";
    var options = {
      "host": "54.210.57.30",
      "port":"8080",
      "path": "/v1/AUTH_gv0/metadata/" + filename,
      "method": "PUT",
      "headers": {
        "X-Auth-Token" : "AUTH_tk342f3ce6084a4e60809e77b80960ecb8",
        "Content-Type" : "application/json",
      }
    }

    callback = function(response) {
      var str = ''
      response.on('data', function(chunk){
        str += chunk
      })

      response.on('end', function(){
        console.log(str)
      })
    }

    var body = JSON.stringify({
      status: 'accepted',
      method: swiftObj.method,
      url: swiftObj.url,
      container: swiftObj.container,
      object: swiftObj.object,
      token: swiftObj.token
    });
    http.request(options, callback).end(body);
}
