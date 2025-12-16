# Roadmap de Migração Dunamys

Este documento serve como guia para transformar o projeto atual (`dunamys`) em uma réplica exata do projeto de referência (`flutterflow_reference`), mantendo a Clean Architecture.

## 1. 🎨 Fundação e Tema
- [x] Configurar `AppTheme` com cores do FlutterFlow.
- [x] Verificar se todas as fontes (Poppins, Inter) e tamanhos de texto correspondem exatamente ao `FlutterFlowTheme`.
- [x] Garantir que `AppTheme` exporte todas as cores customizadas (`amarelo`, `secondaryColor1`, etc.).

## 2. 🧩 Componentes Globais (Prioridade Alta)
Estes componentes aparecem em múltiplas telas e são essenciais para a navegação e identidade visual.
- [x] **Navbar (Barra Inferior):** Portar o `NavbarWidget` customizado do FlutterFlow (design flutuante/arredondado).
- [x] **EndDrawer (Menu Lateral):** Portar o `EndrawerCompWidget` (Perfil, Configurações, Logout).
- [x] **Componentes de Carrinho:** `QuantityCounterWidget` e `FloatingCartWidget`.

## 3. 📱 Telas do Usuário (Fluxo Principal)

### A. Navegação e Home
- [x] **Home:**
    - [x] Ajustar Padding/Espaçamento do Header.
    - [x] Implementar `EndDrawer`.
    - [x] Implementar `Navbar` flutuante.
    - [ ] Verificar suporte a vídeo no Carrossel (se necessário).

### B. Cardápio e Pedidos
- [x] **Detalhes do Item (`item_details`):**
    - [x] Layout com imagem expandida.
    - [x] Seleção de adicionais (`AdicionalComponent`).
    - [x] Botão de adicionar ao carrinho.
- [ ] **Categoria de Itens (`item_category`):**
    - [ ] Listagem completa de produtos da categoria.
- [x] **Carrinho (`cart_users`):**
    - [x] Lista de itens adicionados.
    - [x] Resumo de valores.
- [x] **Checkout:**
    - [x] Fluxo de pagamento (`payment_user`).
    - [x] Tela de PIX (`pagamento_p_i_x`).
- [x] **Sucesso (`order_done`):** Tela de confirmação.

### C. Área do Cliente
- [x] **Meus Pedidos (`myorders`):** Listagem de histórico.
- [x] **Perfil (`perfil_user`):** Edição de dados.
- [x] **FAQ (`faqpage`):** Perguntas frequentes.
- [x] **Feedback (`feedback`):** Avaliação.
- [x] **SAC (`sac`):** Suporte via WhatsApp.
- [x] **Mapas (`maps`):** Localização com Google Maps.

### D. Funcionalidades Específicas
- [ ] **Reservas de Quarto (`room`):** Visualização e seleção.

## 4. 🛠️ Telas Administrativas
- [x] **Dashboard Admin:** Acesso restrito.
- [x] **Gestão de Produtos:** Cadastro (`admin_products_screen`), edição (`admin_product_form_screen`), listagem.
- [x] **Gestão de Categorias:** Cadastro/edição (`admin_categories_screen`).
- [x] **Gestão de Pedidos:** Acompanhamento (`admin_orders_screen`, `admin_order_detail_screen`).
- [x] **Gestão de Estoque:** Controle (`admin_stock_screen`).
- [x] **Gestão de Conteúdo:** FAQ (`admin_faq_screen`), Feedback (`admin_feedback_screen`).
- [ ] **Gestão de Mídia:** Fotos e vídeos.
- [ ] **Relatórios:** Relatório de pedidos.

## 5. 🔄 Lógica e Integração
- [x] Migrar lógica de `FFAppState` para Providers/Cubits.
- [x] Garantir persistência de carrinho e sessão.
- [x] Integração completa com Firebase (Auth, Firestore, Storage).
- [x] **Pagamentos Cielo:** Integração PIX e Cartão (Débito/Crédito).
- [x] **OrderProducts:** Salvar itens do pedido na collection `order_products`.
- [x] **Cloud Functions:** Webhook e verificação automática de pagamentos.

## 📊 Resumo do Progresso

