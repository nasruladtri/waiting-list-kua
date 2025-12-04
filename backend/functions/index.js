const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const db = admin.firestore();

/**
 * Helper function untuk kirim WhatsApp notification
 * Menggunakan API WhatsApp (contoh: Fonnte, Wablas, atau WhatsApp Business API)
 */
async function sendWhatsAppNotification(phoneNumber, message) {
    try {
        // Cek apakah WhatsApp API credentials tersedia
        const whatsappApiUrl = process.env.WHATSAPP_API_URL;
        const whatsappApiKey = process.env.WHATSAPP_API_KEY;

        if (!whatsappApiUrl || !whatsappApiKey) {
            console.log("WhatsApp API not configured, skipping notification");
            return { success: false, message: "WhatsApp API not configured" };
        }

        // Format nomor telepon (hapus karakter non-digit, tambahkan 62 jika perlu)
        let formattedPhone = phoneNumber.replace(/\D/g, "");
        if (formattedPhone.startsWith("0")) {
            formattedPhone = "62" + formattedPhone.substring(1);
        } else if (!formattedPhone.startsWith("62")) {
            formattedPhone = "62" + formattedPhone;
        }

        // Contoh untuk Fonnte API
        // Sesuaikan dengan provider yang digunakan
        const response = await axios.post(
            whatsappApiUrl,
            {
                target: formattedPhone,
                message: message,
            },
            {
                headers: {
                    "Authorization": whatsappApiKey,
                    "Content-Type": "application/json",
                },
            },
        );

        console.log("WhatsApp notification sent:", response.data);
        return { success: true, data: response.data };
    } catch (error) {
        console.error("Error sending WhatsApp notification:", error);
        return { success: false, error: error.message };
    }
}

/**
 * Helper function untuk create log entry
 */
