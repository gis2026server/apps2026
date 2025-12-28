# System Architecture Diagram for gisconnect.online

## Complete System Overview

```
                              🌐 INTERNET
                                  |
                    ┌─────────────┴──────────────┐
                    |                            |
              HTTP/HTTPS Port 80/443         Devices
                    |                            |
        ┌───────────▼───────────┐        ┌──────▼──────┐
        │                       │        │              │
        │   NGINX Reverse Proxy │        │  Mobile      │
        │   (Web Server)        │        │  Devices     │
        │                       │        │              │
        │ • Load Balancer       │        │ • iPhone     │
        │ • SSL/TLS (HTTPS)     │        │ • Android    │
        │ • Static Files        │        │ • Tablets    │
        │ • WebSocket           │        │              │
        │                       │        │ Port: HTTPS  │
        └───┬────────┬──────┬───┘        │ (443)        │
            |        |      |           └──────┬────────┘
   ┌────────┘        │      └───────────┐      |
   |                 |                  |      |
   |             Port 3000               |      |
   |                 |                  |      |
   v                 v                  v      v
┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│ Dashboard   │ │  Backend API │ │ API Request  │
│ App         │ │  Server      │ │ (Socket.IO)  │
│             │ │              │ │              │
│ React 18    │ │ Node.js      │ │ Real-time    │
│ Vite Build  │ │ Express      │ │ Sync         │
│             │ │              │ │              │
│ /app/*      │ │ /api/*       │ │ /socket.io   │
│ /           │ │ /health      │ │              │
│ /uploads    │ │ /auth        │ │              │
│             │ │ /visits      │ │              │
│ HTTPS       │ │ /outlets     │ │ WebSocket    │
│ Cached      │ │ /users       │ │ Long Poll    │
│             │ │ /reports     │ │              │
└─────────────┘ └──────┬───────┘ └──────────────┘
                       |
           ┌───────────┴───────────┐
           |                       |
           v                       v
    ┌──────────────┐        ┌────────────────┐
    │ SQLite       │        │ Real-time Sync │
    │ Databases    │        │ Event Queue    │
    │              │        │                │
    │ /databases/  │        │ • Visit Updates│
    │              │        │ • GPS Data     │
    │ • datauser   │        │ • Photos       │
    │ • dataoutlet │        │ • Notifications
    │ • datavisit  │        │                │
    │ • visitaction│        └────────────────┘
    │ • synclog    │
    │              │
    │ File-based   │
    │ Persistent   │
    │ Storage      │
    └──────────────┘
```

## Data Flow Architecture

### 1. **User Login Flow**
```
Mobile App / Dashboard
        |
        | POST /api/auth/login
        | {username, password}
        |
        v
Backend Auth Controller
        |
        | Verify credentials
        | Hash password with bcryptjs
        |
        v
JWT Token Generated
        |
        | {token, user_data}
        |
        v
Client (localStorage)
        |
        | Authorization: Bearer <token>
        v
All subsequent requests
```

### 2. **Field Visit Workflow**
```
Mobile App (Field)
        |
        | 1. Load outlets & visits
        | GET /api/visits?filter=assigned
        |
        v
Backend returns scheduled visits
        |
        | 2. Capture visit action
        | Photos (expo-camera)
        | GPS coordinates (expo-location)
        | Timestamp
        |
        v
Store locally (AsyncStorage)
        |
        | 3. Check-in/Check-out
        | POST /api/visits/{id}/checkin
        | {gps, timestamp, photo}
        |
        v
Backend processes
        |
        | • Save to visitaction table
        | • Broadcast via Socket.IO
        |
        v
Dashboard receives
        |
        | Socket.IO: data-sync event
        |
        v
Dashboard updates in real-time
        |
        | Shows live visit status
        | Updates on map
        | Refreshes visit list
```

### 3. **Real-time Synchronization**
```
Multiple Clients (Dashboard + Mobile)
        |
        |────────────────────────────────────┐
        |                                    |
    Client 1                          Client 2-N
  Dashboard                           Mobile Apps
        |                                    |
        | WebSocket Connection               |
        | (Socket.IO)                        |
        |                                    |
        └────────┬──────────────────────────┘
                 |
                 v
        Backend Socket.IO Server
                 |
     ┌───────────┼───────────┐
     |           |           |
     v           v           v
  Join Room  Emit Event  Broadcast
  "visits"   "data-update"
             {table, action}
                 |
                 v
     ┌──────────────────────┐
     │ Event Broadcasting   │
     │                      │
     │ • Visit created      │
     │ • Visit updated      │
     │ • GPS location       │
     │ • Photos uploaded    │
     │ • User online status │
     └──────────┬───────────┘
                |
     ┌──────────┼──────────┐
     |          |          |
     v          v          v
  Client 1   Client 2   Client N
  (Updates)  (Updates)  (Updates)
  UI State   Data       Data
  refreshes  refetched  refetched
```

