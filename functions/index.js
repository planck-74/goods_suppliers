const { onDocumentCreated } = require("firebase-functions/firestore");
const admin = require("firebase-admin");
const { getMessaging } = require("firebase-admin/messaging");

// Initialize Admin SDK properly
if (!admin.apps.length) {
      admin.initializeApp({
            projectId: "goods-for-exchange"
      });
}

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

                  // Build the message payload (updated format)
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

                  // Send to each token individually for better error handling
                  const messaging = getMessaging();
                  const results = [];
                  const invalidTokens = [];

                  for (let i = 0; i < tokens.length; i++) {
                        const token = tokens[i];
                        try {
                              const messageWithToken = {
                                    ...message,
                                    token: token
                              };

                              const result = await messaging.send(messageWithToken);
                              console.log(`✅ Message sent successfully to token ${i + 1}:`, result);
                              results.push({ success: true, messageId: result });
                        } catch (error) {
                              console.error(`❌ Failed to send to token ${i + 1}:`, error.code, error.message);

                              // Check if token is invalid
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

                  // More detailed error logging
                  if (error.code) {
                        console.error("Error code:", error.code);
                  }
                  if (error.message) {
                        console.error("Error message:", error.message);
                  }
                  if (error.stack) {
                        console.error("Error stack:", error.stack);
                  }
            }
      }
);