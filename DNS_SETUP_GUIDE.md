# DNS Setup Guide for gisconnect.online

## Step 1: Find Your Server IP Address

Ask your hosting provider for your server's public IP address. It looks like: `123.45.67.89`

## Step 2: DNS Records Required

You need to add **4 DNS A Records** to point all domains to your server:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | gisconnect.online | YOUR_SERVER_IP | 3600 |
| A | api.gisconnect.online | YOUR_SERVER_IP | 3600 |
| A | app.gisconnect.online | YOUR_SERVER_IP | 3600 |
| A | www.gisconnect.online | YOUR_SERVER_IP | 3600 |

### Optional: Add CNAME for www
Instead of an A record for `www`, you can add:
| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | www | gisconnect.online | 3600 |

---

## Step 3: Update DNS at dns-parking.com

### Login to DNS Parking Account
1. Go to https://www.dns-parking.com
2. Click "Domain Management" or "Login"
3. Enter your credentials
4. Find your domain "gisconnect.online"

### Access DNS Settings
1. Click on your domain (gisconnect.online)
2. Look for "DNS Settings", "Manage DNS", or "Edit DNS"
3. Find the section for "A Records" or "DNS Records"

### Add A Records
For each domain below:

**Record 1: Root Domain**
- Type: A
- Name: gisconnect.online (or leave blank for root)
- Value: YOUR_SERVER_IP
- TTL: 3600
- Click **Save** or **Add**

**Record 2: API Subdomain**
- Type: A
- Name: api
- Value: YOUR_SERVER_IP
- TTL: 3600
- Click **Save** or **Add**

**Record 3: App Subdomain**
- Type: A
- Name: app
- Value: YOUR_SERVER_IP
- TTL: 3600
- Click **Save** or **Add**

**Record 4: WWW Subdomain**
- Type: A
- Name: www
- Value: YOUR_SERVER_IP
- TTL: 3600
- Click **Save** or **Add**

---

## Step 4: Verify DNS Propagation

After adding records, wait **5-15 minutes** for DNS propagation worldwide.

### Test on Windows
```cmd
nslookup gisconnect.online
nslookup api.gisconnect.online
nslookup app.gisconnect.online
```

### Test on Mac/Linux
```bash
nslookup gisconnect.online
dig gisconnect.online
```

### Expected Output
```
Name:   gisconnect.online
Address: YOUR_SERVER_IP
```

### Online DNS Checker
Visit: https://dnschecker.org/ and enter:
- gisconnect.online
- api.gisconnect.online
- app.gisconnect.online

All should resolve to YOUR_SERVER_IP

---

## Step 5: Common Issues & Fixes

### Issue: "Domain not resolving"

**Solution 1: Wait longer**
- DNS can take up to 24 hours to fully propagate
- Most take 5-15 minutes
- Check again in 30 minutes

**Solution 2: Clear DNS Cache**

**Windows:**
```cmd
ipconfig /flushdns
```

**Mac:**
```bash
sudo dscacheutil -flushcache
```

**Linux:**
```bash
sudo systemctl restart systemd-resolved
```

### Issue: "Nameservers not pointing correctly"

The nameservers listed when you query should be:
- ns1.dns-parking.com
- ns2.dns-parking.com

If they're different, you may need to update nameservers at your domain registrar (GoDaddy, Namecheap, etc.)

### Issue: "404 Not Found" after DNS resolves

This means DNS is working but the web server isn't responding correctly. Check:

```bash
# On your server
sudo systemctl status nginx
curl http://localhost:3000/health
pm2 status
```

---

## Step 6: Verify Everything Works

Once DNS propagates:

### Test 1: Check DNS Resolution
```bash
nslookup gisconnect.online
# Should return YOUR_SERVER_IP
```

### Test 2: Check HTTP (redirects to HTTPS)
```bash
curl -I http://gisconnect.online
# Should return HTTP 301 Redirect
```

### Test 3: Check HTTPS
```bash
curl -I https://gisconnect.online
# Should return HTTP 200 OK
```

### Test 4: Check API
```bash
curl -I https://api.gisconnect.online/health
# Should return HTTP 200 OK
```

### Test 5: Check Dashboard
```bash
curl -I https://app.gisconnect.online
# Should return HTTP 200 OK
```

### Test 6: Visit in Browser
- Desktop: https://gisconnect.online
- Mobile: Open browser → https://gisconnect.online
- Should see login page

---

## Reference: Common DNS Record Types

| Type | Purpose | Example |
|------|---------|---------|
| A | Points domain to IPv4 address | gisconnect.online → 123.45.67.89 |
| AAAA | Points domain to IPv6 address | gisconnect.online → 2001:0db8:85a3:0000 |
| CNAME | Alias to another domain | www → gisconnect.online |
| MX | Mail exchange server | mail.gisconnect.online |
| TXT | Text records (SPF, DKIM) | v=spf1 include:... |
| NS | Nameserver | ns1.dns-parking.com |

---

## DNS Propagation Timeline

| Time | Status | Action |
|------|--------|--------|
| 0-5 min | Processing | Wait |
| 5-15 min | Most propagated | Test DNS |
| 15-60 min | Fully propagated | Test website |
| 60+ min | Still not working? | Check nameservers |

---

## Contact Support

If DNS isn't working after 2 hours:

1. **Check Nameservers:**
   ```bash
   whois gisconnect.online | grep -i nameserver
   ```
   Should show:
   ```
   Nameserver: ns1.dns-parking.com
   Nameserver: ns2.dns-parking.com
   ```

2. **Contact dns-parking.com Support**
   - URL: https://www.dns-parking.com/support
   - Provide: Domain name + A record details

3. **Check Hosting Provider**
   - Verify YOUR_SERVER_IP is correct
   - Verify server is running and accessible
   - Check firewall rules

---

## Summary Checklist

- [ ] Found server IP address (e.g., 123.45.67.89)
- [ ] Logged into dns-parking.com
- [ ] Added A record for gisconnect.online
- [ ] Added A record for api.gisconnect.online
- [ ] Added A record for app.gisconnect.online
- [ ] Added A record for www.gisconnect.online
- [ ] Waited 5-15 minutes
- [ ] Tested with nslookup/dig
- [ ] Verified on DNS checker website
- [ ] Tested HTTPS on all domains
- [ ] Verified dashboard loads
- [ ] Verified API responds to health check

✅ **DNS Setup Complete!**
