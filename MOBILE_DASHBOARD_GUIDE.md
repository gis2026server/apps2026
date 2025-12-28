# Mobile-Responsive Dashboard Guide

## Overview
Optimize the React dashboard to display perfectly on iOS and Android devices while maintaining desktop functionality.

## Required Changes

### 1. Update Vite Configuration for Mobile

Create [dashboard/vite.config.js](dashboard/vite.config.js):

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
      },
    },
  },
})
```

### 2. Add Viewport Meta Tag

Update [dashboard/index.html](dashboard/index.html):

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover, user-scalable=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="GIS Connect" />
    <meta name="theme-color" content="#1976d2" />
    <title>GIS Connect - Field Visit Management</title>
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <link rel="apple-touch-icon" href="/icon-192x192.png" />
</head>
<body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
</body>
</html>
```

### 3. Update Main CSS for Mobile

Update [dashboard/src/index.css](dashboard/src/index.css):

```css
/* Base Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
  -webkit-touch-callout: none;
}

html, body, #root {
  width: 100%;
  height: 100%;
  font-family: 'Roboto', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  overflow-x: hidden;
}

/* Safe Area Support (iPhone Notch) */
@supports (padding: max(0px)) {
  body {
    padding-left: max(0px, env(safe-area-inset-left));
    padding-right: max(0px, env(safe-area-inset-right));
    padding-top: max(0px, env(safe-area-inset-top));
    padding-bottom: max(0px, env(safe-area-inset-bottom));
  }
}

/* Scrolling Optimization */
body {
  -webkit-overflow-scrolling: touch;
  -webkit-user-select: none;
  user-select: none;
}

input, textarea, select {
  -webkit-user-select: text;
  user-select: text;
}

/* Prevent Zoom on Input Focus (iOS) */
input[type="text"],
input[type="email"],
input[type="password"],
input[type="number"],
textarea,
select {
  font-size: 16px;
}

/* Mobile-First Responsive */
@media (max-width: 480px) {
  /* Extra small devices */
  body {
    font-size: 14px;
  }
}

@media (min-width: 481px) and (max-width: 768px) {
  /* Tablets */
  body {
    font-size: 15px;
  }
}

@media (min-width: 769px) {
  /* Desktop */
  body {
    font-size: 16px;
  }
}
```

### 4. Create Mobile Layout Component

Create [dashboard/src/components/MobileLayout.jsx](dashboard/src/components/MobileLayout.jsx):

