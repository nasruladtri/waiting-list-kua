# API Documentation - KUA Waiting List

## Cloud Functions API

Base URL (Emulator): `http://localhost:5100/kua-waiting-list-dev/us-central1`

### Authentication

All callable functions require Firebase Authentication token.

---

## Callable Functions

### 1. createUser

Create a new user with specific role (Superadmin only).

**Endpoint**: `createUser`

**Method**: Callable Function

**Authorization**: Superadmin only

**Request Body**:
```json
{
  "email": "string",
  "password": "string",
  "name": "string",
  "phone": "string",
  "role": "superadmin" | "admin_kua" | "admin_dukcapil" | "user"
}
```

**Response**:
```json
{
  "success": true,
  "userId": "string",
  "message": "User created successfully"
}
```

**Errors**:
- `unauthenticated`: User not logged in
- `permission-denied`: Only superadmin can create users
- `invalid-argument`: Missing required fields or invalid role

**Example (Flutter)**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('createUser');
final result = await callable.call({
  'email': 'admin@kua.go.id',
  'password': 'password123',
  'name': 'Admin KUA',
  'phone': '081234567890',
  'role': 'admin_kua',
});
```

---

### 2. sendNotification

Send manual WhatsApp notification (Admin only).

**Endpoint**: `sendNotification`

**Method**: Callable Function

**Authorization**: Admin (superadmin, admin_kua, admin_dukcapil)

**Request Body**:
```json
{
  "phoneNumber": "string",
  "message": "string"
}
```

**Response**:
```json
{
  "success": true,
  "data": {}
}
```

**Errors**:
- `unauthenticated`: User not logged in
- `permission-denied`: Only admins can send notifications
- `invalid-argument`: Missing phone number or message

**Example (Flutter)**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
final result = await callable.call({
  'phoneNumber': '081234567890',
  'message': 'Pengajuan Anda telah diproses',
});
```

---

## Firestore Triggers

### 1. onApplicationCreated

Automatically triggered when a new marriage application is created.

**Trigger**: `onCreate` on `marriageApplications/{applicationId}`

**Actions**:
1. Get user data from Firestore
2. Send WhatsApp notification to user
3. Send WhatsApp notification to Admin KUA
4. Create log entry

**Notification to User**:
```
Halo {userName},

Pengajuan pernikahan Anda telah berhasil didaftarkan.
ID Aplikasi: {applicationId}
Status: Menunggu Proses

Kami akan menginformasikan perkembangan selanjutnya.

Terima kasih,
KUA
```

**Notification to Admin KUA**:
```
Pengajuan pernikahan baru:

ID: {applicationId}
Pemohon: {userName}
Calon Suami: {groomName}
Calon Istri: {brideName}

Silakan proses di aplikasi KUA.
```

---

### 2. onStatusChanged

Automatically triggered when application status changes.

**Trigger**: `onUpdate` on `marriageApplications/{applicationId}`

**Actions**:
1. Check if status changed
2. Get user data
3. Send appropriate WhatsApp notification based on new status
4. Create log entry

**Notifications by Status**:

**Status: processed**
```
Halo {userName},

Pengajuan pernikahan Anda (ID: {applicationId}) sedang diproses oleh KUA.

Status: Dalam Proses

Terima kasih,
KUA
```

**Status: validated**
```
Halo {userName},

Pengajuan pernikahan Anda (ID: {applicationId}) telah divalidasi oleh Dukcapil.

Status: Tervalidasi

Terima kasih,
KUA
```

**Status: finished**
```
Halo {userName},

Selamat! Pengajuan pernikahan Anda (ID: {applicationId}) telah selesai diproses.

Status: Selesai

Silakan datang ke KUA untuk proses selanjutnya.

Terima kasih,
KUA
```

**Status: rejected**
```
Halo {userName},

Mohon maaf, pengajuan pernikahan Anda (ID: {applicationId}) ditolak.

Status: Ditolak
Alasan: {rejectionReason}

Silakan hubungi KUA untuk informasi lebih lanjut.

Terima kasih,
KUA
```

---

## Environment Variables

### WhatsApp API Configuration

Set these environment variables in `backend/functions/.env`:

**For Fonnte**:
```bash
WHATSAPP_API_URL=https://api.fonnte.com/send
WHATSAPP_API_KEY=your_fonnte_api_key
```

**For Wablas**:
```bash
WHATSAPP_API_URL=https://console.wablas.com/api/send-message
WHATSAPP_API_KEY=your_wablas_api_key
```

**For WhatsApp Business API**:
```bash
WHATSAPP_API_URL=https://graph.facebook.com/v18.0/YOUR_PHONE_NUMBER_ID/messages
WHATSAPP_API_KEY=Bearer YOUR_ACCESS_TOKEN
```

---

## Error Handling

All functions use try-catch blocks and return appropriate error messages.

**Common Error Responses**:
- `unauthenticated`: User not logged in
- `permission-denied`: Insufficient permissions
- `invalid-argument`: Invalid or missing parameters
- `internal`: Server error

---

## Testing with Emulator

1. Start Firebase Emulator:
   ```bash
   cd backend
   firebase emulators:start
   ```

2. Access Functions at: `http://localhost:5100`

3. Use Emulator UI to test triggers: `http://localhost:4100`

4. Call functions from Flutter app using emulator host:
   ```dart
   FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5100);
   ```
