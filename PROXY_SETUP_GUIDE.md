# CORS Proxy Setup and Usage Guide

## What This Solves
This proxy server solves the CORS (Cross-Origin Resource Sharing) issue that prevents your Flutter web app from communicating with the Laravel API at `http://13.204.86.61`.

## Setup Instructions

### 1. Install Node.js (if not already installed)
Download and install Node.js from: https://nodejs.org/

### 2. Install Dependencies
Open PowerShell in the project directory and run:
```powershell
npm install
```

### 3. Start the Proxy Server
```powershell
npm start
```

You should see:
```
🚀 CORS Proxy Server running on http://localhost:8080
📡 Proxying API requests to http://13.204.86.61
✅ CORS enabled for Flutter web app
```

### 4. Run Your Flutter App
In a new terminal window:
```powershell
flutter run -d chrome
```

## How It Works

1. **Proxy Server**: Runs on `http://localhost:8080`
2. **API Requests**: Flutter app → Proxy → Laravel server
3. **CORS Headers**: Proxy adds proper CORS headers to all responses
4. **Transparent**: Your Flutter app code remains unchanged

## API Endpoints

- **Login**: `http://localhost:8080/api/apparel/login`
- **Products**: `http://localhost:8080/api/apparel/products`
- **Categories**: `http://localhost:8080/api/apparel/categories`
- **Images**: `http://localhost:8080/storage/products/...`

## Troubleshooting

### Port Already in Use
If port 8080 is busy, edit `proxy_server.js` and change:
```javascript
const PORT = 8080; // Change to 8081, 8082, etc.
```

Then update the Flutter API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8081/api/apparel';
```

### Node.js Not Found
Install Node.js from: https://nodejs.org/

### Permission Errors
Run PowerShell as Administrator

## Testing the Proxy

Test if the proxy is working:
```powershell
curl http://localhost:8080/health
```

Should return:
```json
{"status":"OK","message":"CORS Proxy Server is running"}
```

## Production Deployment

For production, you have better options:
1. Configure CORS properly on the Laravel server
2. Deploy Flutter app to the same domain as the API
3. Use a production-grade reverse proxy (nginx, Apache)

This proxy is perfect for development and testing!