# CORS Login Error - Solution Guide

## Problem Description

The Flutter web app fails to login with the error **"ClientException: Failed to fetch"** when trying to connect to the Laravel API at `http://13.204.86.61/api/apparel/login`.

## Root Cause: CORS Policy Restriction

**Cross-Origin Resource Sharing (CORS)** policy is blocking the Flutter web app from making HTTP requests to the external Laravel API server.

### Why This Happens:
1. **Flutter Web runs in Browser**: Unlike mobile apps, Flutter web runs in a web browser environment
2. **Browser Security**: Browsers enforce CORS policy to prevent malicious websites from accessing external APIs
3. **Missing CORS Headers**: The Laravel server doesn't include proper CORS headers to allow requests from `localhost`
4. **Different Origins**: Flutter app runs on `http://localhost:port` while API is on `http://13.204.86.61`

### Evidence:
- ✅ **API Works**: Direct PowerShell requests to the API succeed and return valid tokens
- ❌ **Flutter Fails**: All HTTP requests from Flutter web app fail with "Failed to fetch"
- 🔍 **Debug Logs**: Flutter console shows `ClientException: Failed to fetch` for all API calls

## Solutions

### 🔧 Solution 1: Fix Laravel Server CORS (Recommended)

**Best for Production**: Configure the Laravel server to allow CORS requests.

**Laravel CORS Configuration:**
```php
// In Laravel: config/cors.php
'paths' => ['api/*'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // Or specific domains like 'http://localhost:3000'
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'exposed_headers' => [],
'max_age' => 0,
'supports_credentials' => false,
```

**Install Laravel CORS package:**
```bash
composer require fruitcake/laravel-cors
php artisan vendor:publish --tag="cors"
```

### 🔧 Solution 2: Development Testing with CORS Disabled

**For Testing Only**: Run Flutter with CORS disabled in Chrome.

```bash
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--user-data-dir=temp"
```

⚠️ **Warning**: This is only for development testing and creates security risks.

### 🔧 Solution 3: Use Development Proxy

**For Local Development**: Set up a proxy server to bypass CORS.

```bash
# Using http-proxy-middleware or similar tools
# This requires additional setup and configuration
```

### 🔧 Solution 4: Deploy to Same Domain

**For Production**: Deploy Flutter web app to the same domain as the API or a CORS-allowed domain.

## Current Status

### ✅ What's Working:
- Flutter app runs successfully in browser
- Navigation and UI components work perfectly
- CorsSafeImage widget successfully loads product images
- Authentication logic is properly implemented
- API endpoints are functional (tested with PowerShell)

### ❌ What's Blocked:
- Login functionality (CORS blocked)
- Product data fetching (CORS blocked)
- All API communications (CORS blocked)

## Next Steps

1. **Immediate**: Contact the Laravel API administrator to enable CORS headers
2. **Testing**: Use the CORS-disabled Chrome flag for immediate testing
3. **Development**: Consider implementing a local mock API for development
4. **Production**: Ensure proper CORS configuration before deployment

## Test Credentials

For testing once CORS is resolved:
- **Email**: `it22232922@my.sliit.lk`
- **Password**: `12345678`

## Expected API Response

When CORS is properly configured, the login should return:
```json
{
  "message": "Login successful",
  "user": "it22232922@my.sliit.lk",
  "token": "57|apparel_TmLrEj8QBH5qsDFQA4q9vN5yz0G3QvgqwoZRjw1Ic1d69957",
  "apparel_store_api": {
    "sanctum_auth": "IMPLEMENTED",
    "nosql_database": "MONGODB_CONFIGURED"
  }
}
```

## Additional Notes

- The `CorsSafeImage` widget successfully bypasses CORS for image loading using direct HTTP requests
- The same approach could be used for API calls, but it's better to fix CORS properly
- Mobile versions of the app (Android/iOS) will not have CORS issues as they don't run in browsers