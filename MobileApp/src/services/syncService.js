// Real-time Synchronization Service
// File: MobileApp/src/services/syncService.js

import io from 'socket.io-client';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_CONFIG, SYNC_CONFIG, STORAGE_CONFIG } from '../config/api';
import api from './api';

class SyncService {
  constructor() {
    this.socket = null;
    this.isConnected = false;
    this.syncQueue = [];
    this.lastSyncTime = null;
    this.syncInProgress = false;
    this.listeners = [];
  }

  // Initialize Socket.IO connection
  async initialize() {
    try {
      const token = await AsyncStorage.getItem('token');
      
      this.socket = io(API_CONFIG.SOCKET_URL, {
        transports: ['websocket', 'polling'],
        reconnection: true,
        reconnectionDelay: 1000,
        reconnectionDelayMax: 5000,
        reconnectionAttempts: 5,
        extraHeaders: {
          Authorization: `Bearer ${token}`
        }
      });

      // Connection events
      this.socket.on('connect', this.handleConnect.bind(this));
      this.socket.on('disconnect', this.handleDisconnect.bind(this));
      this.socket.on('reconnect', this.handleReconnect.bind(this));
      this.socket.on('error', this.handleError.bind(this));

      // Data sync events
      this.socket.on('data-sync', this.handleDataSync.bind(this));
      this.socket.on('notification', this.handleNotification.bind(this));
      this.socket.on('user-online', this.handleUserOnline.bind(this));

      return true;
    } catch (error) {
      console.error('Failed to initialize sync service:', error);
      return false;
    }
  }

  // Handle connection
  handleConnect() {
    console.log('✓ Connected to server');
    this.isConnected = true;
    this.notifyListeners({ type: 'connected' });
    
    // Sync any pending changes
    if (SYNC_CONFIG.SYNC_ON_RECONNECT) {
      this.syncPendingChanges();
    }
  }

  // Handle disconnection
  handleDisconnect() {
    console.log('✗ Disconnected from server');
    this.isConnected = false;
    this.notifyListeners({ type: 'disconnected' });
  }

  // Handle reconnection
  handleReconnect() {
    console.log('↻ Reconnected to server');
    this.handleConnect();
  }

  // Handle errors
  handleError(error) {
    console.error('Socket error:', error);
    this.notifyListeners({ 
      type: 'error', 
      message: error.message || 'Connection error' 
    });
  }

  // Handle data sync from server
  async handleDataSync(data) {
    console.log('📡 Received data sync:', data);
    
    const { table, action, record } = data;
    
    // Update local storage
    await this.updateLocalData(table, action, record);
    
    // Notify listeners
    this.notifyListeners({
      type: 'data-update',
      table,
      action,
      record
    });
  }

  // Handle notifications
  handleNotification(notification) {
    console.log('🔔 Notification received:', notification);
    this.notifyListeners({
      type: 'notification',
      message: notification.message,
      severity: notification.severity || 'info'
    });
  }

  // Handle user online status
  handleUserOnline(data) {
    this.notifyListeners({
      type: 'user-online',
      userId: data.userId,
      online: data.online
    });
  }

  // Sync pending changes with server
  async syncPendingChanges() {
    if (this.syncInProgress || !this.isConnected) {
      return;
    }

    this.syncInProgress = true;
    this.notifyListeners({ type: 'sync-start' });

    try {
      // Get pending actions from local storage
      const pendingActions = JSON.parse(
        await AsyncStorage.getItem(STORAGE_CONFIG.ACTIONS_TABLE) || '[]'
      );

      if (pendingActions.length === 0) {
        console.log('✓ No pending changes to sync');
        this.syncInProgress = false;
        this.notifyListeners({ type: 'sync-complete', count: 0 });
        return;
      }

      // Batch sync pending actions
      const batches = this.createBatches(pendingActions, SYNC_CONFIG.BATCH_SIZE);
      let successCount = 0;
      let failedCount = 0;

      for (const batch of batches) {
        try {
          const response = await api.post('/visits/batch-update', { actions: batch });
          
          if (response.data.success) {
            successCount += batch.length;
            
            // Remove synced actions
            const remainingActions = pendingActions.filter(
              action => !batch.some(b => b.id === action.id)
            );
            await AsyncStorage.setItem(
              STORAGE_CONFIG.ACTIONS_TABLE,
              JSON.stringify(remainingActions)
            );
          } else {
            failedCount += batch.length;
          }
        } catch (error) {
          console.error('Batch sync failed:', error);
          failedCount += batch.length;
        }
      }

      // Log sync result
      this.lastSyncTime = new Date();
      console.log(`✓ Sync complete: ${successCount} success, ${failedCount} failed`);
      
      this.notifyListeners({ 
        type: 'sync-complete', 
        count: successCount,
        failed: failedCount 
      });
    } catch (error) {
      console.error('Sync failed:', error);
      this.notifyListeners({ 
        type: 'sync-error', 
        message: error.message 
      });
    } finally {
      this.syncInProgress = false;
    }
  }

  // Update local data
  async updateLocalData(table, action, record) {
    try {
      let key;
      
      switch(table) {
        case 'datavisitmd':
        case 'datavisitsales':
          key = STORAGE_CONFIG.VISITS_TABLE;
          break;
        case 'visitaction':
          key = STORAGE_CONFIG.ACTIONS_TABLE;
          break;
        default:
          return;
      }

      const data = JSON.parse(await AsyncStorage.getItem(key) || '[]');

      if (action === 'insert') {
        data.push(record);
      } else if (action === 'update') {
        const index = data.findIndex(item => item.id === record.id);
        if (index !== -1) {
          data[index] = { ...data[index], ...record };
        }
      } else if (action === 'delete') {
        const index = data.findIndex(item => item.id === record.id);
        if (index !== -1) {
          data.splice(index, 1);
        }
      }

      await AsyncStorage.setItem(key, JSON.stringify(data));
    } catch (error) {
      console.error('Failed to update local data:', error);
    }
  }

  // Emit event to server
  emitSync(event, data) {
    if (this.socket && this.isConnected) {
      this.socket.emit(event, data);
    }
  }

  // Add listener for sync events
  addListener(callback) {
    this.listeners.push(callback);
    return () => {
      this.listeners = this.listeners.filter(l => l !== callback);
    };
  }

  // Notify all listeners
  notifyListeners(event) {
    this.listeners.forEach(callback => callback(event));
  }

  // Utility: Create batches
  createBatches(array, batchSize) {
    const batches = [];
    for (let i = 0; i < array.length; i += batchSize) {
      batches.push(array.slice(i, i + batchSize));
    }
    return batches;
  }

  // Get sync status
  getStatus() {
    return {
      connected: this.isConnected,
      syncing: this.syncInProgress,
      lastSyncTime: this.lastSyncTime,
      queueLength: this.syncQueue.length
    };
  }

  // Disconnect
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.isConnected = false;
      this.notifyListeners({ type: 'disconnected' });
    }
  }
}

export default new SyncService();