async function createLog(applicationId, action, userId, details = {}) {
    try {
        await db.collection("logs").add({
            applicationId: applicationId,
            action: action,
            userId: userId,
            details: details,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Log created: ${action} for application ${applicationId}`);
    } catch (error) {
        console.error("Error creating log:", error);
    }
}

/**
 * Trigger saat marriage application baru dibuat
 * Kirim notifikasi WhatsApp ke user dan admin KUA
 */
exports.onApplicationCreated = functions.firestore
    .document("marriageApplications/{applicationId}")
    .onCreate(async (snap, context) => {
        const applicationData = snap.data();
        const applicationId = context.params.applicationId;

        try {
            // Get user data
            const userDoc = await db.collection("users").doc(applicationData.userId).get();
            const userData = userDoc.data();

            // Kirim notifikasi ke user
            const userMessage = `Halo ${userData.name},\n\n` +
                `Pengajuan pernikahan Anda telah berhasil didaftarkan.\n` +
                `ID Aplikasi: ${applicationId}\n` +
                `Status: Menunggu Proses\n\n` +
                `Kami akan menginformasikan perkembangan selanjutnya.\n\n` +
                `Terima kasih,\nKUA`;

            await sendWhatsAppNotification(userData.phone, userMessage);

            // Get admin KUA untuk notifikasi
            const adminKuaSnapshot = await db.collection("users")
                .where("role", "==", "admin_kua")
                .limit(1)
                .get();

            if (!adminKuaSnapshot.empty) {
                const adminKuaData = adminKuaSnapshot.docs[0].data();
                const adminMessage = `Pengajuan pernikahan baru:\n\n` +
                    `ID: ${applicationId}\n` +
                    `Pemohon: ${userData.name}\n` +
                    `Calon Suami: ${applicationData.groomData.name}\n` +
                    `Calon Istri: ${applicationData.brideData.name}\n\n` +
                    `Silakan proses di aplikasi KUA.`;

                await sendWhatsAppNotification(adminKuaData.phone, adminMessage);
            }

            // Create log
            await createLog(applicationId, "APPLICATION_CREATED", applicationData.userId, {
                groomName: applicationData.groomData.name,
                brideName: applicationData.brideData.name,
            });

            return { success: true };
        } catch (error) {
            console.error("Error in onApplicationCreated:", error);
            return { success: false, error: error.message };
        }
    });

/**
 * Trigger saat status marriage application berubah
 * Kirim notifikasi WhatsApp sesuai status baru
 */
exports.onStatusChanged = functions.firestore
    .document("marriageApplications/{applicationId}")
    .onUpdate(async (change, context) => {
        const beforeData = change.before.data();
        const afterData = change.after.data();
        const applicationId = context.params.applicationId;

        // Cek apakah status berubah
        if (beforeData.status === afterData.status) {
            return null;
        }

        try {
            // Get user data
            const userDoc = await db.collection("users").doc(afterData.userId).get();
            const userData = userDoc.data();

            let message = "";
            let logAction = "";

            switch (afterData.status) {
                case "processed":
                    message = `Halo ${userData.name},\n\n` +
                        `Pengajuan pernikahan Anda (ID: ${applicationId}) sedang diproses oleh KUA.\n\n` +
                        `Status: Dalam Proses\n\n` +
                        `Terima kasih,\nKUA`;
                    logAction = "STATUS_PROCESSED";
                    break;

                case "validated":
                    message = `Halo ${userData.name},\n\n` +
                        `Pengajuan pernikahan Anda (ID: ${applicationId}) telah divalidasi oleh Dukcapil.\n\n` +
                        `Status: Tervalidasi\n\n` +
                        `Terima kasih,\nKUA`;
                    logAction = "STATUS_VALIDATED";
                    break;

                case "finished":
                    message = `Halo ${userData.name},\n\n` +
                        `Selamat! Pengajuan pernikahan Anda (ID: ${applicationId}) telah selesai diproses.\n\n` +
                        `Status: Selesai\n\n` +
                        `Silakan datang ke KUA untuk proses selanjutnya.\n\n` +
                        `Terima kasih,\nKUA`;
                    logAction = "STATUS_FINISHED";
                    break;

                case "rejected":
                    message = `Halo ${userData.name},\n\n` +
                        `Mohon maaf, pengajuan pernikahan Anda (ID: ${applicationId}) ditolak.\n\n` +
                        `Status: Ditolak\n` +
                        `Alasan: ${afterData.rejectionReason || "Tidak disebutkan"}\n\n` +
                        `Silakan hubungi KUA untuk informasi lebih lanjut.\n\n` +
                        `Terima kasih,\nKUA`;
                    logAction = "STATUS_REJECTED";
                    break;

                default:
                    return null;
            }

            // Kirim notifikasi
            await sendWhatsAppNotification(userData.phone, message);

            // Create log
            await createLog(applicationId, logAction, afterData.userId, {
                oldStatus: beforeData.status,
                newStatus: afterData.status,
                rejectionReason: afterData.rejectionReason || null,
            });

            return { success: true };
        } catch (error) {
            console.error("Error in onStatusChanged:", error);
            return { success: false, error: error.message };
        }
    });

/**
 * Callable function untuk create user dengan role
 * Hanya bisa dipanggil oleh superadmin
 */
exports.createUser = functions.https.onCall(async (data, context) => {
    // Cek authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated",
        );
    }

    try {
        // Cek apakah caller adalah superadmin
        const callerDoc = await db.collection("users").doc(context.auth.uid).get();
        const callerData = callerDoc.data();

        if (callerData.role !== "superadmin") {
            throw new functions.https.HttpsError(
                "permission-denied",
                "Only superadmin can create users",
            );
        }

        // Validate input
        const { email, password, name, phone, role } = data;

        if (!email || !password || !name || !phone || !role) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Missing required fields",
            );
        }

        const validRoles = ["superadmin", "admin_kua", "admin_dukcapil", "user"];
        if (!validRoles.includes(role)) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Invalid role",
            );
        }

        // Create user di Firebase Auth
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
            displayName: name,
        });

        // Create user document di Firestore
        await db.collection("users").doc(userRecord.uid).set({
            email: email,
            name: name,
            phone: phone,
            role: role,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: context.auth.uid,
        });

        // Create log
        await createLog(null, "USER_CREATED", context.auth.uid, {
            newUserId: userRecord.uid,
            newUserEmail: email,
            newUserRole: role,
        });

        return {
            success: true,
            userId: userRecord.uid,
            message: "User created successfully",
        };
    } catch (error) {
        console.error("Error in createUser:", error);
        throw new functions.https.HttpsError(
            "internal",
            error.message,
        );
    }
});

/**
 * Callable function untuk manual send WhatsApp notification
 * Untuk testing atau custom notifications
 */
exports.sendNotification = functions.https.onCall(async (data, context) => {
    // Cek authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated",
        );
    }

    try {
        // Cek apakah caller adalah admin
        const callerDoc = await db.collection("users").doc(context.auth.uid).get();
        const callerData = callerDoc.data();

        if (!["superadmin", "admin_kua", "admin_dukcapil"].includes(callerData.role)) {
            throw new functions.https.HttpsError(
                "permission-denied",
                "Only admins can send notifications",
            );
        }

        const { phoneNumber, message } = data;

        if (!phoneNumber || !message) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Phone number and message are required",
            );
        }

        const result = await sendWhatsAppNotification(phoneNumber, message);

        return result;
    } catch (error) {
        console.error("Error in sendNotification:", error);
        throw new functions.https.HttpsError(
            "internal",
            error.message,
        );
    }
});
