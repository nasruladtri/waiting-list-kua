# Setup Guide - KUA Waiting List

## Prerequisites

- Docker & Docker Compose
- Git
- (Optional) Node.js 18+ untuk local development
- (Optional) Flutter SDK untuk frontend development

---

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/Nasruladtri/kua-waiting-list.git
cd kua-waiting-list
```

### 2. Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env` file:
```bash
GCP_PROJECT=kua-waiting-list-dev
APP_ENV=development
EMULATOR_UI_PORT=4100
FIRESTORE_PORT=8282
AUTH_PORT=9190
STORAGE_PORT=9292
FUNCTIONS_PORT=5100

# WhatsApp API (Optional)
# WHATSAPP_API_URL=https://api.fonnte.com/send
# WHATSAPP_API_KEY=your_api_key
```

### 3. Install Cloud Functions Dependencies

```bash
cd backend/functions
npm install
cd ../..
```

### 4. Run with Docker Compose

```bash
docker-compose up -d
```

### 5. Access Emulator UI

Open browser: http://localhost:4100

**Available Services**:
- Emulator UI: http://localhost:4100
- Firestore: http://localhost:8282
- Auth: http://localhost:9190
- Storage: http://localhost:9292
- Functions: http://localhost:5100

### 6. Create Initial Superadmin (Optional)

Via Emulator UI:
1. Go to Authentication tab
2. Add user manually
3. Go to Firestore tab
4. Create document in `users` collection:
   ```json
   {
     "email": "admin@kua.go.id",
     "name": "Super Admin",
     "phone": "081234567890",
     "role": "superadmin",
     "createdAt": "2024-12-04T10:00:00Z"
   }
   ```

---

## Production Deployment (Portainer)

### 1. Build Docker Image

```bash
chmod +x build.sh
./build.sh v1.0.0
```

When prompted, choose `y` to push to Docker registry.

### 2. Configure Docker Hub

Make sure you're logged in:
```bash
docker login
```

Update `build.sh` with your Docker Hub username:
```bash
DOCKER_USERNAME="yourusername"
```

### 3. Deploy to Portainer

1. Login to Portainer
2. Go to **Stacks** → **Add Stack**
3. Name: `kua-waiting-list`
4. Paste content from `docker-stack.yml`
5. Set environment variables:
   - `GCP_PROJECT`: `kua-waiting-list-dev`
   - `APP_ENV`: `production`
   - `DOCKER_IMAGE`: `yourusername/kua-waiting-list:v1.0.0`
   - `WHATSAPP_API_URL`: (your WhatsApp API URL)
   - `WHATSAPP_API_KEY`: (your WhatsApp API key)
6. Click **Deploy the stack**

### 4. Verify Deployment

Check logs in Portainer:
```
Stacks → kua-waiting-list → Logs
```

Access Emulator UI:
```
http://YOUR_VPS_IP:4100
```

### 5. Configure Firewall (VPS)

```bash
sudo ufw allow 4100/tcp  # Emulator UI
sudo ufw allow 8282/tcp  # Firestore
sudo ufw allow 9190/tcp  # Auth
sudo ufw allow 9292/tcp  # Storage
sudo ufw allow 5100/tcp  # Functions
```

---

## GitHub Actions Auto-Deploy

### 1. Setup GitHub Secrets

Go to repository **Settings** → **Secrets and variables** → **Actions**

Add secrets:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password/token
- `PORTAINER_WEBHOOK_URL`: Portainer webhook URL (optional)

### 2. Get Portainer Webhook URL (Optional)

1. In Portainer, go to **Stacks** → `kua-waiting-list`
2. Click **Webhooks**
3. Create webhook
4. Copy webhook URL

### 3. Push to Main Branch

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actions will automatically:
1. Build Docker image
2. Push to Docker Hub
3. Trigger Portainer webhook (if configured)

---

## Flutter App Setup

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Configure Firebase Emulator

For local development, the app is already configured to use emulator.

Edit `lib/main.dart` if needed:
```dart
// Change localhost to your VPS IP for production testing
FirebaseAuth.instance.useAuthEmulator('YOUR_VPS_IP', 9190);
FirebaseFirestore.instance.useFirestoreEmulator('YOUR_VPS_IP', 8282);
FirebaseStorage.instance.useStorageEmulator('YOUR_VPS_IP', 9292);
```

### 3. Run Flutter App

```bash
flutter run
```

Or for specific device:
```bash
flutter devices
flutter run -d <device_id>
```

---

## Troubleshooting

### Emulator tidak bisa diakses

**Problem**: Cannot access emulator from outside

**Solution**:
1. Check firewall rules
2. Ensure emulator binds to `0.0.0.0` not `localhost`
3. Check `firebase.json` emulator host settings

### Cloud Functions error

**Problem**: Functions not working

**Solution**:
```bash
# Check logs
docker logs kua-firebase-emulator

# Rebuild functions
cd backend/functions
npm install
cd ../..
docker-compose restart
```

### WhatsApp notification tidak terkirim

**Problem**: Notifications not sent

**Solution**:
1. Check environment variables
2. Verify API key is correct
3. Check phone number format (must start with 62)
4. Check Cloud Functions logs

### Flutter app tidak connect ke emulator

**Problem**: App cannot connect to Firebase Emulator

**Solution**:
1. Check emulator is running
2. Verify IP address in Flutter code
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For iOS simulator, use `localhost`

---

## Maintenance

### Update Docker Image

```bash
./build.sh v1.1.0
```

### Backup Emulator Data

```bash
# Export Firestore data
firebase emulators:export ./backup

# Import Firestore data
firebase emulators:start --import=./backup
```

### View Logs

```bash
# Docker Compose
docker-compose logs -f

# Portainer
# Via Portainer UI: Stacks → Logs
```

### Cleanup

```bash
chmod +x cleanup-docker.sh
./cleanup-docker.sh
```

---

## Support

For issues or questions:
- GitHub Issues: https://github.com/Nasruladtri/kua-waiting-list/issues
- Email: nasruladitri@example.com