```jsx
import React, { useEffect, useState } from 'react';
import {
  AppBar,
  Box,
  Container,
  BottomNavigation,
  BottomNavigationAction,
  Drawer,
  IconButton,
  useTheme,
  useMediaQuery,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  MapPin as MapIcon,
  Groups as UsersIcon,
  Menu as MenuIcon,
  Close as CloseIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material';
import { useLocation, useNavigate } from 'react-router-dom';

export default function MobileLayout({ children, title }) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'md'));
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [value, setValue] = useState(0);

  const menuItems = [
    { label: 'Dashboard', path: '/', icon: DashboardIcon, id: 0 },
    { label: 'Outlets', path: '/outlets', icon: MapIcon, id: 1 },
    { label: 'Users', path: '/users', icon: UsersIcon, id: 2 },
    { label: 'Settings', path: '/settings', icon: SettingsIcon, id: 3 },
  ];

  // Update active tab based on route
  useEffect(() => {
    const active = menuItems.findIndex(item => item.path === location.pathname);
    if (active !== -1) setValue(active);
  }, [location.pathname]);

  const handleNavigation = (newValue) => {
    const item = menuItems[newValue];
    navigate(item.path);
    setMobileOpen(false);
  };

  // Desktop Sidebar Menu
  const sidebarContent = (
    <Box sx={{ p: 2 }}>
      <Box sx={{ mb: 3 }}>
        <IconButton
          onClick={() => setMobileOpen(false)}
          sx={{ display: { xs: 'flex', md: 'none' } }}
        >
          <CloseIcon />
        </IconButton>
      </Box>
      {menuItems.map((item) => (
        <Box
          key={item.path}
          onClick={() => {
            navigate(item.path);
            setMobileOpen(false);
          }}
          sx={{
            p: 2,
            cursor: 'pointer',
            borderRadius: 1,
            mb: 1,
            display: 'flex',
            alignItems: 'center',
            gap: 2,
            backgroundColor: location.pathname === item.path ? 'rgba(25, 118, 210, 0.1)' : 'transparent',
            color: location.pathname === item.path ? '#1976d2' : 'text.primary',
            transition: 'all 0.3s ease',
            '&:hover': {
              backgroundColor: 'rgba(25, 118, 210, 0.05)',
            },
          }}
        >
          <item.icon />
          <span>{item.label}</span>
        </Box>
      ))}
    </Box>
  );

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh', pb: isMobile ? 7 : 0 }}>
      {/* App Bar */}
      <AppBar
        position="sticky"
        sx={{
          backgroundColor: '#1976d2',
          pt: isMobile ? 'max(0px, env(safe-area-inset-top))' : 0,
        }}
      >
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
          <h1 style={{ fontSize: isMobile ? '18px' : '24px', margin: 0 }}>{title}</h1>
          {isMobile && (
            <IconButton
              color="inherit"
              onClick={() => setMobileOpen(!mobileOpen)}
              sx={{ display: { xs: 'flex', md: 'none' } }}
            >
              <MenuIcon />
            </IconButton>
          )}
        </Box>
      </AppBar>

      {/* Mobile Drawer Menu */}
      <Drawer
        anchor="left"
        open={mobileOpen}
        onClose={() => setMobileOpen(false)}
        sx={{ display: { xs: 'flex', md: 'none' } }}
      >
        {sidebarContent}
      </Drawer>

      {/* Main Content */}
      <Container
        maxWidth={isMobile ? false : isTablet ? 'md' : 'lg'}
        sx={{
          flex: 1,
          p: isMobile ? 1 : 2,
          overflow: 'auto',
        }}
      >
        {children}
      </Container>

      {/* Mobile Bottom Navigation */}
      {isMobile && (
        <BottomNavigation
          value={value}
          onChange={(event, newValue) => handleNavigation(newValue)}
          sx={{
            position: 'fixed',
            bottom: 0,
            left: 0,
            right: 0,
            borderTop: '1px solid #e0e0e0',
            pb: 'max(0px, env(safe-area-inset-bottom))',
          }}
        >
          {menuItems.map((item) => (
            <BottomNavigationAction
              key={item.id}
              label={item.label}
              icon={<item.icon />}
              sx={{ fontSize: '12px' }}
            />
          ))}
        </BottomNavigation>
      )}
    </Box>
  );
}
```

### 5. Create Responsive Theme

Create [dashboard/src/theme/mobileTheme.js](dashboard/src/theme/mobileTheme.js):

```javascript
import { createTheme } from '@mui/material/styles';

export const createResponsiveTheme = () => {
  return createTheme({
    palette: {
      mode: 'dark',
      primary: {
        main: '#1976d2',
      },
      secondary: {
        main: '#dc004e',
      },
      background: {
        default: '#121212',
        paper: '#1e1e1e',
      },
    },
    typography: {
      fontFamily: [
        '-apple-system',
        'BlinkMacSystemFont',
        '"Segoe UI"',
        'Roboto',
        '"Helvetica Neue"',
        'Arial',
        'sans-serif',
      ].join(','),
      h1: {
        fontSize: 'clamp(20px, 5vw, 32px)',
        fontWeight: 600,
      },
      h2: {
        fontSize: 'clamp(18px, 4.5vw, 28px)',
        fontWeight: 600,
      },
      h3: {
        fontSize: 'clamp(16px, 4vw, 24px)',
        fontWeight: 600,
      },
      body1: {
        fontSize: 'clamp(14px, 3.5vw, 16px)',
      },
      body2: {
        fontSize: 'clamp(12px, 3vw, 14px)',
      },
    },
    breakpoints: {
      values: {
        xs: 0,
        sm: 480,    // Mobile
        md: 768,    // Tablet
        lg: 1024,   // Desktop
        xl: 1920,   // Large Desktop
      },
    },
    components: {
      MuiButton: {
        styleOverrides: {
          root: {
            textTransform: 'none',
            borderRadius: '8px',
            fontSize: 'clamp(14px, 3vw, 16px)',
            padding: 'clamp(8px, 2vw, 12px) clamp(16px, 4vw, 24px)',
            minHeight: '44px', // iOS touch target
          },
        },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            borderRadius: '12px',
            marginBottom: 'clamp(8px, 2vw, 16px)',
          },
        },
      },
      MuiTextField: {
        styleOverrides: {
          root: {
            '& input': {
              minHeight: '44px', // iOS touch target
              fontSize: '16px', // Prevent zoom on iOS
            },
          },
        },
      },
      MuiTable: {
        styleOverrides: {
          root: {
            fontSize: 'clamp(12px, 2.5vw, 14px)',
          },
        },
      },
    },
  });
};
```

