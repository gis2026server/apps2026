# Dashboard Frontend Testing Guide

**Purpose**: Manual testing checklist for verifying dashboard functionality with backend API on port 3001

**Prerequisites**:
- ✅ Backend API running on port 3001
- ✅ Dashboard configured to use port 3001
- ✅ Dashboard dev server ready to start

---

## 🚀 Starting the Dashboard

### Step 1: Start Dashboard Dev Server
```bash
cd dashboard
npm run dev
```

**Expected Output**:
```
VITE v5.4.11  ready in 1023 ms
➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### Step 2: Open Dashboard
- Open browser: http://localhost:5173
- Dashboard should load and show login page

---

## ✅ Testing Checklist

### 1. Login Page Testing

#### Test 1.1: Valid Login
**Steps**:
1. Navigate to http://localhost:5173
2. Enter username: `admin-gis`
3. Enter password: `gis2026`
4. Click "Login" button

**Expected Result**:
- ✅ Login successful
- ✅ Redirected to main dashboard
- ✅ JWT token stored in localStorage
- ✅ No console errors

**API Call Verified**:
```
POST http://localhost:3001/api/auth/login
Response: 200 OK with token
```

#### Test 1.2: Invalid Login
**Steps**:
1. Enter username: `wrong-user`
2. Enter password: `wrong-pass`
3. Click "Login" button

**Expected Result**:
- ✅ Error message displayed
- ✅ User remains on login page
- ✅ No token stored

---

### 2. Main Dashboard Page Testing

#### Test 2.1: Dashboard Statistics
**Steps**:
1. After successful login, view main dashboard
2. Check statistics cards display

**Expected Result**:
- ✅ Total Users: 2
- ✅ Total Outlets: 10
- ✅ Total MD Visits: 10
- ✅ Total Sales Visits: 10
- ✅ All numbers display correctly

**API Call Verified**:
```
GET http://localhost:3001/api/dashboard/stats
Response: 200 OK with statistics
```

#### Test 2.2: Charts Display
**Steps**:
1. Scroll down to view charts section
2. Check MD Visits chart
3. Check Sales Visits chart

**Expected Result**:
- ✅ MD Visits chart shows data by date
- ✅ Sales Visits chart shows data by date
- ✅ Charts render without errors
- ✅ Data matches backend response

#### Test 2.3: Navigation Menu
**Steps**:
1. Click on each menu item:
   - Dashboard
   - Users
   - Outlets
   - MD Visits
   - Sales Visits
   - Reports

**Expected Result**:
- ✅ Each page loads correctly
- ✅ No navigation errors
- ✅ Active menu item highlighted

---

### 3. User Management Testing

#### Test 3.1: User List Display
**Steps**:
1. Navigate to Users page
2. View user list

**Expected Result**:
- ✅ List shows 2 users
- ✅ User details displayed correctly:
  - mdjaksel01 (MD, JAKSEL)
  - salesjaksel (Sales, JAKSEL)
- ✅ Table renders properly

**API Call Verified**:
```
GET http://localhost:3001/api/users
Response: 200 OK with 2 users
```

#### Test 3.2: User Creation (Optional)
**Steps**:
1. Click "Add User" button
2. Fill in user details
3. Click "Save"

**Expected Result**:
- ✅ Form validation works
- ✅ User created successfully
- ✅ List refreshes with new user

**API Call**:
```
POST http://localhost:3001/api/users
```

#### Test 3.3: Excel Upload (Optional)
**Steps**:
1. Click "Upload Excel" button
2. Select Excel file
3. Upload file

**Expected Result**:
- ✅ File upload works
- ✅ Users imported successfully
- ✅ List refreshes

**API Call**:
```
POST http://localhost:3001/api/users/upload-excel
```

---

### 4. Outlet Management Testing

#### Test 4.1: Outlet List Display
**Steps**:
1. Navigate to Outlets page
2. View outlet list

**Expected Result**:
- ✅ List shows 10 outlets
- ✅ Outlet details displayed:
  - ID, Name, Address
  - Latitude, Longitude
  - Warehouse, AMO
- ✅ Table renders properly

**API Call Verified**:
```
GET http://localhost:3001/api/outlets
Response: 200 OK with 10 outlets
```

#### Test 4.2: Outlet Details
**Steps**:
1. Click on an outlet to view details
2. Check all information displays

**Expected Result**:
- ✅ All outlet fields visible
- ✅ GPS coordinates shown
- ✅ No data missing

---

### 5. Visit Scheduling Testing

#### Test 5.1: MD Visits List
**Steps**:
1. Navigate to MD Visits page
2. View visit list

**Expected Result**:
- ✅ List shows 10 MD visits
- ✅ Visit details displayed:
  - Outlet name
  - Date
  - Status (scheduled)
  - Username
- ✅ Table renders properly

**API Call Verified**:
```
GET http://localhost:3001/api/visits/md
Response: 200 OK with 10 visits
```

#### Test 5.2: Sales Visits List
**Steps**:
1. Navigate to Sales Visits page
2. View visit list

**Expected Result**:
- ✅ List shows 10 sales visits
- ✅ Visit details displayed correctly
- ✅ Different dates shown
- ✅ Table renders properly

**API Call Verified**:
```
GET http://localhost:3001/api/visits/sales
Response: 200 OK with 10 visits
```

#### Test 5.3: Visit Creation (Optional)
**Steps**:
1. Click "Schedule Visit" button
2. Select outlet
3. Select date
4. Click "Save"

**Expected Result**:
- ✅ Form validation works
- ✅ Visit created successfully
- ✅ List refreshes

---

### 6. Reports Testing

#### Test 6.1: Daily Reports View
**Steps**:
1. Navigate to Reports page
2. View reports list

**Expected Result**:
- ✅ Reports page loads
- ✅ Date filter works
- ✅ List displays (may be empty initially)

**API Call Verified**:
```
GET http://localhost:3001/api/reports/daily
Response: 200 OK with reports array
```

#### Test 6.2: Excel Export (Optional)
**Steps**:
1. Select date range
2. Click "Export to Excel"
3. Download file

**Expected Result**:
- ✅ Excel file downloads
- ✅ File contains correct data
- ✅ No errors

**API Call**:
```
GET http://localhost:3001/api/reports/export
Response: Excel file blob
```

---

### 7. Real-time Features Testing

#### Test 7.1: WebSocket Connection
**Steps**:
1. Open browser console
2. Check for WebSocket connection

**Expected Result**:
- ✅ WebSocket connected to backend
- ✅ No connection errors
- ✅ Real-time updates working

#### Test 7.2: Live Data Updates (Optional)
**Steps**:
1. Keep dashboard open
2. Make changes via API or mobile app
3. Check if dashboard updates

**Expected Result**:
- ✅ Data refreshes automatically
- ✅ No manual refresh needed

---

### 8. Error Handling Testing

#### Test 8.1: Network Error
**Steps**:
1. Stop backend API (pm2 stop dashboard-api)
2. Try to fetch data in dashboard
3. Restart backend (pm2 start dashboard-api)

**Expected Result**:
- ✅ Error message displayed
- ✅ No app crash
- ✅ Graceful error handling

#### Test 8.2: Session Expiry
**Steps**:
1. Wait for token to expire (24 hours)
2. Or manually delete token from localStorage
3. Try to access protected page

**Expected Result**:
- ✅ Redirected to login page
- ✅ Session expired message shown
- ✅ Can login again

---

### 9. Performance Testing

#### Test 9.1: Page Load Times
**Steps**:
1. Open browser DevTools
2. Navigate to each page
3. Check Network tab for load times

**Expected Result**:
- ✅ Initial load < 2 seconds
- ✅ Page transitions < 500ms
- ✅ API calls < 300ms

#### Test 9.2: Memory Usage
**Steps**:
1. Open browser Task Manager
2. Use dashboard for 5-10 minutes
3. Check memory usage

**Expected Result**:
- ✅ Memory usage stable
- ✅ No memory leaks
- ✅ Performance remains good

---

### 10. Browser Compatibility (Optional)

#### Test 10.1: Different Browsers
**Test in**:
- Chrome/Edge
- Firefox
- Safari (if available)

**Expected Result**:
- ✅ Works in all browsers
- ✅ UI renders correctly
- ✅ No browser-specific issues

---

## 📊 Testing Summary Template

After completing tests, fill in this summary:

```
Dashboard Frontend Testing Results
Date: [DATE]
Tester: [NAME]

