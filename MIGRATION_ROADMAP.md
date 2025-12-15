# Roadmap de Migração Dunamys

Este documento serve como guia para transformar o projeto atual (`dunamys`) em uma réplica exata do projeto de referência (`flutterflow_reference`), mantendo a Clean Architecture.

## 1. 🎨 Fundação e Tema
- [x] Configurar `AppTheme` com cores do FlutterFlow.
- [ ] **Ajuste Fino:** Verificar se todas as fontes (Poppins, Inter) e tamanhos de texto correspondem exatamente ao `FlutterFlowTheme`.
- [ ] Garantir que `AppTheme` exporte todas as cores customizadas (`amarelo`, `secondaryColor1`, etc.).

## 2. 🧩 Componentes Globais (Prioridade Alta)
Estes componentes aparecem em múltiplas telas e são essenciais para a navegação e identidade visual.
- [ ] **Navbar (Barra Inferior):** Portar o `NavbarWidget` customizado do FlutterFlow (design flutuante/arredondado).
- [ ] **EndDrawer (Menu Lateral):** Portar o `EndrawerCompWidget` (Perfil, Configurações, Logout).
- [ ] **Componentes de Carrinho:** Portar `Cartmenucomponent` e `ComponentCartUser`.

## 3. 📱 Telas do Usuário (Fluxo Principal)

### A. Navegação e Home
- [ ] **Home:**
    - [ ] Ajustar Padding/Espaçamento do Header.
    - [ ] Implementar `EndDrawer`.
    - [ ] Implementar `Navbar` flutuante.
    - [ ] Verificar suporte a vídeo no Carrossel (se necessário).

### B. Cardápio e Pedidos
- [ ] **Detalhes do Item (`item_details`):**
    - [ ] Layout com imagem expandida.
    - [ ] Seleção de adicionais (`AdicionalComponent`).
    - [ ] Botão de adicionar ao carrinho.
- [ ] **Categoria de Itens (`item_category`):**
    - [ ] Listagem completa de produtos da categoria.
- [ ] **Carrinho (`cart_users`):**
    - [ ] Lista de itens adicionados.
    - [ ] Resumo de valores.
- [ ] **Checkout:**
    - [ ] Fluxo de pagamento (`payment_user`).
    - [ ] Tela de PIX (`pagamento_p_i_x`).
- [ ] **Sucesso (`order_done`):** Tela de confirmação.

### C. Área do Cliente
- [ ] **Meus Pedidos (`myorders`):** Listagem de histórico.
- [ ] **Perfil (`perfil_user`):** Edição de dados.
- [ ] **FAQ (`faqpage`):** Perguntas frequentes.
- [ ] **Feedback (`feedback`):** Avaliação.
- [ ] **SAC (`sac`):** Suporte.
- [ ] **Mapas (`maps`):** Localização.

### D. Funcionalidades Específicas
- [ ] **Reservas de Quarto (`room`):** Visualização e seleção.

## 4. 🛠️ Telas Administrativas
- [ ] **Dashboard Admin:** Acesso restrito.
- [ ] **Gestão de Produtos:** Cadastro (`register_product`), edição, listagem.
- [ ] **Gestão de Categorias:** Cadastro (`cadastrar_categoria`), edição.
- [ ] **Gestão de Pedidos:** Acompanhamento (`order_clientes`, `detail_order`).
- [ ] **Gestão de Estoque:** Controle (`estoquelist`).
- [ ] **Gestão de Conteúdo:** FAQ, Fotos.

## 5. 🔄 Lógica e Integração
- [ ] Migrar lógica de `FFAppState` para Providers/Cubits.
- [ ] Garantir persistência de carrinho e sessão.
- [ ] Integração completa com Firebase (Auth, Firestore, Storage).
