const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

// Credenciais Cielo - em produção, usar variáveis de ambiente
const CIELO_MERCHANT_ID = "8937bd5b-9796-494d-9fe5-f76b3e4da633";

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
      `https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/${PaymentId}`,
      {
        headers: {
          "Content-Type": "application/json",
          "MerchantId": CIELO_MERCHANT_ID,
          "MerchantKey": functions.config().cielo?.merchant_key || "XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV",
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
            `https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/${paymentId}`,
            {
              headers: {
                "Content-Type": "application/json",
                "MerchantId": CIELO_MERCHANT_ID,
                "MerchantKey": functions.config().cielo?.merchant_key || "XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV",
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
      `https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/${paymentId}`,
      {
        headers: {
          "Content-Type": "application/json",
          "MerchantId": CIELO_MERCHANT_ID,
          "MerchantKey": functions.config().cielo?.merchant_key || "XKGHUBSBKIRXKAVPSKWLVXYCLVJUGTNZLIHPUSYV",
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
