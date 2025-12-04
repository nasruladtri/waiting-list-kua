# Database Schema - KUA Waiting List

## Firestore Collections

### 1. users

Menyimpan data user dengan role-based access.

**Collection Path**: `/users/{userId}`

**Document ID**: Firebase Auth UID

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | ✅ | Email address user |
| name | string | ✅ | Nama lengkap user |
| phone | string | ✅ | Nomor telepon (format: 08xxxxxxxxxx) |
| role | string | ✅ | Role user: `superadmin`, `admin_kua`, `admin_dukcapil`, `user` |
| createdAt | timestamp | ✅ | Waktu pembuatan akun |
| createdBy | string | ❌ | UID user yang membuat (untuk admin) |

**Example Document**:
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "081234567890",
  "role": "user",
  "createdAt": "2024-12-04T10:00:00Z",
  "createdBy": null
}
```

**Indexes**: None (queries by UID)

**Security Rules**:
- Read: All authenticated users
- Create: Self-registration only
- Update: Owner or superadmin
- Delete: Superadmin only

---

### 2. marriageApplications

Menyimpan data pengajuan pernikahan.

**Collection Path**: `/marriageApplications/{applicationId}`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | ✅ | UID user yang mengajukan |
| status | string | ✅ | Status: `created`, `processed`, `validated`, `finished`, `rejected` |
| groomData | object | ✅ | Data calon suami |
| brideData | object | ✅ | Data calon istri |
| documents | object | ✅ | URL dokumen yang diupload |
| rejectionReason | string | ❌ | Alasan penolakan (jika status = rejected) |
| createdAt | timestamp | ✅ | Waktu pengajuan dibuat |
| updatedAt | timestamp | ✅ | Waktu terakhir diupdate |

**groomData / brideData Object**:
```json
{
  "name": "string",
  "nik": "string (16 digits)",
  "birthDate": "timestamp",
  "birthPlace": "string",
  "address": "string",
  "religion": "string",
  "occupation": "string",
  "fatherName": "string",
  "motherName": "string"
}
```

**documents Object**:
```json
{
  "groomKK": "string (Storage URL)",
  "groomAkta": "string (Storage URL)",
  "brideKK": "string (Storage URL)",
  "brideAkta": "string (Storage URL)",
  "photo": "string (Storage URL)"
}
```

**Example Document**:
```json
{
  "userId": "abc123",
  "status": "created",
  "groomData": {
    "name": "Ahmad Sulaiman",
    "nik": "3201012345678901",
    "birthDate": "1995-05-15T00:00:00Z",
    "birthPlace": "Jakarta",
    "address": "Jl. Merdeka No. 123",
    "religion": "Islam",
    "occupation": "Karyawan Swasta",
    "fatherName": "Budi Santoso",
    "motherName": "Siti Aminah"
  },
  "brideData": {
    "name": "Fatimah Zahra",
    "nik": "3201012345678902",
    "birthDate": "1997-08-20T00:00:00Z",
    "birthPlace": "Bandung",
    "address": "Jl. Sudirman No. 456",
    "religion": "Islam",
    "occupation": "Guru",
    "fatherName": "Hasan Ali",
    "motherName": "Khadijah"
  },
  "documents": {
    "groomKK": "https://storage.googleapis.com/.../groom_kk.pdf",
    "groomAkta": "https://storage.googleapis.com/.../groom_akta.pdf",
    "brideKK": "https://storage.googleapis.com/.../bride_kk.pdf",
    "brideAkta": "https://storage.googleapis.com/.../bride_akta.pdf",
    "photo": "https://storage.googleapis.com/.../photo.jpg"
  },
  "rejectionReason": null,
  "createdAt": "2024-12-04T10:00:00Z",
  "updatedAt": "2024-12-04T10:00:00Z"
}
```

**Indexes**:

1. **By Status and Created Date**:
   - Fields: `status` (ASC), `createdAt` (DESC)
   - Use case: Get applications by status, sorted by newest

2. **By User and Created Date**:
   - Fields: `userId` (ASC), `createdAt` (DESC)
   - Use case: Get user's applications, sorted by newest

**Security Rules**:
- Read: Owner, all admins
- Create: Users only (with userId = auth.uid, status = 'created')
- Update:
  - Superadmin: all fields
  - Admin KUA: status to 'processed'
  - Admin Dukcapil: status to 'validated' or 'rejected'
  - User: own applications with status 'created'
- Delete: Superadmin only

---

### 3. logs

Menyimpan log aktivitas untuk audit trail.

**Collection Path**: `/logs/{logId}`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| applicationId | string | ❌ | ID aplikasi terkait (null untuk user management) |
| action | string | ✅ | Jenis aksi: `APPLICATION_CREATED`, `STATUS_PROCESSED`, `STATUS_VALIDATED`, `STATUS_REJECTED`, `STATUS_FINISHED`, `USER_CREATED` |
| userId | string | ✅ | UID user yang melakukan aksi |
| details | object | ❌ | Detail tambahan |
| timestamp | timestamp | ✅ | Waktu aksi dilakukan |

**Example Document**:
```json
{
  "applicationId": "xyz789",
  "action": "STATUS_VALIDATED",
  "userId": "admin_dukcapil_uid",
  "details": {
    "oldStatus": "processed",
    "newStatus": "validated"
  },
  "timestamp": "2024-12-04T11:00:00Z"
}
```

**Indexes**:

1. **By Application and Timestamp**:
   - Fields: `applicationId` (ASC), `timestamp` (DESC)
   - Use case: Get logs for specific application

**Security Rules**:
- Read: All admins
- Create: Authenticated users (via Cloud Functions)
- Update/Delete: Superadmin only

---

## Firebase Storage Structure

### marriage-documents

**Path**: `/marriage-documents/{userId}/{applicationId}/{fileName}`

**Files**:
- `groom_kk.pdf` - Kartu Keluarga calon suami
- `groom_akta.pdf` - Akta kelahiran calon suami
- `bride_kk.pdf` - Kartu Keluarga calon istri
- `bride_akta.pdf` - Akta kelahiran calon istri
- `photo.jpg` - Foto bersama

**Max Size**: 5MB per file

**Allowed Types**: `image/*`, `application/pdf`

**Security Rules**:
- Read: Owner, all admins
- Write: Owner only
- Delete: Owner, superadmin

---

### profile-pictures

**Path**: `/profile-pictures/{userId}/{fileName}`

**Files**: Profile pictures (format: `profile_{timestamp}.jpg`)

**Max Size**: 5MB

**Allowed Types**: `image/*`

**Security Rules**:
- Read: All authenticated users
- Write: Owner only
- Delete: Owner, superadmin

---

## Status Workflow

```
created (User creates application)
   ↓
processed (Admin KUA processes)
   ↓
validated (Admin Dukcapil validates)
   ↓
finished (Completed)

OR

rejected (Admin Dukcapil rejects)
```

**Status Descriptions**:
- `created`: Aplikasi baru dibuat, menunggu proses
- `processed`: Sedang diproses oleh Admin KUA
- `validated`: Telah divalidasi oleh Admin Dukcapil
- `finished`: Proses selesai
- `rejected`: Ditolak dengan alasan tertentu

---

## Query Examples

### Get user's applications
```javascript
db.collection('marriageApplications')
  .where('userId', '==', currentUserId)
  .orderBy('createdAt', 'desc')
  .get()
```

### Get applications by status
```javascript
db.collection('marriageApplications')
  .where('status', '==', 'processed')
  .orderBy('createdAt', 'desc')
  .get()
```

### Get application logs
```javascript
db.collection('logs')
  .where('applicationId', '==', applicationId)
  .orderBy('timestamp', 'desc')
  .get()
```

### Get users by role
```javascript
db.collection('users')
  .where('role', '==', 'admin_kua')
  .get()
```