## Domain & Subdomain Routing

```
DNS Records (gisconnect.online)
    |
    ├─► gisconnect.online (A Record) ──┐
    ├─► api.gisconnect.online (A)      │ All point to
    ├─► app.gisconnect.online (A)      │ SERVER_IP
    └─► www.gisconnect.online (CNAME)─┘
        
Nginx Virtual Hosts
    |
    ├─► :80 (HTTP) ────────► :443 (HTTPS Redirect)
    |
    ├─► api.gisconnect.online:443
    |   └─► Backend API (localhost:3000)
    |       ├─► /api/* → REST endpoints
    |       ├─► /socket.io → WebSocket
    |       └─► /uploads → File serving
    |
    ├─► app.gisconnect.online:443
    |   └─► Dashboard (React dist/)
    |       ├─► index.html (SPA)
    |       ├─► /js/* → JavaScript chunks
    |       ├─► /css/* → Stylesheets
    |       └─► /assets/* → Images
    |
    └─► gisconnect.online:443
        └─► Root domain (Dashboard)
```

## Deployment Architecture

```
┌──────────────────────────────────────────┐
│        Linux Server (Ubuntu 20.04)       │
│      IP: 123.45.67.89 (example)         │
├──────────────────────────────────────────┤
│                                          │
│ ┌───────────────────────────────────┐   │
│ │ System Services                   │   │
│ │ • systemd (init system)           │   │
│ │ • UFW firewall                    │   │
│ │ • SSH (port 22)                   │   │
│ └───────────────────────────────────┘   │
│                                          │
│ ┌───────────────────────────────────┐   │
│ │ Nginx Web Server                  │   │
│ │ (Reverse Proxy)                   │   │
│ │ Ports: 80 (HTTP), 443 (HTTPS)     │   │
│ │ Config: /etc/nginx/sites-*/       │   │
│ └────────────┬────────────┬─────────┘   │
│              │            │             │
│        ┌─────▼────┐   ┌───▼──────────┐  │
│        │           │   │              │  │
│        │ Port 3000 │   │ Static Files │  │
│        │           │   │              │  │
│        │ Backend   │   │ /var/www/    │  │
│        │ API       │   │ gisconnect/  │  │
│        │           │   │              │  │
│        └────┬──────┘   └──────────────┘  │
│             │                            │
│ ┌───────────▼────────────────────────┐  │
│ │ PM2 Process Manager                │  │
│ │ • Node.js process management      │  │
│ │ • Auto-restart on crash           │  │
│ │ • Cluster mode (multi-core)       │  │
│ │ • Logging & monitoring            │  │
│ │ • Auto-startup (systemd)          │  │
│ └────────┬─────────────────────────┘   │
│          │                              │
│ ┌────────▼──────────────────────────┐  │
│ │ Node.js Application                │  │
│ │ • Express.js server               │  │
│ │ • Socket.IO (real-time)           │  │
│ │ • Database drivers                │  │
│ │ • Authentication (JWT)            │  │
│ │ • File uploads (multer)           │  │
│ │ • Scheduled jobs (node-cron)      │  │
│ └────┬───────────────────────────┬──┘  │
│      │                           │      │
│ ┌────▼──────────────┐ ┌─────────▼────┐ │
│ │ SQLite Databases  │ │ File Storage │ │
│ │ /var/www/         │ │ /var/www/    │ │
│ │ gisconnect/       │ │ gisconnect/  │ │
│ │ databases/        │ │ uploads/     │ │
│ │                   │ │              │ │
│ │ • datauser.db     │ │ • images/    │ │
│ │ • dataoutlet.db   │ │ • reports/   │ │
│ │ • datavisitmd.db  │ │ • exports/   │ │
│ │ • datavisitsales  │ │              │ │
│ │ • visitaction.db  │ │ (persisted)  │ │
│ │ • synclog.db      │ │              │ │
│ │                   │ │              │ │
│ │ (persisted)       │ │              │ │
│ └───────────────────┘ └──────────────┘ │
│                                          │
│ ┌───────────────────────────────────┐  │
│ │ Security & Monitoring             │  │
│ │ • Certbot (SSL certs)            │  │
│ │ • Let's Encrypt (auto-renew)     │  │
│ │ • Logs: /var/log/nginx/          │  │
│ │ • Logs: /var/www/gisconnect/logs │  │
│ │ • Backups: /var/backups/         │  │
│ └───────────────────────────────────┘  │
│                                          │
└──────────────────────────────────────────┘
```

## Mobile App Integration

