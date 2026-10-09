module.exports = {
  apps: [
    {
      name: "home-automation",
      script: "./server.exe",
      cwd: "./backend",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "300M",
      env: {
        PORT: 3000
      },
      error_file: "./logs/pm2-error.log",
      out_file: "./logs/pm2-out.log",
      time: true
    }
  ]
};
