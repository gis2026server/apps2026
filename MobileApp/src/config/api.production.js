// Production Configuration for Mobile App
// File: MobileApp/src/config/api.js

// API Configuration - Production
export const API_CONFIG = {
  // Main API server endpoint
  API_BASE_URL: 'https://api.gisconnect.online/api',
  
  // WebSocket server for real-time sync
  SOCKET_URL: 'https://api.gisconnect.online',
  
  // Request timeout (30 seconds)
  TIMEOUT: 30000,
  
  // Retry configuration
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 2000,
  
  // Maximum retry delay (exponential backoff)
  MAX_RETRY_DELAY: 30000
};

// Application metadata
export const APP_VERSION = '1.0.0';
export const APP_NAME = 'GIS Connect Field App';
export const ENVIRONMENT = 'production';

// Feature flags
export const FEATURES = {
  OFFLINE_MODE: true,           // Allow offline data entry
  AUTO_SYNC: true,              // Auto-sync every 30 seconds
  PUSH_NOTIFICATIONS: true,     // Show sync notifications
  GPS_TRACKING: true,           // Enable GPS tracking
  PHOTO_CAPTURE: true,          // Enable camera
  EXPORT_REPORTS: true          // Export to CSV/Excel
};

// GPS Configuration
export const GPS_CONFIG = {
  ACCURACY: 10,                 // 10 meters accuracy
  UPDATE_INTERVAL: 5000,        // Update every 5 seconds
  TIMEOUT: 10000,               // 10 second timeout
  MAX_AGE: 5000                 // Max age of position
};

// Local storage configuration
export const STORAGE_CONFIG = {
  VISITS_TABLE: '@gis_visits',
  ACTIONS_TABLE: '@gis_actions',
  USER_TABLE: '@gis_user',
  SYNC_LOG_TABLE: '@gis_synclog'
};

// Sync configuration
export const SYNC_CONFIG = {
  AUTO_SYNC_INTERVAL: 30000,    // Auto-sync every 30 seconds
  SYNC_ON_STARTUP: true,        // Sync when app starts
  SYNC_ON_RECONNECT: true,      // Sync when connection restored
  BATCH_SIZE: 50,               // Upload 50 records per batch
  RETRY_INTERVAL: 5000          // Retry after 5 seconds
};

// Camera configuration
export const CAMERA_CONFIG = {
  QUALITY: 0.8,                 // JPEG quality (0-1)
  RATIO: '4:3',                 // Aspect ratio
  MAX_SIZE: 5242880,            // 5MB max
  MIRROR: false                 // Don't mirror selfie cam
};

// UI Configuration
export const UI_CONFIG = {
  THEME: 'dark',
  PRIMARY_COLOR: '#1976d2',
  SECONDARY_COLOR: '#dc004e',
  TOUCH_TARGET_MIN: 44          // iOS minimum (points)
};

// Error handling
export const ERROR_CONFIG = {
  SHOW_STACK_TRACE: false,      // Hide stack trace in production
  LOG_ERRORS: true,             // Log errors to server
  NOTIFY_ERRORS: true           // Show error notifications
};

// Security configuration
export const SECURITY_CONFIG = {
  HTTPS_ONLY: true,
  TOKEN_STORAGE: 'secure',      // Use secure storage for token
  TOKEN_REFRESH: true,          // Auto-refresh token before expiry
  CERTIFICATE_PINNING: false    // Optional: enable for extra security
};

export default {
  API_CONFIG,
  APP_VERSION,
  APP_NAME,
  ENVIRONMENT,
  FEATURES,
  GPS_CONFIG,
  STORAGE_CONFIG,
  SYNC_CONFIG,
  CAMERA_CONFIG,
  UI_CONFIG,
  ERROR_CONFIG,
  SECURITY_CONFIG
};
