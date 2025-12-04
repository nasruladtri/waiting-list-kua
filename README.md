# KUA Waiting List Application

Aplikasi manajemen antrian pernikahan KUA (Kantor Urusan Agama) dengan integrasi Dukcapil menggunakan Firebase sebagai backend dan Flutter untuk frontend mobile.

## 🚀 Fitur Utama

- **Multi-Role Authentication**: Superadmin, Admin KUA, Admin Dukcapil, dan User
- **Workflow Management**: Status tracking dari created → processed → validated → finished/rejected
- **Document Upload**: Upload KK, akta kelahiran, dan foto
- **WhatsApp Notifications**: Notifikasi otomatis untuk setiap perubahan status
- **Real-time Updates**: Menggunakan Firestore untuk real-time data sync
- **Cloud Functions**: Automated workflow dan business logic

## 📋 Arsitektur

```
┌─────────────┐
│   Flutter   │  ← Frontend Mobile App
│     App     │
└──────┬──────┘
       │
       ↓
┌─────────────────────────────────────┐
│      Firebase Emulator Suite        │
├─────────────┬───────────┬───────────┤
│  Firestore  │   Auth    │  Storage  │
│   (8282)    │  (9190)   │  (9292)   │
├─────────────┴───────────┴───────────┤
│      Cloud Functions (5100)         │
│  - Workflow Automation              │
│  - WhatsApp Integration             │
└─────────────────────────────────────┘
       │
       ↓
┌─────────────────────────────────────┐
│     Docker + Portainer (VPS)        │
└─────────────────────────────────────┘
```

## 🛠️ Tech Stack

- **Backend**: Firebase (Firestore, Auth, Storage, Functions)
- **Frontend**: Flutter (Dart)
- **Infrastructure**: Docker, Portainer, VPS Ubuntu
- **CI/CD**: GitHub Actions
- **Notifications**: WhatsApp API (Fonnte/Wablas/WhatsApp Business API)

## 📦 Struktur Proyek

```
kua-waiting-list/
├── backend/
│   ├── firebase.json              # Firebase configuration
│   ├── .firebaserc                # Firebase project config
│   ├── firestore.rules            # Firestore security rules
│   ├── firestore.indexes.json     # Firestore indexes
│   ├── storage.rules              # Storage security rules
│   └── functions/
│       ├── package.json
│       ├── index.js               # Cloud Functions
│       └── .env.example
├── frontend/
│   └── (Flutter app - coming soon)
├── docker/
│   └── emulators.Dockerfile       # Dockerfile for Firebase Emulator
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions CI/CD
├── docker-compose.yml             # For local development
├── docker-stack.yml               # For Portainer deployment
├── build.sh                       # Build script
├── cleanup-docker.sh              # Cleanup script
└── .env.example                   # Environment variables template
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 18+ (untuk local development)
- Firebase CLI (untuk local development)
- Git

### Local Development

1. **Clone repository**
   ```bash
   git clone https://github.com/Nasruladtri/kua-waiting-list.git
   cd kua-waiting-list
   ```

2. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env dengan konfigurasi Anda
   ```

3. **Install Cloud Functions dependencies**
   ```bash
   cd backend/functions
   npm install
   cd ../..
   ```

4. **Run dengan Docker Compose**
   ```bash
   docker-compose up -d
   ```

5. **Access Emulator UI**
   - Buka browser: http://localhost:4100
   - Firestore: http://localhost:8282
   - Auth: http://localhost:9190
   - Storage: http://localhost:9292
   - Functions: http://localhost:5100

### Production Deployment (Portainer)

1. **Build Docker image**
   ```bash
   chmod +x build.sh
   ./build.sh v1.0.0
   ```

2. **Push to Docker Hub**
   - Script akan menanyakan apakah ingin push ke registry
   - Atau manual: `docker push yourusername/kua-waiting-list:v1.0.0`

3. **Deploy di Portainer**
   - Login ke Portainer
   - Stacks → Add Stack
   - Paste isi dari `docker-stack.yml`
   - Set environment variables:
     - `GCP_PROJECT`
     - `APP_ENV`
     - `DOCKER_IMAGE`
     - `WHATSAPP_API_URL`
     - `WHATSAPP_API_KEY`
   - Deploy stack

