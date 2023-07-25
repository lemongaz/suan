#!/usr/bin/env bash

# 定义检查和启动函数
check_and_start() {
  local APP_NAME=$1
  if ! pm2 list | awk '/ '${APP_NAME}' /{getline; print}' | grep -q online; then
    echo "${APP_NAME} is not running or not online, starting it..."
    pm2 start ecosystem.config.js --name "${APP_NAME}"
  else
    echo "${APP_NAME} is online."
  fi
}

# 检查 web, a, nm 进程是否处于 online 状态
check_and_start "web"
check_and_start "a"
check_and_start "nm"
