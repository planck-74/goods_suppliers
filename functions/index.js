const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/firestore");
const admin = require("firebase-admin");
const { getMessaging } = require("firebase-admin/messaging");

// Initialize Admin SDK properly
if (!admin.apps.length) {
      admin.initializeApp({
            projectId: "goods-for-exchange"
      });
}

// Notify supplier when a new order is created
exports.sendNewOrderNotification = onDocumentCreated(
      {
            document: "orders/{orderId}",
            region: "europe-west1"
      },
      async (event) => {
            console.log("🚀 Triggered sendNewOrderNotification");
            console.log("Order ID:", event.params.orderId);

            const snap = event.data;
            const orderData = snap.data();
            const supplierId = orderData.supplierId;

            if (!supplierId) {
                  console.warn("❌ No supplierId in orderData");
                  return;
            }

            try {
                  // Get supplier document
                  const supplierRef = admin.firestore().collection("suppliers").doc(supplierId);
                  const supplierDoc = await supplierRef.get();

                  if (!supplierDoc.exists) {
                        console.warn("❌ Supplier doc not found for ID:", supplierId);
                        return;
                  }

                  const tokens = supplierDoc.data().fcmTokens || [];
                  console.log("Found tokens count:", tokens.length);

                  if (!Array.isArray(tokens) || tokens.length === 0) {
                        console.warn("❌ No valid FCM tokens for supplier:", supplierId);
                        return;
                  }

                  // Build the message payload
                  const message = {
                        notification: {
                              title: "🚨 طلب جديد!",
                              body: "في طلب جديد من عميل، راجع التفاصيل."
                        },
                        data: {
                              orderId: event.params.orderId,
                              supplierId: supplierId,
                              screen: "orderDetails"
                        },
                        android: {
                              notification: {
                                    sound: "default",
                                    priority: "high"
                              }
                        },
                        apns: {
                              payload: {
                                    aps: {
                                          sound: "default",
                                          badge: 1
                                    }
                              }
                        }
                  };

                  // Send to each token individually
                  const messaging = getMessaging();
                  const results = [];
                  const invalidTokens = [];

                  for (let i = 0; i < tokens.length; i++) {
                        const token = tokens[i];
                        try {
                              const messageWithToken = { ...message, token };
                              const result = await messaging.send(messageWithToken);
                              console.log(`✅ Message sent successfully to token ${i + 1}:`, result);
                              results.push({ success: true, messageId: result });
                        } catch (error) {
                              console.error(`❌ Failed to send to token ${i + 1}:`, error.code, error.message);
                              if (
                                    error.code === 'messaging/invalid-registration-token' ||
                                    error.code === 'messaging/registration-token-not-registered'
                              ) {
                                    invalidTokens.push(token);
                              }
                              results.push({ success: false, error: error.code });
                        }
                  }

                  // Clean up invalid tokens
                  if (invalidTokens.length > 0) {
                        await supplierRef.update({
                              fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
                        });
                        console.log("🗑 Removed invalid tokens:", invalidTokens.length);
                  }

                  console.log("📊 Final results:", {
                        total: tokens.length,
                        successful: results.filter(r => r.success).length,
                        failed: results.filter(r => !r.success).length,
                        invalidTokensRemoved: invalidTokens.length
                  });

            } catch (error) {
                  console.error("🔥 Critical error in function:", error);
                  if (error.code) console.error("Error code:", error.code);
                  if (error.message) console.error("Error message:", error.message);
                  if (error.stack) console.error("Error stack:", error.stack);
            }
      }
);// Enhanced debug version of sendOrderStateUpdateToClient
exports.sendOrderStateUpdateToClient = onDocumentUpdated(
      {
            document: "orders/{orderId}",
            region: "europe-west1"
      },
      async (event) => {
            console.log("🔄 Triggered sendOrderStateUpdateToClient");
            console.log("📋 Order ID:", event.params.orderId);

            const beforeData = event.data.before.data() || {};
            const afterData = event.data.after.data() || {};

            // Enhanced debugging - log entire document structure
            console.log("🔍 FULL BEFORE DATA:", JSON.stringify(beforeData, null, 2));
            console.log("🔍 FULL AFTER DATA:", JSON.stringify(afterData, null, 2));

            // Check various possible field names for state
            const possibleStateFields = ['states', 'state', 'status', 'orderState', 'orderStatus'];

            console.log("🔍 Checking possible state fields:");
            possibleStateFields.forEach(field => {
                  console.log(`  - ${field}: before="${beforeData[field]}", after="${afterData[field]}"`);
            });

            // Try to find the actual state field
            let stateField = null;
            let prevState = null;
            let newState = null;

            for (const field of possibleStateFields) {
                  if (beforeData.hasOwnProperty(field) || afterData.hasOwnProperty(field)) {
                        stateField = field;
                        prevState = (beforeData[field] || "").toString().trim();
                        newState = (afterData[field] || "").toString().trim();
                        console.log(`✅ Found state field: "${field}"`);
                        break;
                  }
            }

            if (!stateField) {
                  console.error("❌ No state field found in document. Available fields:");
                  console.log("  Before fields:", Object.keys(beforeData));
                  console.log("  After fields:", Object.keys(afterData));
                  return;
            }

            console.log(`📊 State comparison (${stateField}):`);
            console.log(`  Previous: "${prevState}"`);
            console.log(`  New: "${newState}"`);

            // Check for meaningful change
            if (!prevState || prevState === newState) {
                  console.log("ℹ️ No meaningful state change. Skipping notification.");
                  return;
            }

            const clientId = afterData.clientId;
            if (!clientId) {
                  console.warn("❌ No clientId found in order data");
                  console.log("Available fields:", Object.keys(afterData));
                  return;
            }

            console.log("👤 Client ID:", clientId);

            // Rest of your existing code...
            const clientRef = admin.firestore().collection("clients").doc(clientId);

            try {
                  const clientDoc = await clientRef.get();
                  if (!clientDoc.exists) {
                        console.warn("❌ Client doc not found:", clientId);
                        return;
                  }

                  const token = clientDoc.data().fcmToken;
                  if (!token || typeof token !== "string") {
                        console.warn("❌ No valid FCM token for client:", clientId);
                        return;
                  }

                  const message = {
                        token,
                        notification: {
                              title: "📦 حالة الطلب تغيّرت!",
                              body: `طلبك الآن "${newState}".`
                        },
                        data: {
                              orderId: event.params.orderId,
                              [stateField]: newState, // Use the actual field name
                              screen: "orderDetails"
                        },
                        android: { notification: { sound: "default", priority: "high" } },
                        apns: { payload: { aps: { sound: "default", badge: 1 } } }
                  };

                  const result = await getMessaging().send(message);
                  console.log("✅ Notification sent to client:", result);

            } catch (error) {
                  console.error("❌ Failed to send notification:", error.code, error.message);

                  if (
                        error.code === "messaging/invalid-registration-token" ||
                        error.code === "messaging/registration-token-not-registered"
                  ) {
                        await clientRef.update({ fcmToken: admin.firestore.FieldValue.delete() });
                        console.log("🗑 Removed invalid client token");
                  }
            }
      }
);