4. **Setup GitHub Actions (Optional - Auto Deploy)**
   - Tambahkan secrets di GitHub repository:
     - `DOCKER_USERNAME`: Docker Hub username
     - `DOCKER_PASSWORD`: Docker Hub password/token
     - `PORTAINER_WEBHOOK_URL`: Portainer webhook URL
   - Push ke branch `main` akan otomatis build dan deploy

## 🔐 Environment Variables

### Required

```bash
GCP_PROJECT=kua-waiting-list-dev
APP_ENV=development
```

### Optional (WhatsApp Integration)

```bash
# Untuk Fonnte
WHATSAPP_API_URL=https://api.fonnte.com/send
WHATSAPP_API_KEY=your_fonnte_api_key

# Untuk Wablas
WHATSAPP_API_URL=https://console.wablas.com/api/send-message
WHATSAPP_API_KEY=your_wablas_api_key

# Untuk WhatsApp Business API
WHATSAPP_API_URL=https://graph.facebook.com/v18.0/YOUR_PHONE_NUMBER_ID/messages
WHATSAPP_API_KEY=Bearer YOUR_ACCESS_TOKEN
```

## 👥 User Roles

### 1. Superadmin
- Full access ke semua fitur
- Manajemen user dan role
- View semua aplikasi
- Analytics dan reports

### 2. Admin KUA
- View semua aplikasi pernikahan
- Update status ke `processed`
- Kirim notifikasi manual

### 3. Admin Dukcapil
- View aplikasi yang perlu validasi
- Update status ke `validated` atau `rejected`
- Validasi data kependudukan

### 4. User
- Submit aplikasi pernikahan
- Upload dokumen (KK, akta, foto)
- Track status aplikasi
- Update aplikasi yang masih status `created`

## 📊 Database Schema

### Collection: `users`
```javascript
{
  uid: string,
  email: string,
  name: string,
  phone: string,
  role: 'superadmin' | 'admin_kua' | 'admin_dukcapil' | 'user',
  createdAt: timestamp,
  createdBy: string (optional)
}
```

### Collection: `marriageApplications`
```javascript
{
  id: string,
  userId: string,
  status: 'created' | 'processed' | 'validated' | 'finished' | 'rejected',
  groomData: {
    name: string,
    nik: string,
    birthDate: date,
    address: string,
    ...
  },
  brideData: {
    name: string,
    nik: string,
    birthDate: date,
    address: string,
    ...
  },
  documents: {
    groomKK: string (storage path),
    groomAkta: string (storage path),
    brideKK: string (storage path),
    brideAkta: string (storage path),
    photo: string (storage path)
  },
  rejectionReason: string (optional),
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Collection: `logs`
```javascript
{
  id: string,
  applicationId: string,
  action: string,
  userId: string,
  details: object,
  timestamp: timestamp
}
```

## 🔧 Cloud Functions

### Triggers

- **onApplicationCreated**: Kirim notifikasi saat aplikasi baru dibuat
- **onStatusChanged**: Kirim notifikasi saat status berubah

### Callable Functions

- **createUser**: Create user dengan role (hanya superadmin)
- **sendNotification**: Kirim WhatsApp notification manual (admin only)

## 📱 Frontend (Coming Soon)

Flutter app dengan fitur:
- Login/Register
- Multi-role dashboard
- Form pengajuan pernikahan
- Upload dokumen
- Status tracking
- Profile management

## 🐛 Troubleshooting

### Emulator tidak bisa diakses dari luar

Pastikan firewall VPS membuka port:
```bash
sudo ufw allow 4100/tcp
sudo ufw allow 8282/tcp
sudo ufw allow 9190/tcp
sudo ufw allow 9292/tcp
sudo ufw allow 5100/tcp
```

### Cloud Functions error

Check logs:
```bash
docker logs kua-firebase-emulator
```

### WhatsApp notification tidak terkirim

1. Cek environment variables `WHATSAPP_API_URL` dan `WHATSAPP_API_KEY`
2. Cek logs Cloud Functions
3. Pastikan nomor telepon format benar (62xxx)

## 📝 License

MIT License - see LICENSE file for details

## 👨‍💻 Author

Nasrul Aditri - [GitHub](https://github.com/Nasruladtri)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

**Status**: ✅ Backend Ready | 🚧 Frontend In Development
