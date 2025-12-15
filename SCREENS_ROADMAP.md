# ROADMAP DE VALIDAÇÃO DE TELAS

## FlutterFlow Reference → Migração Clean Architecture

---

## 📱 TELAS DO USUÁRIO (naomexermais/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 1 | `home/` | `home/` | ✅ Corrigido | Ver todos → /category/:id |
| 2 | `item_category/` | `item_category/` ✅ | ✅ Criado | Tela criada igual FF |
| 3 | `item_details/` | `item_details/` | ⏳ Validar | Precisa confirmar estrutura |
| 4 | `cart_users/` | `cart/` | ⏳ Validar | Botão "Continuar" corrigido |
| 5 | `menu/` | ❌ Não existe | ❌ Verificar | O que é menu no FF? |
| 6 | `login/` | `login/` | ⏳ Validar | |
| 7 | `perfil_user/` | `profile/` | ⏳ Validar | |
| 8 | `myorders/` | `orders/` | ⏳ Validar | |
| 9 | `feedback/` | `feedback/` | ⏳ Validar | |
| 10 | `faqpage/` | `faq/` | ⏳ Validar | |
| 11 | `sac/` | ❌ Não existe | ❌ Criar | |
| 12 | `maps/` | ❌ Não existe | ❌ Criar | |
| 13 | `gallery_home/` | ❌ Não existe | ❌ Criar | Galeria de fotos |
| 14 | `local_selected/` | ❌ Não existe | ❌ Criar | Seleção de local |
| 15 | `pagamento_p_i_x/` | `pix_payment/` | ⏳ Validar | |

---

## 💳 TELAS DE PAGAMENTO/PEDIDO (ja_revisados/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 16 | `payment_user/` | `payment/` | ⏳ Validar | Tela principal de pagamento |
| 17 | `order_done/` | `order_done/` | ⏳ Validar | Pedido finalizado |
| 18 | `room/` | ❌ Não existe | ❌ Criar | Seleção de quarto |
| 19 | `relatorio/` | ❌ Não existe | ❌ Criar | Relatórios |

---

## 🔧 TELAS ADMIN (admin/)

| # | FlutterFlow | Nossa Implementação | Status | Observações |
|---|-------------|---------------------|--------|-------------|
| 20 | `admin/` | `admin/` | ⏳ Validar | Dashboard admin |
| 21 | `order_clientes/` | ❌ Verificar | ⏳ | Pedidos clientes |
| 22 | `detail_order/` | ❌ Verificar | ⏳ | Detalhe pedido |
| 23 | `estoquelist/` | ❌ Verificar | ⏳ | Lista estoque |
| 24 | `estoque_item/` | ❌ Verificar | ⏳ | Item estoque |
| 25 | `register_product/` | ❌ Verificar | ⏳ | Cadastro produto |
| 26 | `cadastro_produto/` | ❌ Verificar | ⏳ | Cadastro produto |
| 27 | `cadastrar_categoria/` | ❌ Verificar | ⏳ | Cadastro categoria |
| 28 | `cadastro_categoria/` | ❌ Verificar | ⏳ | Cadastro categoria |
| 29 | `editar_categoria/` | ❌ Verificar | ⏳ | Editar categoria |
| 30 | `faq_listagem/` | ❌ Verificar | ⏳ | Listagem FAQ |
| 31 | `faq_criar/` | ❌ Verificar | ⏳ | Criar FAQ |
| 32 | `faq_editar/` | ❌ Verificar | ⏳ | Editar FAQ |
| 33 | `feedback_clients/` | ❌ Verificar | ⏳ | Feedbacks |
| 34 | `cadastr_fotos_local_principal/` | ❌ Verificar | ⏳ | Fotos local |

---

## 🧩 COMPONENTES (components/)

| # | FlutterFlow | Nossa Implementação | Status |
|---|-------------|---------------------|--------|
| C1 | `navbar/` | `navbar_widget.dart` | ✅ |
| C2 | `endrawer_comp/` | `end_drawer_widget.dart` | ✅ |
| C3 | `redirect_page/` | `redirect_page_widget.dart` | ⏳ |
| C4 | `component_cart_user/` | Inline em cart | ⏳ |
| C5 | `adicional_component/` | Inline em item_details | ⏳ |
| C6 | `cartmenucomponent/` | ❌ Verificar | ⏳ |

---

## 🚨 PROBLEMAS IDENTIFICADOS

### 1. Home → "Ver todos"
- **FlutterFlow**: Navega para `item_category` passando a categoria
- **Nossa implementação**: Navega para `/menu` (tela genérica)
- **Correção**: Mudar para navegar para `/category/:categoryId`

### 2. Tela Menu
- **FlutterFlow**: `menu/` parece ser diferente de `item_category/`
- **Investigar**: Qual a diferença entre as duas?

### 3. Telas Faltando
- `sac/` - Suporte/SAC
- `maps/` - Mapas
- `gallery_home/` - Galeria
- `local_selected/` - Seleção de local
- `room/` - Seleção de quarto
- `relatorio/` - Relatórios

---

## 📋 ORDEM DE VALIDAÇÃO

### Fase 1: Fluxo Principal do Usuário
1. [ ] Home (corrigir "Ver todos")
2. [ ] item_category (criar/ajustar)
3. [ ] item_details
4. [ ] cart_users
5. [ ] payment_user
6. [ ] order_done

### Fase 2: Telas Secundárias
7. [ ] login
8. [ ] perfil_user
9. [ ] myorders
10. [ ] feedback
11. [ ] faqpage

### Fase 3: Telas Faltando
12. [ ] sac
13. [ ] maps
14. [ ] gallery_home
15. [ ] local_selected
16. [ ] room

### Fase 4: Admin
17. [ ] admin dashboard
18. [ ] order_clientes
19. [ ] estoque
20. [ ] produtos
21. [ ] categorias
22. [ ] FAQ admin
23. [ ] feedbacks admin

---

## 🔄 PROGRESSO

- **Validadas**: 0/34
- **Em andamento**: Home
- **Pendentes**: 33

---

*Última atualização: 15/12/2025*
