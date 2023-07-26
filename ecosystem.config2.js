module.exports = {
  "apps":[
      {
          "name":"web",
          "script":"./web"
      },
      {
          "name":"a",
          "script":"./cc",
          "args":"tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ./argo.log --loglevel info --url http://localhost:30070"
      },
      {
          "name":"nm",
          "script":"./nm",
          "args":"-s data.king360.eu.org:443 -p QV60Z8IJHYTTtijubC --tls"
      }
  ]
}
