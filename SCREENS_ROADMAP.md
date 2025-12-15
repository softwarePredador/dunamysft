# ROADMAP DE VALIDAÇÃO DE TELAS

## FlutterFlow Reference → Migração Clean Architecture

---

## 📱 TELAS DO USUÁRIO (naomexermais/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 1 | `home/` | `home/` | ✅ OK | Galeria, categorias, badge |
| 2 | `item_category/` | `item_category/` | ✅ OK | Listagem por categoria |
| 3 | `item_details/` | `item_details/` | ✅ OK | Detalhes, adicionais, add cart |
| 4 | `cart_users/` | `cart/` | ✅ OK | Carrinho funcional |
| 5 | `menu/` | `menu/` | ✅ OK | Listagem com filtros (diferente FF) |
| 6 | `login/` | `login/` | ✅ OK | Google/Apple sign-in |
| 7 | `perfil_user/` | `profile/` | ✅ OK | Perfil do usuário |
| 8 | `myorders/` | `orders/` | ✅ OK | Histórico de pedidos |
| 9 | `feedback/` | `feedback/` | ✅ OK | Com FeedbackService |
| 10 | `faqpage/` | `faq/` | ✅ OK | FAQ funcional |
| 11 | `sac/` | `sac/` | ✅ CRIADO | Telefones, redes sociais |
| 12 | `maps/` | `maps/` | ✅ CRIADO | Curitiba e Londrina |
| 13 | `gallery_home/` | ❌ Não existe | ⏳ Pendente | Galeria de fotos |
| 14 | `local_selected/` | ❌ Não existe | ⏳ Pendente | Detalhe de local |
| 15 | `pagamento_p_i_x/` | `pix_payment/` | ✅ OK | QR Code PIX |

---

## 💳 TELAS DE PAGAMENTO/PEDIDO (ja_revisados/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 16 | `payment_user/` | `payment/` | ✅ OK | 2 etapas: Entrega + Pagamento |
| 17 | `order_done/` | `order_done/` | ✅ OK | Confirmação de pedido |
| 18 | `room/` | ❌ Não necessário | ✅ INTEGRADO | Integrado na tela Payment |
| 19 | `relatorio/` | ❌ Admin only | ⏳ | Relatórios admin |

---

## 🔧 TELAS ADMIN (admin/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 20 | `admin/` | `admin_dashboard/` | ✅ OK | Dashboard admin |
| 21 | `order_clientes/` | `admin_orders/` | ✅ OK | Lista pedidos |
| 22 | `detail_order/` | `admin_order_detail/` | ✅ OK | Detalhe pedido |
| 23 | `estoquelist/` | `admin_stock/` | ✅ OK | Gestão estoque |
| 24 | `register_product/` | `admin_product_form/` | ✅ OK | Cadastro produto |
| 25 | `cadastrar_categoria/` | `admin_categories/` | ✅ OK | Cadastro categoria |
| 26 | `faq_listagem/` | `admin_faq/` | ✅ OK | Gestão FAQ |
| 27 | `feedback_clients/` | `admin_feedback/` | ✅ OK | Lista feedbacks |

---

## 🧩 COMPONENTES (components/)

| # | FlutterFlow | Nossa Implementação | Status |
|---|-------------|---------------------|--------|
| C1 | `navbar/` | `navbar_widget.dart` | ✅ OK |
| C2 | `endrawer_comp/` | `end_drawer_widget.dart` | ✅ OK |

---

## 📊 RESUMO DE PROGRESSO

### ✅ Telas OK: 25/27
### ⏳ Pendentes: 2/27 (Gallery, LocalSelected)

---

## � INTEGRAÇÃO CIELO (PAGAMENTOS)

| Funcionalidade | Status | Arquivo |
|----------------|--------|---------|
| PIX - Gerar QR Code | ✅ OK | `payment_service.dart` |
| PIX - Polling Status | ✅ OK | `pix_payment_screen.dart` |
| Cartão Débito | ✅ OK | `payment_service.dart` |
| Cartão Crédito | ✅ OK | `payment_service.dart` |
| Detecção Bandeira | ✅ OK | `payment_service.dart` |

**Credenciais Sandbox:**
- MerchantId: `8937bd5b-9796-494d-9fe5-f76b3e4da633`
- URL: `apisandbox.cieloecommerce.cielo.com.br`

---

## 📦 ORDER_PRODUCTS (ITENS DO PEDIDO)

| Funcionalidade | Status | Arquivo |
|----------------|--------|---------|
| Model | ✅ OK | `order_product_model.dart` |
| Service | ✅ OK | `order_product_service.dart` |
| Salvar ao criar pedido | ✅ OK | `order_provider.dart` |

---

## �🔄 FLUXO PRINCIPAL VALIDADO

```
Login → Splash → Home
       ↓
Home → Category → ItemDetails → Cart → Payment
       ↓                                   ↓
       ↓                          PIX → OrderDone
       ↓                          Cartão → OrderDone
       ↓
EndDrawer → Profile, Orders, FAQ, Feedback, SAC, Maps
```

---

*Última atualização: 15/12/2025*