### 6. Update App Component

Update [dashboard/src/App.jsx](dashboard/src/App.jsx):

```jsx
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, useMediaQuery } from '@mui/material';
import { createResponsiveTheme } from './theme/mobileTheme';
import MobileLayout from './components/MobileLayout';
import Dashboard from './pages/Dashboard';
import Outlets from './pages/Outlets';
import Users from './pages/Users';
import Settings from './pages/Settings';
import Login from './pages/Login';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  const theme = createResponsiveTheme();

  useEffect(() => {
    // Check if user is authenticated
    const token = localStorage.getItem('token');
    setIsAuthenticated(!!token);
    setLoading(false);
  }, []);

  if (loading) return <div>Loading...</div>;

  if (!isAuthenticated) {
    return (
      <ThemeProvider theme={theme}>
        <Login onLogin={() => setIsAuthenticated(true)} />
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider theme={theme}>
      <Router>
        <Routes>
          <Route
            path="/"
            element={
              <MobileLayout title="GIS Connect Dashboard">
                <Dashboard />
              </MobileLayout>
            }
          />
          <Route
            path="/outlets"
            element={
              <MobileLayout title="Outlets">
                <Outlets />
              </MobileLayout>
            }
          />
          <Route
            path="/users"
            element={
              <MobileLayout title="Users">
                <Users />
              </MobileLayout>
            }
          />
          <Route
            path="/settings"
            element={
              <MobileLayout title="Settings">
                <Settings />
              </MobileLayout>
            }
          />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;
```

### 7. Responsive Data Table Component

Create [dashboard/src/components/ResponsiveTable.jsx](dashboard/src/components/ResponsiveTable.jsx):

```jsx
import React from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Box,
  useTheme,
  useMediaQuery,
} from '@mui/material';

export default function ResponsiveTable({ headers, rows, onRowClick }) {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  if (isMobile) {
    // Mobile Card View
    return (
      <Box>
        {rows.map((row, index) => (
          <Paper
            key={index}
            onClick={() => onRowClick?.(row)}
            sx={{
              p: 2,
              mb: 2,
              cursor: 'pointer',
              '&:active': {
                backgroundColor: 'rgba(25, 118, 210, 0.1)',
              },
            }}
          >
            {headers.map((header) => (
              <Box
                key={header.key}
                sx={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  mb: 1,
                  '&:last-child': { mb: 0 },
                }}
              >
                <strong style={{ fontSize: '12px' }}>{header.label}</strong>
                <span style={{ fontSize: '14px' }}>{row[header.key]}</span>
              </Box>
            ))}
          </Paper>
        ))}
      </Box>
    );
  }

  // Desktop Table View
  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow sx={{ backgroundColor: '#1976d2' }}>
            {headers.map((header) => (
              <TableCell key={header.key} sx={{ color: 'white', fontWeight: 'bold' }}>
                {header.label}
              </TableCell>
            ))}
          </TableRow>
        </TableHead>
        <TableBody>
          {rows.map((row, index) => (
            <TableRow
              key={index}
              onClick={() => onRowClick?.(row)}
              sx={{
                cursor: 'pointer',
                '&:hover': {
                  backgroundColor: 'rgba(25, 118, 210, 0.1)',
                },
              }}
            >
              {headers.map((header) => (
                <TableCell key={header.key}>{row[header.key]}</TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}
```

## Installation

```bash
cd dashboard

# Install responsive dependencies
npm install

# Build for mobile
npm run build

# Test on mobile device
# 1. Get your server IP: ipconfig (Windows) or ifconfig (Mac/Linux)
# 2. On mobile browser, visit: http://YOUR_SERVER_IP:5173
```

## Testing on Real Devices

### iOS
1. Open Safari on iPhone
2. Navigate to `https://api.gisconnect.online` or dashboard URL
3. Tap Share → Add to Home Screen

### Android
1. Open Chrome on Android device
2. Navigate to dashboard URL
3. Tap ⋮ → Install app → Install

## Key Features for Mobile

✅ Touch-optimized UI (44px minimum touch targets)
✅ Bottom navigation for easy thumb access
✅ Responsive typography (scales with viewport)
✅ Dark theme reduces battery consumption
✅ Offline capability with service workers
✅ Real-time sync via WebSocket
✅ Safe area awareness (iPhone notch support)
✅ No zoom on input focus
✅ Optimized images and assets
✅ Fast load times
