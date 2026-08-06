// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a ZigDash';

  @override
  String get onboardingWelcomeSubtitle =>
      'Tu panel privado y local para Zigbee2MQTT.\nSin nube. Sin seguimiento. Solo control.';

  @override
  String get onboardingBrokerTitle => 'Conecta tu broker';

  @override
  String get onboardingBrokerSubtitle =>
      'Apunta ZigDash a tu broker MQTT para hablar directamente con tus dispositivos Zigbee. Funciona con Mosquitto, SMLIGHT y cualquier servidor MQTT.';

  @override
  String get onboardingDashboardTitle => 'Crea tus tableros';

  @override
  String get onboardingDashboardSubtitle =>
      'Crea tableros personalizados con interruptores, deslizadores, persianas y más. Organiza los paneles a tu manera: todo se guarda en tu dispositivo.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingDemo => 'Probar demo';

  @override
  String get navBrokers => 'Brokers';

  @override
  String get navDashboards => 'Tableros';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsDynamicColor => 'Usar colores de Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+; de lo contrario usa el color de la app';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Conexiones';

  @override
  String connLoadFailed(Object error) {
    return 'No se pudo cargar: $error';
  }

  @override
  String get connAddBroker => 'Añadir broker';

  @override
  String get connEmpty =>
      'Aún no hay conexiones.\nToca «Añadir broker» para apuntar ZigDash a tu servidor MQTT.';

  @override
  String get connNew => 'Nueva conexión';

  @override
  String get connEdit => 'Editar conexión';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando…';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get connName => 'Nombre';

  @override
  String get connNameHint => 'Broker de casa';

  @override
  String get connHost => 'Host';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Host local';

  @override
  String get connFindBrokers => 'Buscar brokers';

  @override
  String get connHowToFind => '¿Cómo encuentro esto?';

  @override
  String get connRescan => 'Volver a escanear';

  @override
  String get connBrokerNeedsLogin => 'Requiere inicio de sesión';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Escaneando $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(s) encontrados: toca para usar';
  }

  @override
  String get connFindBrokersNone => 'No se encontraron brokers en tu Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'No se pudo leer tu dirección Wi-Fi. Asegúrate de que el Wi-Fi esté activado e inténtalo de nuevo.';

  @override
  String get connHelpTitle => 'Encontrar la IP de tu broker';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT en Docker';

  @override
  String get connHelpDockerBody =>
      'La IP del broker es la dirección LAN de la máquina donde corre Docker (tu NAS, Raspberry Pi, etc.). Encuéntrala en la lista de dispositivos de tu router, o ejecuta \'hostname -I\' / \'ip addr\' en esa máquina. El puerto suele ser 1883 (Mosquitto). Usa la IP LAN del host, no 127.0.0.1, incluso si Mosquitto corre en su propio contenedor.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'La IP del broker es la IP del hub. Encuéntrala en la interfaz web de SMLIGHT en Ajustes → Red, o en tu router. El puerto es 1883, sin usuario/contraseña por defecto.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA no tiene broker MQTT: se comunica directamente con Home Assistant, por lo que ZigDash no puede conectarse. Para usar ZigDash, cambia a Zigbee2MQTT (disponible como complemento de Home Assistant o contenedor Docker), que proporciona un broker MQTT.';

  @override
  String get connHelpSameNetwork =>
      'Tu teléfono y el broker deben estar en la misma red Wi-Fi (no en una VLAN de invitados o aislada).';

  @override
  String get connRemoteHost => 'Host remoto (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Se usa cuando el host local no es accesible. Prefiere la IP de Tailscale del hub, p. ej. 100.x.y.z';

  @override
  String get connPort => 'Puerto';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'Usuario (opcional)';

  @override
  String get connPasswordOptional => 'Contraseña (opcional)';

  @override
  String get connPasswordKeepHint => 'Déjalo vacío para conservar la existente';

  @override
  String get connAutoConnect => 'Conectar automáticamente al iniciar la app';

  @override
  String get advanced => 'Avanzado';

  @override
  String get connKeepAlive => 'Keep-alive (segundos)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protocolo';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get connDeleteTitle => '¿Eliminar la conexión?';

  @override
  String connDeleteContent(Object name) {
    return 'Elimina «$name», sus tableros/paneles y la contraseña guardada.';
  }

  @override
  String get statusDisconnected => 'Desconectado';

  @override
  String get statusConnecting => 'Conectando…';

  @override
  String get statusConnected => 'Conectado';

  @override
  String get statusReconnecting => 'Reconectando…';

  @override
  String get statusError => 'Error';

  @override
  String get statusConnectedRemote => 'Conectado · Remoto';

  @override
  String get dashPlaceholder =>
      'Abre un broker desde la pestaña Brokers para ver y gestionar sus tableros.';

  @override
  String get dashAddDashboard => 'Añadir tablero';

  @override
  String get dashEditDashboard => 'Editar tablero';

  @override
  String get dashAddPanel => 'Añadir panel';

  @override
  String get dashEmpty =>
      'Aún no hay tableros.\nToca «Añadir tablero» para crear uno para este broker.';

  @override
  String dashLoadFailed(Object error) {
    return 'Error: $error';
  }

  @override
  String get panelPickerTitle => 'Añadir panel';

  @override
  String get panelPickerSectionControl => 'Control';

  @override
  String get panelPickerSectionState => 'Estado';

  @override
  String get panelPickerToggleTitle => 'Interruptor';

  @override
  String get panelPickerToggleSubtitle =>
      'Interruptor de encendido/apagado para el estado de un dispositivo';

  @override
  String get panelPickerSliderBrightnessTitle => 'Deslizador — Brillo';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Atenuar luz (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Deslizador — Posición';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Persiana (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Persiana';

  @override
  String get panelPickerCoverSubtitle =>
      'Persiana: ABRIR·PARAR·CERRAR + deslizador de posición';

  @override
  String get panelPickerScheduleTitle => 'Programación';

  @override
  String get panelPickerScheduleSubtitle =>
      'Horarios diarios de apertura/cierre, se ejecutan en el hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Regla de cierre automático';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Cierra un dispositivo automáticamente N segundos después de encenderse, se ejecuta en el hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Multiestado';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Botones segmentados para una enumeración (p. ej. ABRIR/PARAR/CERRAR)';

  @override
  String get panelPickerComboTitle => 'Desplegable';

  @override
  String get panelPickerComboSubtitle =>
      'Selector desplegable para una enumeración';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle =>
      'Lista de botones de opción para una enumeración';

  @override
  String get panelPickerButtonTitle => 'Botón';

  @override
  String get panelPickerButtonSubtitle => 'Envía un comando único';

  @override
  String get panelPickerTextInputTitle => 'Entrada de texto';

  @override
  String get panelPickerTextInputSubtitle => 'Publica un valor libre o JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Indicador de color para un estado booleano (contacto, fuga)';

  @override
  String get panelPickerNodeStatusTitle => 'Estado del nodo';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Disponibilidad de dispositivos Z2M (en línea/desconectado)';

  @override
  String get panelPickerProgressTitle => 'Progreso';

  @override
  String get panelPickerProgressSubtitle =>
      'Barra numérica para batería, calidad del enlace, etc.';

  @override
  String get panelPickerTextLogTitle => 'Registro de texto';

  @override
  String get panelPickerTextLogSubtitle => 'Historial de mensajes en un tema';

  @override
  String get dashExportMenu => 'Exportar tableros';

  @override
  String get dashImportMenu => 'Importar tableros';

  @override
  String get dashExportTitle => 'Exportar tableros';

  @override
  String get dashExportClose => 'Cerrar';

  @override
  String get dashExportCopy => 'Copiar';

  @override
  String get dashExportCopied => 'Copiado al portapapeles';

  @override
  String get dashImportTitle => 'Importar tableros';

  @override
  String get dashImportHint => 'Pega aquí el JSON exportado';

  @override
  String get dashImportButton => 'Importar';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count tableros',
      one: 'Se importó 1 tablero',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get dashFormNew => 'Nuevo tablero';

  @override
  String get dashFormEdit => 'Editar tablero';

  @override
  String get dashFormName => 'Nombre';

  @override
  String get dashFormNameHint => 'Oficina';

  @override
  String get dashFormTopicPrefix => 'Prefijo de tema (opcional)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/salon';

  @override
  String get dashFormTopicPrefixHelper =>
      'Se antepone a cada tema de panel en este tablero';

  @override
  String get dashFormColorSeed => 'Color';

  @override
  String get dashFormIcon => 'Icono';

  @override
  String get dashFormLock => 'Bloquear';

  @override
  String get dashFormLockSubtitle =>
      'Ocultar las opciones de edición mientras esté bloqueado';

  @override
  String get dashFormDelete => 'Eliminar tablero';

  @override
  String get dashDeleteTitle => '¿Eliminar este tablero?';

  @override
  String get dashDeleteContent =>
      'Todos los paneles que contiene también se eliminarán.';

  @override
  String get dashDeleteConfirm => 'Eliminar';

  @override
  String panelFormNew(Object type) {
    return 'Nuevo $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Editar $type';
  }

  @override
  String get panelTypeButton => 'Botón';

  @override
  String get panelTypeToggle => 'Interruptor';

  @override
  String get panelTypeSlider => 'Deslizador';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'Estado del nodo';

  @override
  String get panelTypeProgress => 'Progreso';

  @override
  String get panelTypeMultiState => 'Multiestado';

  @override
  String get panelTypeCombo => 'Desplegable';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Persiana';

  @override
  String get panelTypeTextInput => 'Entrada de texto';

  @override
  String get panelTypeTextLog => 'Registro de texto';

  @override
  String get panelTypeSchedule => 'Programación';

  @override
  String get panelTypeAutoClose => 'Cierre automático';

  @override
  String get panelFormName => 'Nombre';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Prefijo del tablero: $prefix/ (se usa salvo que se anule abajo)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Anular prefijo de tema (opcional)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/persiana';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Usar otro dispositivo en este tablero. Vacío = usar el prefijo del tablero.';

  @override
  String get panelFormPublishTopic => 'Tema de publicación (sufijo)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Se añade al prefijo efectivo. Déjalo vacío para publicar en el propio prefijo.';

  @override
  String get panelFormTopicSuffix => 'Tema (sufijo)';

  @override
  String get panelFormSubscribeTopic =>
      'Tema de suscripción (sufijo, opcional)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Se añade al prefijo del tablero. Vacío = suscribirse al propio prefijo (estado Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Vacío = suscribirse al propio prefijo (estado Z2M). Igual que Tema de publicación = usar ese.';

  @override
  String get panelFormWidth => 'Ancho';

  @override
  String get panelFormWidthFull => 'Completo';

  @override
  String get panelFormWidthHalf => 'Mitad';

  @override
  String get panelFormWidthThird => 'Tercio';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — como máximo una vez';

  @override
  String get panelFormQos1 => '1 — al menos una vez';

  @override
  String get panelFormQos2 => '2 — exactamente una vez';

  @override
  String get panelFormRetain => 'Retener';

  @override
  String get panelToggleOnPayload => 'Payload de encendido';

  @override
  String get panelToggleOffPayload => 'Payload de apagado';

  @override
  String get panelToggleJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Coincidencia de encendido';

  @override
  String get panelToggleOnMatchHelper =>
      'Valor en la ruta JSON que significa «encendido» (p. ej. «ON»)';

  @override
  String get panelSliderMin => 'Mín';

  @override
  String get panelSliderMax => 'Máx';

  @override
  String get panelSliderStep => 'Paso';

  @override
  String get panelSliderTemplate => 'Plantilla de valor';

  @override
  String get panelSliderTemplateHelper =>
      'Usa la palabra value como marcador de posición: se sustituye por el valor del deslizador';

  @override
  String get panelSliderJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Payload';

  @override
  String get panelLedJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'p. ej. «contact», «occupancy», «water_leak»';

  @override
  String get panelLedOnMatch => 'Coincidencia de encendido';

  @override
  String get panelLedOnMatchHelper =>
      'Valor en la ruta JSON que enciende el LED (p. ej. «true», «ON»)';

  @override
  String get panelLedOnLabel => 'Etiqueta de encendido (opcional)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Etiqueta de apagado (opcional)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Payload de en línea';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Valor que significa «en línea» (estándar Z2M: «online»)';

  @override
  String get panelNodeJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelNodeJsonPathHelper =>
      'Déjalo vacío para el estándar Z2M (cadena «online»/«offline» sin procesar)';

  @override
  String get panelProgressMin => 'Mín';

  @override
  String get panelProgressMax => 'Máx';

  @override
  String get panelProgressUnit => 'Unidad';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'p. ej. «battery», «linkquality»';

  @override
  String get panelOptionsJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Campo del payload recibido que contiene el valor actual';

  @override
  String get panelOptionsHeader => 'Opciones';

  @override
  String get panelOptionsLabel => 'Etiqueta';

  @override
  String get panelOptionsPayload => 'Payload';

  @override
  String get panelOptionsMatch => 'Coincidencia (valor actual)';

  @override
  String get panelOptionsAdd => 'Añadir opción';

  @override
  String get panelCoverDescription =>
      'Botones ABRIR/PARAR/CERRAR más una fila de posiciones predefinidas. Usa los payloads estándar de Z2M para persianas (state y position).';

  @override
  String get panelCoverPresets => 'Posiciones predefinidas';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Porcentajes separados por comas (0–100). Vacío = sin fila de predefinidos.';

  @override
  String get panelCoverShowSlider => 'Mostrar deslizador de posición';

  @override
  String get panelTextInputHint => 'Sugerencia (opcional)';

  @override
  String get panelTextInputHintHint => 'Escribe un valor…';

  @override
  String get panelTextInputTemplate => 'Plantilla';

  @override
  String get panelTextInputTemplateHelper =>
      'Usa la palabra value como marcador de posición: se sustituye por el texto escrito. Por defecto publica el texto sin procesar.';

  @override
  String get panelTextInputClearAfterSend => 'Vaciar después de enviar';

  @override
  String get panelTextLogMaxLines => 'Máx. de líneas';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Cuántos mensajes recientes conservar';

  @override
  String get panelTextLogJsonPath => 'Ruta JSON (opcional)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Registrar solo este campo en lugar de todo el payload';

  @override
  String get panelScheduleDescription =>
      'Se ejecuta en el SMHUB mediante Node-RED, incluso con el teléfono apagado. El tema de publicación anterior es el destino del comando de la persiana.';

  @override
  String get panelScheduleOpenTime => 'Hora de apertura';

  @override
  String get panelScheduleCloseTime => 'Hora de cierre';

  @override
  String get panelScheduleOpenPayload => 'Payload de apertura';

  @override
  String get panelScheduleClosePayload => 'Payload de cierre';

  @override
  String get panelScheduleEnabled => 'Activado';

  @override
  String get panelScheduleSavedOffline =>
      'Guardado: sin conexión; la programación se sincronizará al conectarse.';

  @override
  String get panelAutoCloseDescription =>
      'Se ejecuta en el SMHUB mediante Node-RED, incluso con el teléfono apagado. El tema de publicación anterior es el destino del comando del dispositivo (p. ej. puerta).';

  @override
  String get panelAutoCloseTriggerPath => 'Ruta JSON del disparador';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Campo del JSON de estado del dispositivo a vigilar (por defecto: state)';

  @override
  String get panelAutoCloseTriggerValue => 'Valor del disparador';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Activa el temporizador cuando el campo del disparador sea igual a este valor (por defecto: ON)';

  @override
  String get panelAutoCloseClosePayload => 'Payload de cierre';

  @override
  String get panelAutoCloseDelaySeconds => 'Retardo (segundos)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1–3600. Tiempo de espera tras encenderse el dispositivo antes de publicar el payload de cierre.';

  @override
  String get panelAutoCloseEnabled => 'Activado';

  @override
  String get panelAutoCloseSavedOffline =>
      'Guardado: sin conexión; la regla se sincronizará al conectarse.';

  @override
  String get panelTileEdit => 'Editar panel';

  @override
  String get panelTileDuplicate => 'Duplicar panel';

  @override
  String get panelTileMoveUp => 'Subir';

  @override
  String get panelTileMoveDown => 'Bajar';

  @override
  String get panelTileWidth => 'Ancho';

  @override
  String get panelTileWidthFull => 'Completo';

  @override
  String get panelTileWidthHalf => 'Mitad';

  @override
  String get panelTileWidthThird => '⅓';

  @override
  String get panelTileDelete => 'Eliminar panel';

  @override
  String get panelCoverOpen => 'Abrir';

  @override
  String get panelCoverStop => 'Parar';

  @override
  String get panelCoverClose => 'Cerrar';

  @override
  String get panelToggleNoState => '(sin estado)';

  @override
  String get panelToggleError => 'err';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'en línea';

  @override
  String get panelNodeStatusOffline => 'sin conexión';

  @override
  String get panelNodeStatusUnknown => 'desconocido';

  @override
  String get panelNodeStatusError => 'error';

  @override
  String get panelMultiStateNoOptions => 'No hay opciones configuradas';

  @override
  String get panelTextInputDefaultHint => 'Escribe un valor…';

  @override
  String get panelTextLogWaiting => 'Esperando mensajes…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Abre $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Cierra $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Programador sin conexión: no se ejecutará';

  @override
  String get panelScheduleDisabled => 'Desactivado';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Siguiente: $action a las $at';
  }

  @override
  String get panelScheduleActionOpen => 'abrir';

  @override
  String get panelScheduleActionClose => 'cerrar';

  @override
  String get panelAutoCloseIdle => 'Inactivo';

  @override
  String get panelAutoCloseDisabled => 'Desactivado';

  @override
  String get panelAutoCloseOffline =>
      'Automatización sin conexión: la regla no se ejecutará';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Se cierra en ${seconds}s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Cerrando…';

  @override
  String get panelGridEmpty =>
      'Aún no hay paneles.\nToca + para añadir un Interruptor, Deslizador o Botón.';

  @override
  String get panelsOffline => 'Sin conexión: mostrando últimos valores';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsHelp => 'Ayuda y guía';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get a11yBackupMenu => 'Copia de seguridad y restauración';

  @override
  String get a11ySelectColor => 'Seleccionar color';

  @override
  String get a11ySelectIcon => 'Seleccionar icono';

  @override
  String get a11yDeleteOption => 'Eliminar opción';

  @override
  String get a11yPanelOptions => 'Opciones del panel';

  @override
  String get a11yMoreOptions => 'Más opciones';

  @override
  String get a11yDeleteConnection => 'Eliminar conexión';

  @override
  String get controlNotConnected => 'Sin conexión: cambio no enviado';

  @override
  String get discoverFromDevice => 'Añadir desde un dispositivo…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Detectar automáticamente un dispositivo Zigbee2MQTT';

  @override
  String get discoverTitle => 'Añadir desde dispositivo';

  @override
  String get discoverBaseTopic => 'Tema base de Zigbee2MQTT';

  @override
  String get discoverScanning => 'Buscando dispositivos…';

  @override
  String get discoverNone => 'No se encontraron dispositivos.';

  @override
  String get discoverFailed =>
      'No se encontró la lista de dispositivos. Comprueba el tema base y que el broker esté conectado.';

  @override
  String get retry => 'Reintentar';

  @override
  String get previewTitle => 'Vista previa en vivo';

  @override
  String previewWaiting(Object topic) {
    return 'Esperando un mensaje en $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Extraído ($path): $value';
  }

  @override
  String get previewNoValue => '(sin valor en esta ruta)';

  @override
  String get connErrorTitle => 'Error de conexión';

  @override
  String get connErrorUnknown => 'No hay detalles del error disponibles.';

  @override
  String get connTestButton => 'Probar conexión';

  @override
  String get connTestOk => 'Conexión correcta';

  @override
  String connTestFailed(Object error) {
    return 'Conexión fallida: $error';
  }

  @override
  String get devicesTitle => 'Dispositivos';

  @override
  String get devicesAddButton => 'Añadir dispositivo';

  @override
  String get devicesPairingTitle =>
      'Emparejando: pulsa el botón del dispositivo';

  @override
  String devicesPairingHint(int seconds) {
    return 'Buscando nuevos dispositivos… ${seconds}s';
  }

  @override
  String get devicesPairingStop => 'Detener';

  @override
  String get devicesNone => 'No se encontraron dispositivos.';

  @override
  String get devicesBattery => 'Batería';

  @override
  String get devicesLinkQuality => 'Enlace';

  @override
  String get devicesOnline => 'En línea';

  @override
  String get devicesOffline => 'Desconectado';

  @override
  String devicesPaired(Object name) {
    return 'Listo: $name';
  }

  @override
  String get devicesPairedHint =>
      'Añadido a tu red. Para ponerlo en un tablero, usa «Añadir desde un dispositivo» en ese tablero.';

  @override
  String get scenesTitle => 'Escenas';

  @override
  String get scenesNone =>
      'Aún no hay escenas. Configura tus dispositivos como quieras y luego captúralos como escena.';

  @override
  String get scenesNewButton => 'Nueva escena';

  @override
  String scenesActivated(Object name) {
    return '$name activada';
  }

  @override
  String get scenesActivateOffline =>
      'Sin conexión: no se puede activar la escena';

  @override
  String get sceneFormNewTitle => 'Nueva escena';

  @override
  String get sceneFormEditTitle => 'Editar escena';

  @override
  String get sceneFormNameLabel => 'Nombre de la escena';

  @override
  String get sceneFormDevicesHeader => 'Dispositivos a capturar';

  @override
  String get sceneFormCaptureHint =>
      'Se guarda el estado configurable actual de cada dispositivo seleccionado (encendido/apagado, brillo, color, posición…). Los valores de solo lectura se ignoran.';

  @override
  String get sceneFormNoDevices =>
      'No se encontraron dispositivos controlables. Asegúrate de que estén emparejados y toca actualizar.';

  @override
  String get sceneFormReadingState => 'Leyendo el estado actual…';

  @override
  String get sceneCtrlPower => 'Encendido';

  @override
  String get sceneCtrlBrightness => 'Brillo';

  @override
  String get sceneCtrlPosition => 'Posición';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Selecciona al menos un dispositivo para capturar.';

  @override
  String get sceneFormNothingCaptured =>
      'No se capturó nada configurable de los dispositivos seleccionados.';

  @override
  String get sceneDeleteTitle => '¿Eliminar la escena?';

  @override
  String sceneDeleteMessage(Object name) {
    return 'Se eliminará «$name». Los dispositivos conservan su estado actual.';
  }

  @override
  String get sceneEditAction => 'Editar';

  @override
  String get sceneDeleteAction => 'Eliminar';

  @override
  String get sceneAddToDashboard => 'Añadir al tablero';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Añadida a $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count dispositivos';
  }

  @override
  String get panelTypeScene => 'Escena';

  @override
  String get panelPickerSceneTitle => 'Botón de escena';

  @override
  String get panelPickerSceneSubtitle => 'Un toque activa una escena guardada';

  @override
  String get panelSceneChoose => 'Escena';

  @override
  String get panelSceneMissing => 'Escena no encontrada: vuelve a elegirla';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get languageSpanish => 'Español';

  @override
  String get guidedConnectTitle => 'Configurar broker';

  @override
  String get guidedConnectIntro =>
      'Probaremos cada paso de la conexión y mostraremos tus dispositivos Zigbee.';

  @override
  String get guidedBaseTopic => 'Tema base';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Probar y conectar';

  @override
  String get guidedTesting => 'Probando la conexión…';

  @override
  String get stepResolve => 'Resolver host';

  @override
  String get stepTcp => 'Conexión TCP';

  @override
  String get stepConnack => 'Handshake MQTT';

  @override
  String get stepAuth => 'Autenticación';

  @override
  String get stepDevices => 'Buscando dispositivos';

  @override
  String get diagResolveFail =>
      'No se pudo resolver el nombre del host. Comprueba la dirección introducida.';

  @override
  String get diagResolveTimeout =>
      'Se agotó el tiempo al resolver el host. Comprueba la dirección y la red.';

  @override
  String get diagTcpFail =>
      'No se puede alcanzar el broker. ¿Está Zigbee2MQTT en marcha? Comprueba la dirección y el puerto.';

  @override
  String get diagTcpTimeout =>
      'Se agotó el tiempo de conexión con el broker. Puede estar desconectado o ser inalcanzable.';

  @override
  String get diagConnackFail =>
      'El broker no completó el handshake MQTT. Asegúrate de que es un broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'El broker rechazó el usuario o la contraseña. Comprueba tus credenciales.';

  @override
  String get diagAuthRefused =>
      'El broker rechazó la conexión. Comprueba la configuración de conexión.';

  @override
  String foundDevices(Object count) {
    return 'Se encontraron $count dispositivos';
  }

  @override
  String get foundDevicesHint =>
      'Tus dispositivos Zigbee son visibles. Continúa para crear tu panel.';

  @override
  String get noDevicesTitle => 'Conectado: aún no se encontraron dispositivos';

  @override
  String get noDevicesHint =>
      'ZigDash ve el broker, pero aún no ha encontrado dispositivos Zigbee. Puedes iniciar el emparejamiento.';

  @override
  String get startPairing => 'Iniciar emparejamiento';

  @override
  String get pairingEnabled =>
      'El emparejamiento está activado. Pulsa el botón de emparejamiento en tu dispositivo.';

  @override
  String get continueToDashboard => 'Continuar al panel';

  @override
  String get guidedBackToForm => 'Editar configuración';

  @override
  String ladderTriedHint(Object count) {
    return 'Se probaron $count direcciones';
  }

  @override
  String get guidedSaveFailed =>
      'No se pudo guardar la conexión. Inténtalo de nuevo.';

  @override
  String get onboardingConnectBroker => 'Conectar mi broker';
}
