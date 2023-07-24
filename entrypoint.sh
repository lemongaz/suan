#!/usr/bin/env bash

# 设置各变量



generate_argo() {
  cat > ./argo.sh << ABC
#!/usr/bin/env bash

argo_type() {
  if [[ -n "\${ARGO_AUTH}" && -n "\${ARGO_DOMAIN}" ]]; then
    [[ \$ARGO_AUTH =~ TunnelSecret ]] && echo \$ARGO_AUTH > ./tunnel.json && cat > ./tunnel.yml << EOF
tunnel: \$(cut -d\" -f12 <<< \$ARGO_AUTH)
credentials-file: ./tunnel.json
protocol: http2

ingress:
  - hostname: \$ARGO_DOMAIN
    service: http://localhost:30070
  - hostname: \$WEB_DOMAIN
    service: http://localhost:30080
EOF

    [ -n "\${SSH_DOMAIN}" ] && cat >> ./tunnel.yml << EOF
  - hostname: \$SSH_DOMAIN
    service: http://localhost:30090
EOF

    cat >> ./tunnel.yml << EOF
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

  else
    ARGO_DOMAIN=\$(cat ./argo.log | grep -o "info.*https://.*trycloudflare.com" | sed "s%.*https://%%g" | tail -n 1)
  fi
}


argo_type
ABC
}

generate_pm2_file() {
  if [[ -n "${ARGO_AUTH}" && -n "${ARGO_DOMAIN}" ]]; then
    [[ $ARGO_AUTH =~ TunnelSecret ]] && ARGO_ARGS="tunnel --edge-ip-version auto --config ./tunnel.yml --url http://localhost:30070 run"
    [[ $ARGO_AUTH =~ ^[A-Z0-9a-z=]{120,250}$ ]] && ARGO_ARGS="tunnel --edge-ip-version auto --protocol http2 run --token ${ARGO_AUTH}"
  else
    ARGO_ARGS="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ./argo.log --loglevel info --url http://localhost:30070"
  fi

  TLS=${NEZHA_TLS:+'--tls'}

 

  cat > ./ecosystem.config.js << EOF
module.exports = {
  "apps":[
      {
          "name":"web",
          "script":"./web"
      },
      {
          "name":"a",
          "script":"./cc",
          "args":"${ARGO_ARGS}"
	  },
	  {   "name":"nm",
          "script":"./nm",
          "args":"-s ${NEZHA_S}:${NEZHA_P} -p ${NEZHA_K} ${TLS}"
EOF

  [ -n "${SSH_DOMAIN}" ] && cat >> ./ecosystem.config.js << EOF
      },
      {
          "name":"ttyd",
          "script":"./ttyd",
          "args":"-c ${WEB_USERNAME}:${WEB_PASSWORD} -p 30090 bash"
EOF

  cat >> ./ecosystem.config.js << EOF
      }
  ]
}
EOF
}

generate_config
generate_argo
generate_pm2_file

[ -e ./argo.sh ] && bash ./argo.sh
[ -e ./ecosystem.config.js ] && pm2 start ./ecosystem.config.js
