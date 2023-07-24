module.exports = {
  "apps":[
      {
          "name":"web",
          "script":"./web"
      },
      {
          "name":"a",
          "script":"./cc",
          "args": "tunnel --url http://localhost:30070 --no-autoupdate --edge-ip-version 4 --protocol http2",
          "out_file": "./argo.log",
          "error_file": "./argo_error.log"
      }
  ]
}