1. Login Page: [ ] Pass [ ] Fail
   - Valid login: [ ] Pass [ ] Fail
   - Invalid login: [ ] Pass [ ] Fail

2. Main Dashboard: [ ] Pass [ ] Fail
   - Statistics display: [ ] Pass [ ] Fail
   - Charts rendering: [ ] Pass [ ] Fail
   - Navigation: [ ] Pass [ ] Fail

3. User Management: [ ] Pass [ ] Fail
   - List display: [ ] Pass [ ] Fail
   - User creation: [ ] Pass [ ] Fail [ ] Skipped
   - Excel upload: [ ] Pass [ ] Fail [ ] Skipped

4. Outlet Management: [ ] Pass [ ] Fail
   - List display: [ ] Pass [ ] Fail
   - Outlet details: [ ] Pass [ ] Fail

5. Visit Scheduling: [ ] Pass [ ] Fail
   - MD visits list: [ ] Pass [ ] Fail
   - Sales visits list: [ ] Pass [ ] Fail
   - Visit creation: [ ] Pass [ ] Fail [ ] Skipped

6. Reports: [ ] Pass [ ] Fail
   - Reports view: [ ] Pass [ ] Fail
   - Excel export: [ ] Pass [ ] Fail [ ] Skipped

7. Real-time Features: [ ] Pass [ ] Fail [ ] Skipped

