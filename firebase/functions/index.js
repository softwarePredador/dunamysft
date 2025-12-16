const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

// Configuração de ambiente - usa variáveis do Firebase Config ou valores padrão (sandbox)
const IS_PRODUCTION = functions.config().cielo?.environment === "production";

// Credenciais Cielo - usa firebase functions:config:set para configurar em produção
const CIELO_MERCHANT_ID = functions.config().cielo?.merchant_id || "8937bd5b-9796-494d-9fe5-f76b3e4da633";
const CIELO_MERCHANT_KEY = functions.config().cielo?.merchant_key || "XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV";

// URLs da Cielo baseadas no ambiente
const CIELO_QUERY_URL = IS_PRODUCTION
  ? "https://apiquery.cieloecommerce.cielo.com.br/1/sales/"
  : "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/";

/**
 * Webhook para receber notificações de pagamento da Cielo
 * 
 * URL para configurar na Cielo:
 * https://[REGION]-[PROJECT_ID].cloudfunctions.net/cieloWebhook
 * 
 * A Cielo envia POST com:
 * {
 *   "PaymentId": "8e20285d-0fe8-4b03-9219-65b2ff258eb3",
 *   "ChangeType": "1" // 1 = Pagamento, 2 = Recorrência
 * }
 */
exports.cieloWebhook = functions.https.onRequest(async (req, res) => {
  // Apenas aceita POST
  if (req.method !== "POST") {
    console.log("Method not allowed:", req.method);
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const { PaymentId, ChangeType } = req.body;

    console.log("Cielo Webhook received:", { PaymentId, ChangeType });

    if (!PaymentId) {
      console.log("Missing PaymentId");
      return res.status(400).send("Missing PaymentId");
    }

    // ChangeType 1 = Pagamento
    if (ChangeType !== "1" && ChangeType !== 1) {
      console.log("ChangeType not payment:", ChangeType);
      return res.status(200).send("OK - Not a payment notification");
    }

    // Busca o pedido pelo paymentId
    const ordersSnapshot = await firestore
      .collection("order")
      .where("paymentId", "==", PaymentId)
      .limit(1)
      .get();

    if (ordersSnapshot.empty) {
      console.log("Order not found for PaymentId:", PaymentId);
      return res.status(404).send("Order not found");
    }

    const orderDoc = ordersSnapshot.docs[0];
    const orderData = orderDoc.data();

    console.log("Found order:", orderDoc.id, orderData.status);

    // Se já foi pago, ignora
    if (orderData.paymentStatus === "paid") {
      console.log("Order already paid:", orderDoc.id);
      return res.status(200).send("OK - Already paid");
    }

    // Consulta status na Cielo para confirmar
    const axios = require("axios");
    const cieloResponse = await axios.get(
      `${CIELO_QUERY_URL}${PaymentId}`,
      {
        headers: {
          "Content-Type": "application/json",
          "MerchantId": CIELO_MERCHANT_ID,
          "MerchantKey": CIELO_MERCHANT_KEY,
        },
      }
    );

    const paymentStatus = cieloResponse.data?.Payment?.Status;
    console.log("Cielo payment status:", paymentStatus);

    // Status 2 = Pago/Confirmado
    if (paymentStatus === 2) {
      await orderDoc.ref.update({
        paymentStatus: "paid",
        status: "confirmed",
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Order updated to paid:", orderDoc.id);

      // Opcional: Enviar push notification para o usuário
      // await sendPaymentConfirmationPush(orderData);

      return res.status(200).send("OK - Payment confirmed");
    }

    // Status 10 = Cancelado, 11 = Refunded, 13 = Aborted
    if ([10, 11, 13].includes(paymentStatus)) {
      await orderDoc.ref.update({
        paymentStatus: "cancelled",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Order updated to cancelled:", orderDoc.id);
      return res.status(200).send("OK - Payment cancelled");
    }

    console.log("Payment status not final:", paymentStatus);
    return res.status(200).send("OK - Status noted");

  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(500).send("Internal Server Error");
  }
});

/**
 * Função auxiliar para verificar pagamento manualmente
 * Pode ser chamada via Cloud Function ou agendada
 */
exports.checkPendingPayments = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async (context) => {
    try {
      const axios = require("axios");
      
      // Busca pedidos pendentes com PIX criados há mais de 1 minuto
      const oneMinuteAgo = new Date(Date.now() - 60 * 1000);
      
      const pendingOrders = await firestore
        .collection("order")
        .where("paymentStatus", "==", "pending")
        .where("paymentMethod", "==", "Pix")
        .get();

      console.log(`Found ${pendingOrders.size} pending PIX orders`);

      for (const doc of pendingOrders.docs) {
        const order = doc.data();
        const paymentId = order.paymentId;

        if (!paymentId) continue;

        try {
          const cieloResponse = await axios.get(
            `${CIELO_QUERY_URL}${paymentId}`,
            {
              headers: {
                "Content-Type": "application/json",
                "MerchantId": CIELO_MERCHANT_ID,
                "MerchantKey": CIELO_MERCHANT_KEY,
              },
            }
          );

          const status = cieloResponse.data?.Payment?.Status;

          if (status === 2) {
            await doc.ref.update({
              paymentStatus: "paid",
              status: "confirmed",
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Order ${doc.id} marked as paid`);
          } else if ([10, 11, 13].includes(status)) {
            await doc.ref.update({
              paymentStatus: "cancelled",
            });
            console.log(`Order ${doc.id} marked as cancelled`);
          }
        } catch (err) {
          console.error(`Error checking order ${doc.id}:`, err.message);
        }
      }

      return null;
    } catch (error) {
      console.error("checkPendingPayments error:", error);
      return null;
    }
  });

/**
 * HTTP endpoint para verificar pagamento manualmente (debug)
 */
exports.checkPayment = functions.https.onRequest(async (req, res) => {
  const { paymentId } = req.query;

  if (!paymentId) {
    return res.status(400).json({ error: "Missing paymentId" });
  }

  try {
    const axios = require("axios");
    const cieloResponse = await axios.get(
      `${CIELO_QUERY_URL}${paymentId}`,
      {
        headers: {
          "Content-Type": "application/json",
          "MerchantId": CIELO_MERCHANT_ID,
          "MerchantKey": CIELO_MERCHANT_KEY,
        },
      }
    );

    return res.status(200).json({
      status: cieloResponse.data?.Payment?.Status,
      amount: cieloResponse.data?.Payment?.Amount,
      type: cieloResponse.data?.Payment?.Type,
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * Cloud Function para enviar Push Notification para um usuário específico
 * Chamada via httpsCallable do Flutter
 */
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  const { userId, title, body, data: notificationData } = data;

  if (!userId || !title || !body) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: userId, title, body"
    );
  }

  try {
    // Busca tokens FCM do usuário
    const userDoc = await firestore.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      console.log("User not found:", userId);
      return { success: false, error: "User not found" };
    }

    const userData = userDoc.data();
    const tokens = userData.fcm_tokens || [];

    if (tokens.length === 0) {
      console.log("No FCM tokens for user:", userId);
      return { success: false, error: "No FCM tokens" };
    }

    // Prepara a mensagem
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      tokens: tokens,
    };

    // Envia para todos os tokens do usuário
    const response = await admin.messaging().sendEachForMulticast(message);

    console.log(`Notification sent: ${response.successCount} success, ${response.failureCount} failures`);

    // Remove tokens inválidos
    if (response.failureCount > 0) {
      const tokensToRemove = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errorCode = resp.error?.code;
          if (
            errorCode === "messaging/invalid-registration-token" ||
            errorCode === "messaging/registration-token-not-registered"
          ) {
            tokensToRemove.push(tokens[idx]);
          }
        }
      });

      if (tokensToRemove.length > 0) {
        await firestore.collection("users").doc(userId).update({
          fcm_tokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
        });
        console.log("Removed invalid tokens:", tokensToRemove);
      }
    }

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Cloud Function para adicionar token FCM ao usuário
 * Chamada via httpsCallable do Flutter
 */
exports.addFcmToken = functions.https.onCall(async (data, context) => {
  // Verifica autenticação
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { token } = data;
  const userId = context.auth.uid;

  if (!token) {
    throw new functions.https.HttpsError("invalid-argument", "Missing token");
  }

  try {
    await firestore.collection("users").doc(userId).set(
      {
        fcm_tokens: admin.firestore.FieldValue.arrayUnion(token),
      },
      { merge: true }
    );

    console.log("FCM token added for user:", userId);
    return { success: true };
  } catch (error) {
    console.error("Error adding FCM token:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Trigger: Envia notificação quando status do pedido é alterado
 */
exports.onOrderStatusChange = functions.firestore
  .document("order/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const orderId = context.params.orderId;

    // Verifica se o status mudou
    if (before.status === after.status) {
      return null;
    }

    const userId = after.userId || after.userRef?.id;
    if (!userId) {
      console.log("No userId in order:", orderId);
      return null;
    }

    // Busca tokens do usuário
    const userDoc = await firestore.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.log("User not found:", userId);
      return null;
    }

    const tokens = userDoc.data().fcm_tokens || [];
    if (tokens.length === 0) {
      console.log("No FCM tokens for user:", userId);
      return null;
    }

    // Define mensagem baseada no status
    let title, body;
    switch (after.status) {
      case "confirmed":
        title = "Pedido Confirmado! 🎉";
        body = "Seu pedido foi confirmado e está sendo preparado.";
        break;
      case "preparing":
        title = "Preparando seu Pedido 👨‍🍳";
        body = "Seu pedido está sendo preparado com carinho.";
        break;
      case "ready":
        title = "Pedido Pronto! 🍽️";
        body = "Seu pedido está pronto e será entregue em breve.";
        break;
      case "delivered":
        title = "Pedido Entregue! ✅";
        body = "Seu pedido foi entregue. Bom apetite!";
        break;
      case "cancelled":
        title = "Pedido Cancelado 😔";
        body = "Seu pedido foi cancelado.";
        break;
      default:
        return null;
    }

    const message = {
      notification: { title, body },
      data: { orderId, type: "order_update", status: after.status },
      tokens: tokens,
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Order ${orderId} status notification sent: ${response.successCount} success`);
    } catch (error) {
      console.error("Error sending order notification:", error);
    }

    return null;
  });
