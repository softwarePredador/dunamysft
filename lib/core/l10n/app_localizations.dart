import 'package:flutter/material.dart';

/// Classe de localização do app
/// Suporta: Português (pt), Inglês (en), Espanhol (es)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Helper para obter traduções de forma mais fácil
  static AppLocalizations tr(BuildContext context) {
    return of(context) ?? AppLocalizations(const Locale('pt', 'BR'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'), // Português
    Locale('en', 'US'), // Inglês
    Locale('es', 'ES'), // Espanhol
  ];

  // Mapa de traduções
  static final Map<String, Map<String, String>> _localizedValues = {
    'pt': _ptTranslations,
    'en': _enTranslations,
    'es': _esTranslations,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['pt']?[key] ??
        key;
  }

  // Getters convenientes para textos comuns
  String get appName => get('app_name');
  String get hello => get('hello');
  String get visitor => get('visitor');
  String get yourOrder => get('your_order');
  String get menu => get('menu');
  String get seeAll => get('see_all');
  String get cart => get('cart');
  String get myOrders => get('my_orders');
  String get profile => get('profile');
  String get orders => get('orders');
  String get settings => get('settings');
  String get language => get('language');
  String get selectLanguage => get('select_language');
  String get portuguese => get('portuguese');
  String get english => get('english');
  String get spanish => get('spanish');
  String get logout => get('logout');
  String get login => get('login');
  String get email => get('email');
  String get password => get('password');
  String get forgotPassword => get('forgot_password');
  String get createAccount => get('create_account');
  String get continueAsGuest => get('continue_as_guest');
  String get total => get('total');
  String get payment => get('payment');
  String get finishOrder => get('finish_order');
  String get emptyCart => get('empty_cart');
  String get addItems => get('add_items');
  String get remove => get('remove');
  String get add => get('add');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get save => get('save');
  String get edit => get('edit');
  String get delete => get('delete');
  String get search => get('search');
  String get loading => get('loading');
  String get error => get('error');
  String get success => get('success');
  String get tryAgain => get('try_again');
  String get noResults => get('no_results');
  String get orderStatus => get('order_status');
  String get pending => get('pending');
  String get preparing => get('preparing');
  String get ready => get('ready');
  String get delivered => get('delivered');
  String get cancelled => get('cancelled');
  String get waitTime => get('wait_time');
  String get prepareTime => get('prepare_time');
  String get delivering => get('delivering');
  String get waitingConfirmation => get('waiting_confirmation');
  String get readyForPickup => get('ready_for_pickup');
  String get orderDelivered => get('order_delivered');
  String get orderCancelled => get('order_cancelled');
  String get room => get('room');
  String get pickupAtCounter => get('pickup_at_counter');
  String get deliverToRoom => get('deliver_to_room');
  String get faq => get('faq');
  String get contact => get('contact');
  String get gallery => get('gallery');
  String get maps => get('maps');
  String get feedback => get('feedback');
  String get alsoOrder => get('also_order');
  String get observations => get('observations');
  String get quantity => get('quantity');
  String get additionals => get('additionals');
  String get creditCard => get('credit_card');
  String get debitCard => get('debit_card');
  String get pix => get('pix');
  String get cash => get('cash');
  String get selectPayment => get('select_payment');
  String get orderCode => get('order_code');
  String get thankYou => get('thank_you');
  String get orderPlaced => get('order_placed');
  String get backToHome => get('back_to_home');
  String get name => get('name');
  String get phone => get('phone');
  String get cpf => get('cpf');
  String get editProfile => get('edit_profile');
  String get saveChanges => get('save_changes');
  String get changesSaved => get('changes_saved');
  String get requiredField => get('required_field');
  String get invalidEmail => get('invalid_email');
  String get invalidCpf => get('invalid_cpf');
  String get minLength => get('min_length');
  String get admin => get('admin');
  String get dashboard => get('dashboard');
  String get products => get('products');
  String get categories => get('categories');
  String get stock => get('stock');
  String get reports => get('reports');
  String get media => get('media');
  String get homeCarousel => get('home_carousel');
  String get localGallery => get('local_gallery');
  String get addImage => get('add_image');
  String get deleteImage => get('delete_image');
  String get confirmDelete => get('confirm_delete');
  String get imageDeleted => get('image_deleted');
  String get imageAdded => get('image_added');
  String get noImages => get('no_images');
  String get tapToAdd => get('tap_to_add');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ==================== TRADUÇÕES PORTUGUÊS ====================
const Map<String, String> _ptTranslations = {
  'app_name': 'Dunamys',
  'hello': 'Olá!',
  'visitor': 'Visitante',
  'your_order': 'Seu pedido',
  'menu': 'Cardápio',
  'see_all': 'Ver tudo',
  'cart': 'Carrinho',
  'my_orders': 'Meus pedidos',
  'profile': 'Perfil',
  'settings': 'Configurações',
  'language': 'Idioma',
  'select_language': 'Selecionar idioma',
  'portuguese': 'Português',
  'english': 'Inglês',
  'spanish': 'Espanhol',
  'logout': 'Sair',
  'login': 'Entrar',
  'login_to_see_cart': 'Faça login para ver seu carrinho',
  'login_to_see_orders': 'Faça login para ver seus pedidos',
  'login_to_see_profile': 'Faça login para ver seu perfil',
  'email': 'E-mail',
  'password': 'Senha',
  'forgot_password': 'Esqueceu a senha?',
  'create_account': 'Criar conta',
  'continue_as_guest': 'Continuar como visitante',
  'continue_btn': 'Continuar',
  'total': 'Total',
  'payment': 'Pagamento',
  'finish_order': 'Finalizar pedido',
  'empty_cart': 'Carrinho Vazio',
  'add_items': 'Adicione itens do cardápio',
  'add_more_items': 'adicionar mais itens?',
  'items_added': 'Itens adicionados',
  'clear': 'Limpar',
  'remove': 'Remover',
  'add': 'Adicionar',
  'cancel': 'Cancelar',
  'confirm': 'Confirmar',
  'save': 'Salvar',
  'edit': 'Editar',
  'delete': 'Excluir',
  'search': 'Buscar',
  'loading': 'Carregando...',
  'error': 'Erro',
  'success': 'Sucesso',
  'try_again': 'Tentar novamente',
  'no_results': 'Nenhum resultado encontrado',
  'no_items_category': 'Nenhum item nesta categoria',
  'order_status': 'Status do pedido',
  'pending': 'Pendente',
  'preparing': 'Em preparo',
  'ready': 'Pronto',
  'delivered': 'Entregue',
  'cancelled': 'Cancelado',
  'wait_time': 'Tempo de espera',
  'prepare_time': 'Tempo de preparo',
  'delivering': 'Indo entregar',
  'waiting_confirmation': 'Aguardando confirmação',
  'ready_for_pickup': 'Pronto para retirada!',
  'order_delivered': 'Pedido entregue!',
  'order_cancelled': 'Pedido cancelado',
  'room': 'Quarto',
  'pickup_at_counter': 'Retirar no balcão',
  'deliver_to_room': 'Entregar no quarto',
  'faq': 'Perguntas frequentes',
  'contact': 'Contato',
  'gallery': 'Galeria',
  'maps': 'Mapas',
  'feedback': 'Avaliação',
  'also_order': 'Peça também',
  'observations': 'Observações',
  'quantity': 'Quantidade',
  'additionals': 'Adicionais',
  'credit_card': 'Cartão de crédito',
  'debit_card': 'Cartão de débito',
  'pix': 'PIX',
  'cash': 'Dinheiro',
  'select_payment': 'Selecione o pagamento',
  'order_code': 'Código do pedido',
  'thank_you': 'Obrigado!',
  'order_placed': 'Seu pedido foi realizado com sucesso',
  'back_to_home': 'Voltar ao início',
  'name': 'Nome',
  'phone': 'Telefone',
  'cpf': 'CPF',
  'edit_profile': 'Editar perfil',
  'save_changes': 'Salvar alterações',
  'changes_saved': 'Alterações salvas',
  'required_field': 'Campo obrigatório',
  'invalid_email': 'E-mail inválido',
  'invalid_cpf': 'CPF inválido',
  'min_length': 'Mínimo de caracteres',
  'admin': 'Admin',
  'dashboard': 'Painel',
  'products': 'Produtos',
  'categories': 'Categorias',
  'stock': 'Estoque',
  'reports': 'Relatórios',
  'media': 'Mídias',
  'home_carousel': 'Carrossel Home',
  'local_gallery': 'Galeria Locais',
  'add_image': 'Adicionar Imagem',
  'delete_image': 'Excluir Imagem',
  'confirm_delete': 'Deseja realmente excluir?',
  'image_deleted': 'Imagem excluída!',
  'image_added': 'Imagem adicionada!',
  'no_images': 'Nenhuma imagem',
  'tap_to_add': 'Toque no + para adicionar',
  'home_menu': 'Home / Cardápio',
  'customer_service': 'SAC',
  'maps_directions': 'Mapas e Direções',
  'image_gallery': 'Galeria de imagens',
  'reservations': 'Reservas pelo site',
  'coming_soon': 'Em breve!',
  'orders': 'Pedidos',
  'send_feedback': 'Enviar Feedback',
  'about': 'Sobre',
  'about_app': 'Sobre o App',
  'version': 'Versão',
  'about_description': 'Aplicativo desenvolvido para gerenciar pedidos e serviços do Hotel Dunamys.',
  'close': 'Fechar',
  'user': 'Usuário',
  'my_profile': 'Meu Perfil',
  'welcome_message': 'Olá, seja bem-vindo',
  'select_option': 'Por favor, selecione uma das opções',
  'login_google': 'Entrar com Google',
  'login_apple': 'Entrar com Apple',
  'error_loading_orders': 'Erro ao carregar pedidos',
  'no_orders_found': 'Nenhum pedido encontrado',
  'make_first_order': 'Faça seu primeiro pedido',
  'view_menu': 'Ver Cardápio',
  'order_number': 'Pedido',
  'date': 'Data',
  'delivery': 'Entrega',
  'pickup_local': 'Retirar no local',
  'deliver_room': 'Entregar no quarto',
  'error_loading_faq': 'Erro ao carregar perguntas',
  'no_faq_available': 'Nenhuma pergunta disponível',
  'login_to_feedback': 'Faça login para enviar feedback',
  'select_rating': 'Por favor, selecione uma avaliação',
  'thanks_feedback': 'Obrigado pelo seu feedback!',
  'error_sending_feedback': 'Erro ao enviar feedback. Tente novamente.',
  'feedback_question': 'Queremos saber como foi sua estadia no Dunamys Hotel?',
  'rate_experience': 'Como você avalia sua experiência?',
  'leave_comment': 'Gostaria de deixar um comentário?',
  'write_comment_here': 'Escreva seu comentário aqui...',
  'login_to_add_cart': 'Faça login para adicionar ao carrinho',
  'added_success': 'Adicionado com sucesso!',
  'include_items': 'Incluir itens?',
  'no_additionals': 'Nenhum adicional disponível',
  'any_observation': 'Alguma observação?',
  'observation_hint': 'Ex: Sem cebola, bem passado...',
  'unavailable': 'Indisponível',
  'order_confirmed': 'Pedido confirmado!',
  'code': 'Código',
  'payment_confirmed_preparing': 'Seu pagamento foi confirmado e seu pedido está sendo preparado.',
  'estimated_time': 'Tempo estimado',
  'view_my_orders': 'Ver meus pedidos',
  'receive_receipt_email': 'Receber nota fiscal por e-mail?',
  'receipt_sent': 'Nota fiscal enviada para seu e-mail!',
  'phones': 'Telefones',
  'social_media': 'Nossas redes sociais',
  'photo_video_gallery': 'Galeria de fotos e vídeos',
  'explore_by_location': 'Explore por local',
  'no_images_available': 'Nenhuma imagem disponível',
};

// ==================== TRADUÇÕES INGLÊS ====================
const Map<String, String> _enTranslations = {
  'app_name': 'Dunamys',
  'hello': 'Hello!',
  'visitor': 'Guest',
  'your_order': 'Your order',
  'menu': 'Menu',
  'see_all': 'See all',
  'cart': 'Cart',
  'my_orders': 'My orders',
  'profile': 'Profile',
  'settings': 'Settings',
  'language': 'Language',
  'select_language': 'Select language',
  'portuguese': 'Portuguese',
  'english': 'English',
  'spanish': 'Spanish',
  'logout': 'Logout',
  'login': 'Login',
  'login_to_see_cart': 'Login to see your cart',
  'login_to_see_orders': 'Login to see your orders',
  'login_to_see_profile': 'Login to see your profile',
  'email': 'Email',
  'password': 'Password',
  'forgot_password': 'Forgot password?',
  'create_account': 'Create account',
  'continue_as_guest': 'Continue as guest',
  'continue_btn': 'Continue',
  'total': 'Total',
  'payment': 'Payment',
  'finish_order': 'Finish order',
  'empty_cart': 'Empty Cart',
  'add_items': 'Add items from the menu',
  'add_more_items': 'add more items?',
  'items_added': 'Items added',
  'clear': 'Clear',
  'remove': 'Remove',
  'add': 'Add',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'save': 'Save',
  'edit': 'Edit',
  'delete': 'Delete',
  'search': 'Search',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'try_again': 'Try again',
  'no_results': 'No results found',
  'no_items_category': 'No items in this category',
  'order_status': 'Order status',
  'pending': 'Pending',
  'preparing': 'Preparing',
  'ready': 'Ready',
  'delivered': 'Delivered',
  'cancelled': 'Cancelled',
  'wait_time': 'Wait time',
  'prepare_time': 'Preparation time',
  'delivering': 'On the way',
  'waiting_confirmation': 'Waiting for confirmation',
  'ready_for_pickup': 'Ready for pickup!',
  'order_delivered': 'Order delivered!',
  'order_cancelled': 'Order cancelled',
  'room': 'Room',
  'pickup_at_counter': 'Pickup at counter',
  'deliver_to_room': 'Deliver to room',
  'faq': 'FAQ',
  'contact': 'Contact',
  'gallery': 'Gallery',
  'maps': 'Maps',
  'feedback': 'Feedback',
  'also_order': 'Also order',
  'observations': 'Observations',
  'quantity': 'Quantity',
  'additionals': 'Extras',
  'credit_card': 'Credit card',
  'debit_card': 'Debit card',
  'pix': 'PIX',
  'cash': 'Cash',
  'select_payment': 'Select payment',
  'order_code': 'Order code',
  'thank_you': 'Thank you!',
  'order_placed': 'Your order was placed successfully',
  'back_to_home': 'Back to home',
  'name': 'Name',
  'phone': 'Phone',
  'cpf': 'ID Number',
  'edit_profile': 'Edit profile',
  'save_changes': 'Save changes',
  'changes_saved': 'Changes saved',
  'required_field': 'Required field',
  'invalid_email': 'Invalid email',
  'invalid_cpf': 'Invalid ID',
  'min_length': 'Minimum characters',
  'admin': 'Admin',
  'dashboard': 'Dashboard',
  'products': 'Products',
  'categories': 'Categories',
  'stock': 'Stock',
  'reports': 'Reports',
  'media': 'Media',
  'home_carousel': 'Home Carousel',
  'local_gallery': 'Location Gallery',
  'add_image': 'Add Image',
  'delete_image': 'Delete Image',
  'confirm_delete': 'Are you sure you want to delete?',
  'image_deleted': 'Image deleted!',
  'image_added': 'Image added!',
  'no_images': 'No images',
  'tap_to_add': 'Tap + to add',
  'home_menu': 'Home / Menu',
  'customer_service': 'Customer Service',
  'maps_directions': 'Maps & Directions',
  'image_gallery': 'Image Gallery',
  'reservations': 'Book Online',
  'coming_soon': 'Coming soon!',
  'orders': 'Orders',
  'send_feedback': 'Send Feedback',
  'about': 'About',
  'about_app': 'About the App',
  'version': 'Version',
  'about_description': 'App developed to manage orders and services of Hotel Dunamys.',
  'close': 'Close',
  'user': 'User',
  'my_profile': 'My Profile',
  'welcome_message': 'Hello, welcome',
  'select_option': 'Please select an option',
  'login_google': 'Sign in with Google',
  'login_apple': 'Sign in with Apple',
  'error_loading_orders': 'Error loading orders',
  'no_orders_found': 'No orders found',
  'make_first_order': 'Place your first order',
  'view_menu': 'View Menu',
  'order_number': 'Order',
  'date': 'Date',
  'delivery': 'Delivery',
  'pickup_local': 'Pickup at location',
  'deliver_room': 'Deliver to room',
  'error_loading_faq': 'Error loading questions',
  'no_faq_available': 'No questions available',
  'login_to_feedback': 'Login to send feedback',
  'select_rating': 'Please select a rating',
  'thanks_feedback': 'Thank you for your feedback!',
  'error_sending_feedback': 'Error sending feedback. Please try again.',
  'feedback_question': 'We want to know how was your stay at Dunamys Hotel?',
  'rate_experience': 'How would you rate your experience?',
  'leave_comment': 'Would you like to leave a comment?',
  'write_comment_here': 'Write your comment here...',
  'login_to_add_cart': 'Login to add to cart',
  'added_success': 'Added successfully!',
  'include_items': 'Include items?',
  'no_additionals': 'No extras available',
  'any_observation': 'Any observation?',
  'observation_hint': 'E.g.: No onion, well done...',
  'unavailable': 'Unavailable',
  'order_confirmed': 'Order confirmed!',
  'code': 'Code',
  'payment_confirmed_preparing': 'Your payment has been confirmed and your order is being prepared.',
  'estimated_time': 'Estimated time',
  'view_my_orders': 'View my orders',
  'receive_receipt_email': 'Receive receipt by email?',
  'receipt_sent': 'Receipt sent to your email!',
  'phones': 'Phones',
  'social_media': 'Our social media',
  'photo_video_gallery': 'Photo and video gallery',
  'explore_by_location': 'Explore by location',
  'no_images_available': 'No images available',
};

// ==================== TRADUÇÕES ESPANHOL ====================
const Map<String, String> _esTranslations = {
  'app_name': 'Dunamys',
  'hello': '¡Hola!',
  'visitor': 'Visitante',
  'your_order': 'Tu pedido',
  'menu': 'Menú',
  'see_all': 'Ver todo',
  'cart': 'Carrito',
  'my_orders': 'Mis pedidos',
  'profile': 'Perfil',
  'settings': 'Configuración',
  'language': 'Idioma',
  'select_language': 'Seleccionar idioma',
  'portuguese': 'Portugués',
  'english': 'Inglés',
  'spanish': 'Español',
  'logout': 'Salir',
  'login': 'Iniciar sesión',
  'login_to_see_cart': 'Inicia sesión para ver tu carrito',
  'login_to_see_orders': 'Inicia sesión para ver tus pedidos',
  'login_to_see_profile': 'Inicia sesión para ver tu perfil',
  'email': 'Correo electrónico',
  'password': 'Contraseña',
  'forgot_password': '¿Olvidaste tu contraseña?',
  'create_account': 'Crear cuenta',
  'continue_as_guest': 'Continuar como invitado',
  'continue_btn': 'Continuar',
  'total': 'Total',
  'payment': 'Pago',
  'finish_order': 'Finalizar pedido',
  'empty_cart': 'Carrito Vacío',
  'add_items': 'Añade artículos del menú',
  'add_more_items': '¿añadir más artículos?',
  'items_added': 'Artículos añadidos',
  'clear': 'Limpiar',
  'remove': 'Eliminar',
  'add': 'Añadir',
  'cancel': 'Cancelar',
  'confirm': 'Confirmar',
  'save': 'Guardar',
  'edit': 'Editar',
  'delete': 'Eliminar',
  'search': 'Buscar',
  'loading': 'Cargando...',
  'error': 'Error',
  'success': 'Éxito',
  'try_again': 'Intentar de nuevo',
  'no_results': 'No se encontraron resultados',
  'no_items_category': 'No hay artículos en esta categoría',
  'order_status': 'Estado del pedido',
  'pending': 'Pendiente',
  'preparing': 'En preparación',
  'ready': 'Listo',
  'delivered': 'Entregado',
  'cancelled': 'Cancelado',
  'wait_time': 'Tiempo de espera',
  'prepare_time': 'Tiempo de preparación',
  'delivering': 'En camino',
  'waiting_confirmation': 'Esperando confirmación',
  'ready_for_pickup': '¡Listo para recoger!',
  'order_delivered': '¡Pedido entregado!',
  'order_cancelled': 'Pedido cancelado',
  'room': 'Habitación',
  'pickup_at_counter': 'Recoger en mostrador',
  'deliver_to_room': 'Entregar en habitación',
  'faq': 'Preguntas frecuentes',
  'contact': 'Contacto',
  'gallery': 'Galería',
  'maps': 'Mapas',
  'feedback': 'Opinión',
  'also_order': 'Pide también',
  'observations': 'Observaciones',
  'quantity': 'Cantidad',
  'additionals': 'Adicionales',
  'credit_card': 'Tarjeta de crédito',
  'debit_card': 'Tarjeta de débito',
  'pix': 'PIX',
  'cash': 'Efectivo',
  'select_payment': 'Seleccionar pago',
  'order_code': 'Código del pedido',
  'thank_you': '¡Gracias!',
  'order_placed': 'Tu pedido se realizó con éxito',
  'back_to_home': 'Volver al inicio',
  'name': 'Nombre',
  'phone': 'Teléfono',
  'cpf': 'Documento',
  'edit_profile': 'Editar perfil',
  'save_changes': 'Guardar cambios',
  'changes_saved': 'Cambios guardados',
  'required_field': 'Campo obligatorio',
  'invalid_email': 'Correo inválido',
  'invalid_cpf': 'Documento inválido',
  'min_length': 'Mínimo de caracteres',
  'admin': 'Admin',
  'dashboard': 'Panel',
  'products': 'Productos',
  'categories': 'Categorías',
  'stock': 'Inventario',
  'reports': 'Informes',
  'media': 'Medios',
  'home_carousel': 'Carrusel Inicio',
  'local_gallery': 'Galería Lugares',
  'add_image': 'Añadir Imagen',
  'delete_image': 'Eliminar Imagen',
  'confirm_delete': '¿Estás seguro de que deseas eliminar?',
  'image_deleted': '¡Imagen eliminada!',
  'image_added': '¡Imagen añadida!',
  'no_images': 'Sin imágenes',
  'tap_to_add': 'Toca + para añadir',
  'home_menu': 'Inicio / Menú',
  'customer_service': 'Atención al Cliente',
  'maps_directions': 'Mapas y Direcciones',
  'image_gallery': 'Galería de Imágenes',
  'reservations': 'Reservas Online',
  'coming_soon': '¡Próximamente!',
  'orders': 'Pedidos',
  'send_feedback': 'Enviar Opinión',
  'about': 'Acerca de',
  'about_app': 'Acerca de la App',
  'version': 'Versión',
  'about_description': 'Aplicación desarrollada para gestionar pedidos y servicios del Hotel Dunamys.',
  'close': 'Cerrar',
  'user': 'Usuario',
  'my_profile': 'Mi Perfil',
  'welcome_message': 'Hola, bienvenido',
  'select_option': 'Por favor, selecciona una opción',
  'login_google': 'Iniciar sesión con Google',
  'login_apple': 'Iniciar sesión con Apple',
  'error_loading_orders': 'Error al cargar pedidos',
  'no_orders_found': 'No se encontraron pedidos',
  'make_first_order': 'Haz tu primer pedido',
  'view_menu': 'Ver Menú',
  'order_number': 'Pedido',
  'date': 'Fecha',
  'delivery': 'Entrega',
  'pickup_local': 'Recoger en local',
  'deliver_room': 'Entregar en habitación',
  'error_loading_faq': 'Error al cargar preguntas',
  'no_faq_available': 'No hay preguntas disponibles',
  'login_to_feedback': 'Inicia sesión para enviar opinión',
  'select_rating': 'Por favor, selecciona una calificación',
  'thanks_feedback': '¡Gracias por tu opinión!',
  'error_sending_feedback': 'Error al enviar opinión. Intenta de nuevo.',
  'feedback_question': '¿Queremos saber cómo fue tu estadía en Dunamys Hotel?',
  'rate_experience': '¿Cómo calificas tu experiencia?',
  'leave_comment': '¿Te gustaría dejar un comentario?',
  'write_comment_here': 'Escribe tu comentario aquí...',
  'login_to_add_cart': 'Inicia sesión para añadir al carrito',
  'added_success': '¡Añadido con éxito!',
  'include_items': '¿Incluir artículos?',
  'no_additionals': 'Sin adicionales disponibles',
  'any_observation': '¿Alguna observación?',
  'observation_hint': 'Ej: Sin cebolla, bien cocido...',
  'unavailable': 'No disponible',
  'order_confirmed': '¡Pedido confirmado!',
  'code': 'Código',
  'payment_confirmed_preparing': 'Tu pago ha sido confirmado y tu pedido está siendo preparado.',
  'estimated_time': 'Tiempo estimado',
  'view_my_orders': 'Ver mis pedidos',
  'receive_receipt_email': '¿Recibir factura por correo?',
  'receipt_sent': '¡Factura enviada a tu correo!',
  'phones': 'Teléfonos',
  'social_media': 'Nuestras redes sociales',
  'photo_video_gallery': 'Galería de fotos y vídeos',
  'explore_by_location': 'Explorar por ubicación',
  'no_images_available': 'No hay imágenes disponibles',
};