```
┌────────────────────────────────────┐
│ Mobile Application (React Native)  │
│ • iOS (Expo)                       │
│ • Android (Expo)                   │
├────────────────────────────────────┤
│                                    │
│ ┌──────────────────────────────┐  │
│ │ Navigation Stack             │  │
│ │ • Login Screen               │  │
│ │ • Visits Tab                 │  │
│ │ • Outlets Map                │  │
│ │ • Visit Details              │  │
│ │ • Check-in/Out              │  │
│ │ • Photos                     │  │
│ │ • Sync Status               │  │
│ └──────────────────────────────┘  │
│                                    │
│ ┌──────────────────────────────┐  │
│ │ Services Layer               │  │
│ │ • API Client (axios)         │  │
│ │ • WebSocket (Socket.IO)      │  │
│ │ • Location (expo-location)   │  │
│ │ • Camera (expo-camera)       │  │
│ │ • Storage (AsyncStorage)     │  │
│ │ • Notifications              │  │
│ └────────┬─────────────────────┘  │
│          │                        │
│          ├─────────────────────┬──┤
│          │                     │  │
│   ┌──────▼────────┐    ┌───────▼──────────┐
│   │ HTTP Requests │    │ WebSocket Events │
│   │ (REST API)    │    │ (Real-time sync) │
│   │               │    │                  │
│   │ Auth:         │    │ Listen:          │
│   │ • POST login  │    │ • data-sync      │
│   │ • GET user    │    │ • notification   │
│   │               │    │ • online-status  │
│   │ Data:         │    │                  │
│   │ • GET visits  │    │ Emit:            │
│   │ • GET outlets │    │ • visit-checkin  │
│   │ • POST visits │    │ • location-update│
│   │ • POST photos │    │ • device-status  │
│   └──────┬────────┘    └────────┬─────────┘
│          │                      │
│          │                      │
│          └──────────┬───────────┘
│                     │
│          ┌──────────▼────────────┐
│          │ Backend API           │
│          │ (https://api.         │
│          │  gisconnect.online)   │
│          │                       │
│          │ Port: 3000 (443 HTTPS)│
│          └──────────────────────┘
│
│ ┌────────────────────────────────┐
│ │ Local Storage (AsyncStorage)   │
│ │ • User token                   │
│ │ • Offline visits              │
│ │ • Pending actions             │
│ │ • User preferences            │
│ └────────────────────────────────┘
│
│ ┌────────────────────────────────┐
│ │ Device Features                │
│ │ • GPS Coordinates              │
│ │ • Camera (before/after pics)   │
│ │ • Network Detection            │
│ │ • Push Notifications           │
│ └────────────────────────────────┘
│
└────────────────────────────────────┘
```

## Real-time Synchronization Flow

```
Timeline: Field Visit Update

  Mobile App               Backend              Dashboard
  (Field)                 (Server)             (Office)
      |                      |                    |
      | 1. Check-in at       |                    |
      |    10:30 AM          |                    |
      |------------------------→ POST /api/      |
      |    visitaction       |  visitaction       |
      |    {gps, photo,      |                    |
      |     timestamp}       |                    |
      |                      |                    |
      |                      | 2. Save to DB      |
      |                      | 3. Broadcast       |
      |                      |    via Socket.IO   |
      |                      |                    |
      |                      |    emit 'data-sync'|
      |                      |------------------------→
      |                      |                    | 4. Receive
      |                      |                    |    update
      |                      |                    | 5. Refresh
      |                      |                    |    visit
      |                      |                    |    status
      |                      |                    | 6. Re-fetch
      |                      |                    |    data
      |                      |                    | 7. Update
      |                      |                    |    UI
      |                      |                    |
      | ← Confirmation ←─────────────────────────|
      | Updated visit object                      |
      |                                           |
```

## Performance Optimization

```
┌─────────────────────────────────────┐
│ Performance Layers                  │
├─────────────────────────────────────┤
│                                     │
│ 1. CDN/Edge (Optional)              │
│    • Cache static files             │
│    • Compress responses             │
│                                     │
│ 2. Nginx (Reverse Proxy)            │
│    • Gzip compression               │
│    • Caching headers                │
│    • Load balancing                 │
│    • SSL termination                │
│                                     │
│ 3. Backend (Node.js)                │
│    • Cluster mode (CPU cores)       │
│    • Connection pooling             │
│    • Query optimization             │
│    • Caching (Redis optional)       │
│                                     │
│ 4. Database (SQLite)                │
│    • Indexed queries                │
│    • Prepared statements            │
│    • Regular maintenance            │
│                                     │
│ 5. Client (Browser/Mobile)          │
│    • Code splitting                 │
│    • Image lazy loading             │
│    • Service workers                │
│    • Local caching                  │
│                                     │
└─────────────────────────────────────┘
```

---

**End of Architecture Diagram**