### Telas de Usuário Implementadas
| Tela | Status | Localização |
|------|--------|-------------|
| Splash | ✅ | `lib/presentation/screens/splash/` |
| Login | ✅ | `lib/presentation/screens/login/` |
| Home | ✅ | `lib/presentation/screens/home/` |
| Menu | ✅ | `lib/presentation/screens/menu/` |
| Item Details | ✅ | `lib/presentation/screens/item_details/` |
| Cart | ✅ | `lib/presentation/screens/cart/` |
| Payment | ✅ | `lib/presentation/screens/payment/` |
| PIX Payment | ✅ | `lib/presentation/screens/pix_payment/` |
| Order Done | ✅ | `lib/presentation/screens/order_done/` |
| My Orders | ✅ | `lib/presentation/screens/orders/` |
| FAQ | ✅ | `lib/presentation/screens/faq/` |
| Feedback | ✅ | `lib/presentation/screens/feedback/` |
| Profile | ✅ | `lib/presentation/screens/profile/` |
| SAC | ✅ | `lib/presentation/screens/sac/` |
| Maps | ✅ | `lib/presentation/screens/maps/` |

### Telas Administrativas Implementadas
| Tela | Status | Localização |
|------|--------|-------------|
| Admin Dashboard | ✅ | `lib/presentation/screens/admin/admin_dashboard_screen.dart` |
| Admin Orders | ✅ | `lib/presentation/screens/admin/admin_orders_screen.dart` |
| Admin Order Detail | ✅ | `lib/presentation/screens/admin/admin_order_detail_screen.dart` |
| Admin Products | ✅ | `lib/presentation/screens/admin/admin_products_screen.dart` |
| Admin Product Form | ✅ | `lib/presentation/screens/admin/admin_product_form_screen.dart` |
| Admin Categories | ✅ | `lib/presentation/screens/admin/admin_categories_screen.dart` |
| Admin Stock | ✅ | `lib/presentation/screens/admin/admin_stock_screen.dart` |
| Admin Feedback | ✅ | `lib/presentation/screens/admin/admin_feedback_screen.dart` |
| Admin FAQ | ✅ | `lib/presentation/screens/admin/admin_faq_screen.dart` |

### Widgets Reutilizáveis
| Widget | Descrição | Localização |
|--------|-----------|-------------|
| EndDrawerWidget | Menu lateral | `lib/presentation/widgets/end_drawer_widget.dart` |
| NavbarWidget | Navegação inferior | `lib/presentation/widgets/navbar_widget.dart` |
| QuantityCounterWidget | Contador +/- | `lib/presentation/widgets/quantity_counter_widget.dart` |
| FloatingCartWidget | Carrinho flutuante | `lib/presentation/widgets/floating_cart_widget.dart` |

### Rotas Configuradas
```dart
// Rotas do Usuário
/              -> SplashScreen
/login         -> LoginScreen
/home          -> HomeScreen
/menu          -> MenuScreen
/item-details  -> ItemDetailsScreen (extra: MenuItemModel)
/cart          -> CartScreen
/payment       -> PaymentScreen
/pix-payment   -> PIXPaymentScreen (extra: orderId)
/order-done    -> OrderDoneScreen (extra: orderId)
/orders        -> MyOrdersScreen
/faq           -> FAQScreen
/feedback      -> FeedbackScreen
/profile       -> ProfileScreen
/sac           -> SACScreen
/maps          -> MapsScreen

// Rotas Administrativas
/admin                      -> AdminDashboardScreen
/admin/orders               -> AdminOrdersScreen
/admin/orders/:orderId      -> AdminOrderDetailScreen
/admin/products             -> AdminProductsScreen
/admin/products/new         -> AdminProductFormScreen
/admin/products/:productId  -> AdminProductFormScreen (edição)
/admin/categories           -> AdminCategoriesScreen
/admin/stock                -> AdminStockScreen
/admin/feedback             -> AdminFeedbackScreen
/admin/faq                  -> AdminFAQScreen
/admin/media                -> (Em breve)
/admin/reports              -> (Em breve)
```

### Próximos Passos
1. ⏳ Implementar reservas de quarto
2. ⏳ Adicionar gestão de mídia (fotos/vídeos)
3. ⏳ Implementar relatórios de pedidos
4. ⏳ Verificar suporte a vídeo no Carrossel
5. ✅ ~~Implementar telas SAC e Mapas~~ (Concluído)
6. ✅ ~~Integração Cielo (PIX/Cartão)~~ (Concluído)
7. ✅ ~~OrderProducts no Firebase~~ (Concluído)
8. ✅ ~~Cloud Functions para Webhooks~~ (Concluído)
