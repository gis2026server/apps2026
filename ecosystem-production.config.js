/**
 * PM2 Ecosystem Configuration for GIS2026 Backend
 * Location: /home/www/gisconnect.online/ecosystem.config.js
 * Usage: pm2 start ecosystem.config.js
 */

module.exports = {
  apps: [
    {
      // Application name
      name: 'gis2026-server',
      
      // Script path
      script: './server/index.js',
      
      // Working directory
      cwd: '/home/www/gisconnect.online',
      
      // ============================
      // CLUSTERING CONFIGURATION
      // ============================
      instances: 4,              // Number of worker instances
      exec_mode: 'cluster',      // Clustering mode for better load distribution
      
      // ============================
      // ENVIRONMENT
      // ============================
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '0.0.0.0'
      },
      
      // ============================
      // LOGGING
      // ============================
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,          // Merge logs from all instances
      
      // ============================
      // PROCESS MANAGEMENT
      // ============================
      min_uptime: '10s',         // Minimum uptime before restart
      max_restarts: 10,          // Max restarts per min
      restart_delay: 4000,       // Wait time before restart (ms)
      
      // ============================
      // MEMORY MANAGEMENT
      // ============================
      max_memory_restart: '1G',  // Restart if memory exceeds 1GB
      
      // ============================
      // WATCH MODE (development only - disable in production)
      // ============================
      watch: false,              // Don't watch files in production
      
      // ============================
      // GRACEFUL SHUTDOWN
      // ============================
      wait_ready: true,          // Wait for ready message
      listen_timeout: 5000,      // Max time to wait for app to be ready
      kill_timeout: 5000,        // Max time to wait before force kill
      shutdown_with_message: true, // Allow graceful shutdown
      
      // ============================
      // MONITORING
      // ============================
      ignore_watch: ['node_modules', 'logs', 'database', 'uploads', '.git'],
      
      // ============================
      // AUTO-RESTART CONDITIONS
      // ============================
      autorestart: true,         // Auto restart on crash
      
      // ============================
      // OTHER OPTIONS
      // ============================
      node_args: '--max-old-space-size=512', // Node.js arguments
      
      // Custom metadata
      instances_per_core: 1,
      
      // Cron restart (e.g., every day at 2:00 AM)
      // cron_restart: '0 2 * * *',  // Uncomment to enable
    }
  ],
  
  // ============================
  // DEPLOY CONFIGURATION (Optional)
  // ============================
  deploy: {
    production: {
      user: 'root',
      host: '192.168.0.169',
      ref: 'origin/main',
      repo: 'git@github.com:gis2026server/apps2026.git',
      path: '/home/www/gisconnect.online',
      'pre-deploy-local': '',
      'post-deploy': 'npm install --production && npm run build && pm2 startOrRestart ecosystem.config.js',
      'pre-deploy': 'echo "Deploying to production"'
    }
  }
};

/**
 * USAGE INSTRUCTIONS
 * 
 * Start application:
 *   pm2 start ecosystem.config.js
 * 
 * Stop application:
 *   pm2 stop gis2026-server
 * 
 * Restart application:
 *   pm2 restart gis2026-server
 * 
 * Delete from PM2 list:
 *   pm2 delete gis2026-server
 * 
 * View logs:
 *   pm2 logs gis2026-server
 * 
 * Monitor resources:
 *   pm2 monit
 * 
 * Setup startup script:
 *   pm2 startup
 *   pm2 save
 * 
 * Disable startup script:
 *   pm2 unstartup
 * 
 * Graceful reload (zero downtime):
 *   pm2 gracefulReload gis2026-server
 * 
 * View application details:
 *   pm2 show gis2026-server
 * 
 * View all applications:
 *   pm2 list
 */
