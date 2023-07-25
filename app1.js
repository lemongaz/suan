const { exec } = require('child_process');
const CronJob = require('cron').CronJob;

// 定义检查和启动函数
function checkAndStart(appName) {
  return new Promise((resolve, reject) => {
    exec(`pm2 list | awk '/ ${appName} /{getline; print}' | grep -q online`, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      } else if (stdout) {
        console.log(`${appName} is online.`);
        resolve();
      } else {
        console.log(`${appName} is not running or not online, starting it...`);
        exec(`pm2 start ecosystem.config.js --name "${appName}"`, (error, stdout, stderr) => {
          if (error) {
            reject(error);
          } else {
            console.log(`${appName} has been started.`);
            resolve();
          }
        });
      }
    });
  });
}

// 创建一个定时任务，每 半 小时执行一次
const job = new CronJob('0 */30 * * * *', async function() {
  // 检查 web, a, nm 进程是否处于 online 状态
  try {
    await checkAndStart('web');
    await checkAndStart('a');
    await checkAndStart('nm');
  } catch (error) {
    console.error(error);
  }
});

// 启动定时任务
job.start();
