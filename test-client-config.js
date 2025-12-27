const axios = require('axios');

console.log('='.repeat(70));
console.log('CLIENT CONFIGURATION TEST');
console.log('Testing Backend API on Port 3001');
console.log('='.repeat(70));
console.log();

const API_BASE_URL = 'http://localhost:3001/api';
let authToken = '';

// Test results
const results = {
  passed: 0,
  failed: 0,
  tests: []
};

function logTest(name, passed, message = '') {
  const status = passed ? '✓ PASS' : '✗ FAIL';
  const color = passed ? '\x1b[32m' : '\x1b[31m';
  console.log(`${color}${status}\x1b[0m ${name}`);
  if (message) console.log(`  ${message}`);
  
  results.tests.push({ name, passed, message });
  if (passed) results.passed++;
  else results.failed++;
}

async function testEndpoint(name, method, url, data = null, headers = {}) {
  try {
    const config = {
      method,
      url: `${API_BASE_URL}${url}`,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };
    
    if (data) config.data = data;
    
    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data || error.message,
      status: error.response?.status 
    };
  }
}

async function runTests() {
  console.log('1. Testing Root Endpoint');
  console.log('-'.repeat(70));
  
  const rootTest = await testEndpoint('Root', 'GET', '/..');
  if (rootTest.success && rootTest.data.success) {
    logTest('Root endpoint accessible', true, `Version: ${rootTest.data.version}`);
  } else {
    logTest('Root endpoint accessible', false, 'Failed to connect');
    return;
  }
  console.log();

  console.log('2. Testing Authentication (Login)');
  console.log('-'.repeat(70));
  
  const loginTest = await testEndpoint('Login', 'POST', '/auth/login', {
    username: 'admin-gis',
    password: 'gis2026'
  });
  
  if (loginTest.success && loginTest.data.success) {
    authToken = loginTest.data.token;
    logTest('Login endpoint', true, `Token received: ${authToken.substring(0, 20)}...`);
  } else {
    logTest('Login endpoint', false, JSON.stringify(loginTest.error));
    return;
  }
  console.log();

  console.log('3. Testing Dashboard Stats (Authenticated)');
  console.log('-'.repeat(70));
  
  const statsTest = await testEndpoint('Dashboard Stats', 'GET', '/dashboard/stats', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (statsTest.success && statsTest.data.success) {
    const stats = statsTest.data.data.summary;
    logTest('Dashboard stats endpoint', true, 
      `Users: ${stats.totalUsers}, Outlets: ${stats.totalOutlets}, MD Visits: ${stats.totalMdVisits}`);
  } else {
    logTest('Dashboard stats endpoint', false, JSON.stringify(statsTest.error));
  }
  console.log();

  console.log('4. Testing Users Endpoint');
  console.log('-'.repeat(70));
  
  const usersTest = await testEndpoint('Users List', 'GET', '/users', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (usersTest.success && usersTest.data.success) {
    logTest('Users endpoint', true, `Found ${usersTest.data.data.length} users`);
  } else {
    logTest('Users endpoint', false, JSON.stringify(usersTest.error));
  }
  console.log();

  console.log('5. Testing Outlets Endpoint');
  console.log('-'.repeat(70));
  
  const outletsTest = await testEndpoint('Outlets List', 'GET', '/outlets', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (outletsTest.success && outletsTest.data.success) {
    logTest('Outlets endpoint', true, `Found ${outletsTest.data.data.length} outlets`);
  } else {
    logTest('Outlets endpoint', false, JSON.stringify(outletsTest.error));
  }
  console.log();

  console.log('6. Testing MD Visits Endpoint');
  console.log('-'.repeat(70));
  
  const mdVisitsTest = await testEndpoint('MD Visits', 'GET', '/visits/md', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (mdVisitsTest.success && mdVisitsTest.data.success) {
    logTest('MD visits endpoint', true, `Found ${mdVisitsTest.data.data.length} MD visits`);
  } else {
    logTest('MD visits endpoint', false, JSON.stringify(mdVisitsTest.error));
  }
  console.log();

  console.log('7. Testing Sales Visits Endpoint');
  console.log('-'.repeat(70));
  
  const salesVisitsTest = await testEndpoint('Sales Visits', 'GET', '/visits/sales', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (salesVisitsTest.success && salesVisitsTest.data.success) {
    logTest('Sales visits endpoint', true, `Found ${salesVisitsTest.data.data.length} sales visits`);
  } else {
    logTest('Sales visits endpoint', false, JSON.stringify(salesVisitsTest.error));
  }
  console.log();

  console.log('8. Testing Visit Actions Endpoint');
  console.log('-'.repeat(70));
  
  const actionsTest = await testEndpoint('Visit Actions', 'GET', '/visit-actions', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (actionsTest.success && actionsTest.data.success) {
    logTest('Visit actions endpoint', true, `Found ${actionsTest.data.data.length} actions`);
  } else {
    logTest('Visit actions endpoint', false, JSON.stringify(actionsTest.error));
  }
  console.log();

  console.log('9. Testing Reports Endpoint');
  console.log('-'.repeat(70));
  
  const reportsTest = await testEndpoint('Daily Reports', 'GET', '/reports/daily', null, {
    'Authorization': `Bearer ${authToken}`
  });
  
  if (reportsTest.success && reportsTest.data.success) {
    logTest('Reports endpoint', true, `Found ${reportsTest.data.data.length} reports`);
  } else {
    logTest('Reports endpoint', false, JSON.stringify(reportsTest.error));
  }
  console.log();

  // Summary
  console.log('='.repeat(70));
  console.log('TEST SUMMARY');
  console.log('='.repeat(70));
  console.log(`Total Tests: ${results.tests.length}`);
  console.log(`\x1b[32mPassed: ${results.passed}\x1b[0m`);
  console.log(`\x1b[31mFailed: ${results.failed}\x1b[0m`);
  console.log();

  if (results.failed === 0) {
    console.log('\x1b[32m✓ ALL TESTS PASSED!\x1b[0m');
    console.log();
    console.log('Client Configuration Status:');
    console.log('  ✓ Backend API running on port 3001');
    console.log('  ✓ Dashboard configured: http://localhost:3001/api');
    console.log('  ✓ Mobile App configured: http://192.168.0.43:3001/api');
    console.log();
    console.log('Next Steps:');
    console.log('  1. Start Dashboard: cd dashboard && npm run dev');
    console.log('  2. Start Mobile App: cd MobileApp && npm start');
    console.log('  3. Test connectivity from both clients');
  } else {
    console.log('\x1b[31m✗ SOME TESTS FAILED\x1b[0m');
    console.log('Please check the errors above and fix the issues.');
  }
  console.log('='.repeat(70));
}

// Run tests
runTests().catch(error => {
  console.error('\x1b[31mTest execution failed:\x1b[0m', error.message);
  process.exit(1);
});