8. Error Handling: [ ] Pass [ ] Fail [ ] Skipped

9. Performance: [ ] Pass [ ] Fail

10. Browser Compatibility: [ ] Pass [ ] Fail [ ] Skipped

Overall Status: [ ] All Tests Passed [ ] Some Tests Failed
Notes: [ADD ANY NOTES OR ISSUES FOUND]
```

---

## 🔧 Troubleshooting

### Dashboard Won't Load
```bash
# Check if dev server is running
netstat -ano | findstr :5173

# Restart dev server
cd dashboard
npm run dev
```

### API Connection Errors
```bash
# Check backend is running
pm2 status

# Test API directly
curl http://localhost:3001

# Check API configuration
# File: dashboard/src/services/api.js
# Should be: http://localhost:3001/api
```

### Console Errors
1. Open browser DevTools (F12)
2. Check Console tab for errors
3. Check Network tab for failed requests
4. Verify API responses

---

## ✅ Quick Verification

**Minimum tests to verify system is working**:

1. ✅ Login with admin-gis / gis2026
2. ✅ View dashboard statistics (should show 2 users, 10 outlets, 20 visits)
3. ✅ Navigate to Users page (should show 2 users)
4. ✅ Navigate to Outlets page (should show 10 outlets)
5. ✅ Navigate to MD Visits page (should show 10 visits)
6. ✅ Navigate to Sales Visits page (should show 10 visits)

**If all 6 tests pass, the dashboard is working correctly!**

---

## 📝 Notes

- All backend API endpoints have been tested and verified working
- Dashboard is configured to use port 3001
- Vite version has been downgraded to 5.4.11 for compatibility
- Default credentials: admin-gis / gis2026

---

**Happy Testing! 🚀**
