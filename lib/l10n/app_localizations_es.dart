// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Último valor conocido';

  @override
  String get reliabilityControlsUnavailable => 'Controles no disponibles';

  @override
  String get appTitle => 'ZigDash';

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
  String get connectionsTitle => 'Casas';

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
      'La IP del broker es la IP del hub. Abre la página web del hub (smhub.local): en el Dashboard, el recuadro Network la muestra junto a IPv4. La app de tu router también muestra el hub como SMHUB. El puerto es 1883, sin usuario/contraseña por defecto.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA no tiene broker MQTT: habla directamente con Home Assistant, así que ZigDash no puede conectarse. Para usar ZigDash, cambia a Zigbee2MQTT (disponible como aplicación de Home Assistant o como contenedor Docker), que incluye un broker MQTT.';

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
  String get connUsername => 'Usuario';

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
  String get dashFormLock => 'Bloqueo de edición';

  @override
  String get dashFormLockSubtitle => 'Oculta Editar en este panel';

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
  String get panelTypeDevice => 'Dispositivo';

  @override
  String get panelTypeReading => 'Lectura';

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
  String get tileSize => 'Tamaño';

  @override
  String get tileSizeSmall => 'Pequeño';

  @override
  String get tileSizeWide => 'Ancho';

  @override
  String get tileSizeFull => 'Completo';

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
      'Aún no hay mosaicos.\nToca Añadir mosaico para poner aquí tus dispositivos.';

  @override
  String get panelsOffline => 'Sin conexión: mostrando últimos valores';

  @override
  String get connectionConnecting => 'Conectando…';

  @override
  String get connectionReconnecting => 'Reconectando…';

  @override
  String get connectionShowingLastKnownValues =>
      'Mostrando los últimos valores conocidos';

  @override
  String get connectionFailed => 'Error de conexión';

  @override
  String get connectionAutomaticRetry =>
      'Los reintentos automáticos continuarán';

  @override
  String get connectionReconnectNow => 'Reconectar ahora';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsHelp => 'Ayuda y guía';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsRateApp => 'Califica ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      '¿Te gusta? Una reseña rápida ayuda a otros a encontrarla.';

  @override
  String get settingsFeatureRequest => 'Proponer una función';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Cuéntame qué haría mejor a ZigDash.';

  @override
  String get featureRequestGithub => 'En GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Público: otros pueden verlo y votarlo.';

  @override
  String get featureRequestEmail => 'Por correo';

  @override
  String get featureRequestEmailSubtitle =>
      'Privado, directo al desarrollador.';

  @override
  String get featureRequestEmailSubject => 'ZigDash: solicitud de función';

  @override
  String get featureRequestEmailPrompt =>
      '¿Qué te gustaría que hiciera ZigDash y por qué?';

  @override
  String get settingsReportProblem => 'Informar de un problema';

  @override
  String get settingsReportProblemSubtitle =>
      '¿Algo falla o confunde? Cuéntamelo.';

  @override
  String get reportProblemEmailSubject => 'ZigDash: informe de problema';

  @override
  String get reportProblemEmailPrompt => '¿Qué pasó y qué esperabas?';

  @override
  String get settingsBuyCoffee => 'Invítame un café';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratis y de código abierto — las propinas mantienen el café fluyendo.';

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
  String get a11yRefresh => 'Actualizar';

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
  String get devicesListMissing =>
      'Zigbee2MQTT no ha enviado su lista de dispositivos. Puede pasar después de reiniciar el bróker MQTT.';

  @override
  String get devicesRestartZ2m => 'Reiniciar Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Reiniciando Zigbee2MQTT. Tus dispositivos deberían aparecer en unos segundos.';

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
  String get scenesAllShutters => 'Todas las persianas';

  @override
  String get sceneCloseAllShutters => 'Cerrar todas las persianas';

  @override
  String get sceneOpenAllShutters => 'Abrir todas las persianas';

  @override
  String get sceneStopAllShutters => 'Detener todas las persianas';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persianas',
      one: '1 persiana',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Qué persianas…';

  @override
  String get sceneWhichShuttersHint =>
      'Se incluyen todas las persianas de esta casa. Desmarca las que deban quedar fuera, como una puerta de garaje.';

  @override
  String get scenesYours => 'Tus escenas';

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
  String get languageFrench => 'Français';

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
      'El broker no aceptó la conexión. Comprueba que tu broker MQTT (normalmente Mosquitto) está en marcha y acepta conexiones de otros dispositivos, y que la dirección y el puerto (normalmente 1883) son correctos.';

  @override
  String get diagTcpTimeout =>
      'Se agotó el tiempo de conexión con el broker. Puede estar desconectado o ser inalcanzable.';

  @override
  String get diagConnackFail =>
      'El broker no completó el handshake MQTT. Asegúrate de que es un broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'El broker no respondió al inicio de sesión a tiempo. Home Assistant puede tardar unos segundos en comprobarlo; inténtalo de nuevo.';

  @override
  String get diagAuthRejected =>
      'El broker rechazó el usuario o la contraseña. Comprueba tus credenciales.';

  @override
  String get diagAuthRefused =>
      'El broker rechazó la conexión. Comprueba la configuración de conexión.';

  @override
  String get diagResolveLocalName =>
      'Tu teléfono no encontró este nombre. Android a menudo no resuelve nombres que terminan en .local; escribe la dirección IP (Home Assistant la muestra en Ajustes › Sistema › Red).';

  @override
  String get diagTcpHaNoBroker =>
      'Este es tu Home Assistant, pero no tiene ningún broker MQTT en marcha. Instala e inicia la aplicación Mosquitto broker (Configuración › Aplicaciones) y vuelve a intentarlo.';

  @override
  String get diagTcpSmlightClosed =>
      'Este es tu hub SMLIGHT, pero su broker MQTT no acepta conexiones de otros dispositivos. En la página web del hub, abre Settings › MQTT, activa Allow External, guarda y vuelve a intentarlo.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'En esta dirección corre Zigbee2MQTT, pero llega a su broker con otro nombre (ver Zigbee2MQTT › Settings › MQTT › Server). Si es otra máquina, escribe su dirección, normalmente con el puerto 1883. Si es un contenedor en esta máquina, publica su puerto (ports: \"1883:1883\") y deja que escuche en la red; luego vuelve a intentarlo.';

  @override
  String get diagTcpZ2mNoBroker =>
      'En esta dirección funciona Zigbee2MQTT, pero su broker MQTT no acepta conexiones de otros dispositivos. Mosquitto solo escucha en su propia máquina hasta que añades las líneas \"listener 1883\" y \"allow_anonymous true\" a mosquitto.conf (o configuras una contraseña). Reinicia Mosquitto y vuelve a intentarlo.';

  @override
  String get diagAuthRejectedHa =>
      'El broker de Home Assistant rechazó este inicio de sesión. Usa el nombre y la contraseña de un usuario de Home Assistant (Ajustes › Personas › Usuarios); lo mejor es un usuario solo para MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se encontraron $count dispositivos',
      one: 'Se encontró 1 dispositivo',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => '¿Atascado? Pregunta a una persona';

  @override
  String get guidedStuckBody =>
      'Dos intentos sin conexión. Dinos qué hub tienes y qué escribiste, y te ayudamos a encontrarlo.';

  @override
  String get guidedStuckTelegram => 'Preguntar en Telegram';

  @override
  String get guidedStuckHelp => 'Consejos y correo';

  @override
  String ladderTriedHint(Object count) {
    return 'Se probaron $count direcciones';
  }

  @override
  String get guidedSaveFailed =>
      'No se pudo guardar la conexión. Inténtalo de nuevo.';

  @override
  String get setupWelcomeTitle => 'Bienvenido a ZigDash';

  @override
  String get setupWelcomeHeadline => 'Tu hogar Zigbee, en tu móvil';

  @override
  String get setupWelcomeBody =>
      'Solo necesitas un hub pequeño con Zigbee2MQTT: un hub SMLIGHT, una Raspberry Pi o cualquier equipo Linux. No hace falta Home Assistant, y si lo tienes, ZigDash también funciona con él. Todo queda en local, sin nube.';

  @override
  String get setupFindMySetup => 'Encontrar mi instalación';

  @override
  String get setupErrPageTitle => 'La página de Zigbee2MQTT no respondió';

  @override
  String get setupErrPageBody =>
      'Ninguna página de Zigbee2MQTT respondió en esa dirección. Ábrela en el navegador de este teléfono para comprobarla y copia la dirección exacta (con su puerto, a menudo 8080). Si la página pide un token, introduce los datos de tu broker.';

  @override
  String get setupErrPageAction => 'Reintentar';

  @override
  String get setupLookWider => 'Buscar en toda la red';

  @override
  String get setupAsk => '¿Qué mueve tu Zigbee?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'En una Raspberry Pi, un servidor o Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Con la aplicación Zigbee2MQTT, o ZHA';

  @override
  String get setupAskSmlight => 'SMLIGHT';

  @override
  String get setupAskSmlightSub => 'Un SMHUB o un adaptador SLZB';

  @override
  String get setupAskSmlightWhich => '¿Qué dispositivo SMLIGHT tienes?';

  @override
  String get setupAskSmhub => 'SMHUB';

  @override
  String get setupAskSmhubSub => 'Zigbee2MQTT funciona en el propio hub';

  @override
  String get setupAskSlzb => 'Un adaptador SLZB';

  @override
  String get setupAskSlzbSub =>
      'SLZB-06, SLZB-MR y otros: solo la radio Zigbee';

  @override
  String get setupSlzbWhere =>
      'Tu SLZB es la radio Zigbee. Zigbee2MQTT funciona en otro equipo: ¿en cuál?';

  @override
  String get setupRunningAsk => '¿Zigbee2MQTT ya está funcionando?';

  @override
  String get setupRunningYes => 'Sí, funciona';

  @override
  String get setupRunningNotYet => 'Todavía no';

  @override
  String get setupRunningNotSure => 'No estoy seguro';

  @override
  String get setupRunningYesNote =>
      'Entonces este teléfono no lo alcanza desde aquí. Lo más habitual es que el teléfono esté en una red de invitados u otra Wi-Fi, o que el bróker solo acepte conexiones de su propia máquina (Mosquitto 2 lo hace hasta que su configuración tenga \"listener 1883\"). Escribe su dirección abajo para comprobarla.';

  @override
  String get setupRunningNotYetNote =>
      'ZigDash se conecta a un Zigbee2MQTT que ya funciona. Mira lo que necesitas para empezar y, mientras tanto, prueba la demo.';

  @override
  String setupRunningNotSureNote(String button) {
    return 'Zigbee2MQTT tiene su propia página web, donde emparejas tus dispositivos Zigbee. Si la has abierto, funciona: toca \"$button\" abajo. Si nunca la has visto, aún no está configurado.';
  }

  @override
  String get setupRunningWhatToGet => 'Lo que necesitas';

  @override
  String get setupAskNothing => '¿Aún nada?';

  @override
  String get setupAskHaWhich => '¿Cómo maneja Zigbee tu Home Assistant?';

  @override
  String get setupAskHaZ2m => 'La aplicación Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Iniciar sesión con Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, el Zigbee propio de Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, sin Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Conectar a mi página de Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Datos del broker (avanzado)';

  @override
  String get z2mPageTitle => 'Tu página de Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'La dirección en tu navegador cuando la página de Zigbee2MQTT está abierta, la que usas para emparejar dispositivos. No hace falta usuario ni contraseña MQTT.';

  @override
  String get z2mPageLabel => 'Dirección de la página';

  @override
  String get z2mPageConnect => 'Conectar';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host encontrado en $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Nada respondió por $host en esta red';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Las automatizaciones necesitan tu broker MQTT';

  @override
  String get engineNeedsBrokerBody =>
      'Esta casa se conecta por la página de Zigbee2MQTT, suficiente para tus paneles. Las automatizaciones, alertas e historial funcionan en el ZigDash Engine de tu hub, que habla a través de tu broker MQTT. Añade sus datos una vez y ZigDash se conectará por el broker desde entonces.';

  @override
  String get engineNeedsBrokerButton => 'Añadir datos del broker';

  @override
  String get connFromPageNote =>
      'Esta casa se conecta por la página de Zigbee2MQTT. Introduce tu broker MQTT (normalmente el mismo equipo, puerto 1883) para activar automatizaciones, alertas e historial. Al guardar, ZigDash se conecta por el broker.';

  @override
  String get setupManualEntry => 'Introducir datos manualmente';

  @override
  String get setupScanningTitle => 'Buscando una conexión…';

  @override
  String get setupScanningHint =>
      'Mantén este dispositivo en la misma red local que tu host de Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Posible conexión encontrada';

  @override
  String get setupNoCandidatesTitle => 'No se encontró ninguna conexión';

  @override
  String get setupNoCandidatesBody => '¿Dónde se ejecuta Zigbee2MQTT?';

  @override
  String get setupGuideHa =>
      'Home Assistant: comprueba que las aplicaciones Mosquitto broker y Zigbee2MQTT están instaladas y en marcha (Configuración › Aplicaciones).';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux: comprueba que tu broker (p. ej. Mosquitto) y el servicio Zigbee2MQTT estén en ejecución y que el puerto 1883 sea accesible.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB: abre la interfaz web, ve a Settings > MQTT, activa Allow External para que el móvil llegue al bróker y comprueba que Zigbee2MQTT está en marcha.';

  @override
  String get setupTryAgain => 'Reintentar';

  @override
  String get reminderButton => 'Recuérdamelo mañana';

  @override
  String get reminderSet => 'Te lo recordaremos mañana, en este teléfono.';

  @override
  String get reminderNoPermission =>
      'Las notificaciones de ZigDash están desactivadas, así que no habrá recordatorio. Puedes activarlas en los ajustes de Android.';

  @override
  String get reminderChannel => 'Recordatorio de configuración';

  @override
  String get reminderTitle => 'Termina de configurar ZigDash';

  @override
  String get reminderBody =>
      '¿En casa con tu Wi-Fi? Toca para volver a intentarlo: tarda un minuto.';

  @override
  String get setupWelcomeNoZ2m => '¿Aún no tienes Zigbee2MQTT?';

  @override
  String get setupWelcomeDemo => 'Prueba la casa de demostración';

  @override
  String get setupWelcomeHubs => 'Qué hub elegir';

  @override
  String get haConnectTitle => 'Conectar a través de Home Assistant';

  @override
  String get haConnectIntro =>
      'Tu teléfono no alcanza el broker, pero sí a Home Assistant. Inicia sesión una vez y ZigDash hablará con Zigbee2MQTT a través de Home Assistant: en casa o fuera, sin ajustes del broker.';

  @override
  String get haConnectAddressHelp =>
      'La dirección con la que abres Home Assistant: 192.168.1.20:8123, o una dirección remota como la de Nabu Casa o Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'El inicio de sesión de Home Assistant se abre en tu navegador. ZigDash nunca ve tu contraseña.';

  @override
  String get haConnectKeeps =>
      'ZigDash guarda este inicio de sesión en tu teléfono y actúa como tú en Home Assistant, solo para MQTT. Puedes terminarlo cuando quieras en Home Assistant, en Perfil › Seguridad.';

  @override
  String get haConnectTokenHelp =>
      'En Home Assistant, abre tu perfil y luego Seguridad › Tokens de acceso de larga duración › Crear token. Cópialo y pégalo aquí. ZigDash lo guarda en este teléfono para conectarse; bórralo en Home Assistant cuando quieras terminar.';

  @override
  String get haConnectWithToken => 'Conectar con token';

  @override
  String get haConnectChecking => 'Comprobando Home Assistant…';

  @override
  String get setupStillChecking =>
      'Seguimos comprobando. Puede tardar hasta 30 segundos.';

  @override
  String get aiHelpTitle => '¿Atascado? Pregunta a tu asistente de IA';

  @override
  String get aiHelpBody =>
      'ZigDash resume lo que encontró para ChatGPT, Claude, Gemini o cualquier app de IA, sin contraseñas ni direcciones. Lo ves antes de compartirlo.';

  @override
  String get aiHelpButton => 'Preguntar a una IA';

  @override
  String get aiHelpPreviewTitle => 'Lo que se compartirá';

  @override
  String get aiHelpShare => 'Compartir con una app de IA';

  @override
  String get aiHelpCopied => 'Copiado. Pégalo en cualquier chat de IA.';

  @override
  String get haConnectWhereAddress =>
      '¿No sabes cuál es? En la app de Home Assistant, abre Ajustes › Companion app y toca tu servidor: ahí está la dirección. En un ordenador, es la que muestra el navegador con Home Assistant abierto.';

  @override
  String get haFindLooking => 'Buscando Home Assistant en esta red…';

  @override
  String get haFindSeveral =>
      'Se encontró más de un Home Assistant. Toca el que quieras usar:';

  @override
  String get haFindNone =>
      'Este teléfono no ve Home Assistant en esta Wi-Fi. Usa la dirección que abre tu app de Home Assistant: a menudo una remota, como https://abcd1234.ui.nabu.casa o https://micasa.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Esa dirección está en una red distinta a la de este teléfono, que está en $network. Usa la dirección que abre tu app de Home Assistant, a menudo una remota, o conecta el teléfono a la red de Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Este teléfono no encontró ese nombre: Android a menudo no abre los nombres .local. Escribe la dirección IP de Home Assistant (como 192.168.1.20:8123) o su dirección remota.';

  @override
  String get haConnectRemoteUnreachable =>
      'Nada respondió en esa dirección remota. Ábrela en el navegador de este teléfono para comprobar que funciona y cópiala tal como la muestra tu app de Home Assistant.';

  @override
  String get setupNoWifiHa => '¿Usas Home Assistant? Inicia sesión';

  @override
  String get haConnectNotAdmin =>
      'Tu usuario de Home Assistant no es administrador. ZigDash necesita uno para el MQTT de Home Assistant. Inicia sesión como administrador o pega un token creado por un administrador.';

  @override
  String get haConnectNoMqtt =>
      'Este Home Assistant no tiene integración MQTT. Zigbee2MQTT también la necesita: en Home Assistant, añade la aplicación Mosquitto broker (Configuración › Aplicaciones) y la integración MQTT, y vuelve a intentarlo.';

  @override
  String get haConnectSignInFailed =>
      'El inicio de sesión no se completó. Inténtalo de nuevo o usa un token de larga duración.';

  @override
  String get setupHaShortcut =>
      '¿Zigbee2MQTT funciona en Home Assistant? Olvídate del broker y su usuario: inicia sesión con tu cuenta de administrador de Home Assistant. Funciona desde cualquier red.';

  @override
  String get haConnectButton => 'Conectar a través de Home Assistant';

  @override
  String get haConnectManualLink =>
      '¿Usas Home Assistant? Conéctate a través de él';

  @override
  String get haConnectEmptyNote =>
      '¿Este teléfono no alcanza el broker? Home Assistant puede llevar la conexión por ti.';

  @override
  String get haHomeConnected => 'Conectado a través de Home Assistant';

  @override
  String get haHomeChange =>
      'Si el inicio de sesión deja de funcionar, en un teléfono nuevo o tras quitar el token en Home Assistant, vuelve a iniciar sesión aquí. También puedes terminarlo en Home Assistant, en Perfil › Seguridad.';

  @override
  String get haHomeSignInAgain => 'Iniciar sesión de nuevo';

  @override
  String get haHomeRemote => 'Dirección remota de Home Assistant (opcional)';

  @override
  String get setupAuthTitle => 'Este broker requiere inicio de sesión';

  @override
  String setupAuthBody(Object host) {
    return 'Introduce el usuario y la contraseña de MQTT para $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'El usuario o la contraseña fueron rechazados. Compruébalos e inténtalo de nuevo.';

  @override
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT ya inicia sesión en este broker: su página web muestra el usuario en Ajustes › MQTT. Usa ese usuario y su contraseña.';

  @override
  String get setupAuthWhich =>
      'Es el acceso MQTT, no la contraseña de la página web de tu hub.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant: usa un usuario de Home Assistant. La mayoría crea uno solo para MQTT en Configuración › Personas › Usuarios, y la aplicación Mosquitto broker lo acepta.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi o Docker: el usuario y la contraseña del archivo de contraseñas de Mosquitto, los mismos que en configuration.yaml de Zigbee2MQTT bajo mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT: el acceso que aparece en la página web del hub en Settings › MQTT. O activa ahí Allow Anonymous y guarda: así no hace falta acceso.';

  @override
  String get setupVerifyingTitle => 'Comprobando la conexión…';

  @override
  String get setupReviewTitle => 'Tus dispositivos';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos encontrados.',
      one: '1 dispositivo encontrado.',
    );
    return '$_temp0 Elige qué va en tu primer panel.';
  }

  @override
  String get setupReviewLastStep =>
      'Último paso: marca los dispositivos que quieras y toca Crear panel abajo.';

  @override
  String get setupLeaveTitle => '¿Crear tu panel?';

  @override
  String get setupLeaveBody =>
      'Tus dispositivos ya están encontrados. Crea el panel ahora o empieza de nuevo y pierde esta lista.';

  @override
  String get setupStartOver => 'Empezar de nuevo';

  @override
  String setupCreateWithCount(Object count) {
    return 'Crear panel con $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Aún no hay nada marcado. Marca los dispositivos que quieras en el panel, o créalo vacío y añade mosaicos más tarde.';

  @override
  String get setupCreateEmpty => 'Crear un panel vacío';

  @override
  String get setupGroupOther => 'Otros dispositivos';

  @override
  String get setupGroupUnsupported => 'Dispositivos no compatibles';

  @override
  String get setupCreatingTitle => 'Creando tu panel…';

  @override
  String get setupReadyTitle => 'Tu panel está listo';

  @override
  String setupReadyBody(Object count) {
    return '$count controles creados.';
  }

  @override
  String get setupOpenDashboard => 'Abrir panel';

  @override
  String get setupErrUnreachableTitle => 'No se puede alcanzar esta dirección';

  @override
  String get setupErrUnreachableBody =>
      'Este dispositivo y el host de Zigbee2MQTT no pueden comunicarse. Comprueba que ambos estén en la misma red local.';

  @override
  String get setupErrUnreachableAction => 'Reintentar';

  @override
  String get setupErrPortClosedTitle => 'Nada responde en este puerto';

  @override
  String get setupErrPortClosedBody =>
      'El host es accesible, pero ningún broker MQTT respondió. Comprueba que el broker esté en ejecución y que el puerto sea correcto.';

  @override
  String get setupErrPortClosedAction => 'Reintentar';

  @override
  String get setupErrAuthRequiredTitle => 'Inicio de sesión requerido';

  @override
  String get setupErrAuthRequiredBody =>
      'Este broker requiere un usuario y una contraseña.';

  @override
  String get setupErrAuthRequiredAction => 'Introducir inicio de sesión';

  @override
  String get setupErrAuthRejectedTitle => 'Inicio de sesión rechazado';

  @override
  String get setupErrAuthRejectedBody =>
      'El broker rechazó estas credenciales.';

  @override
  String get setupErrAuthRejectedAction => 'Reintentar';

  @override
  String get setupErrNotZ2mTitle => 'Aquí no hay Zigbee2MQTT';

  @override
  String get setupErrNotZ2mBody =>
      'Un broker MQTT responde aquí, pero no se encontraron topics de Zigbee2MQTT. Puede ser un broker diferente.';

  @override
  String get setupErrNotZ2mAction => 'Elegir otro';

  @override
  String get setupErrNoDevicesTitle => 'No se recibieron dispositivos';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT está en ejecución, pero no se publicaron dispositivos durante la comprobación. Empareja dispositivos en Zigbee2MQTT primero.';

  @override
  String get setupErrNoDevicesAction => 'Comprobar de nuevo';

  @override
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT no envió su lista de dispositivos';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT responde, pero su lista de dispositivos no llegó. Suele pasar tras reiniciar el broker MQTT: antes de la 2.14.2, Zigbee2MQTT solo vuelve a enviar la lista cuando se reinicia. Reinicia Zigbee2MQTT (o actualízalo) y vuelve a intentarlo.';

  @override
  String get setupErrListMissingAction => 'Reintentar';

  @override
  String get setupErrHaNoZ2mTitle =>
      'No hay Zigbee2MQTT en este Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Has iniciado sesión en Home Assistant, pero Zigbee2MQTT no está enviando nada por su MQTT. Si tus dispositivos Zigbee están en ZHA (el Zigbee integrado de Home Assistant), ZigDash no puede verlos: funciona con Zigbee2MQTT. Si usas la aplicación Zigbee2MQTT, ábrela en Configuración › Aplicaciones, comprueba que está iniciada y vuelve a intentarlo.';

  @override
  String get setupErrHaNoZ2mAction => 'Reintentar';

  @override
  String get setupErrScanFailedTitle => 'Sin red local';

  @override
  String get setupErrScanFailedBody =>
      'No se pudo determinar la red local de este dispositivo. Conéctate al Wi-Fi e inténtalo de nuevo.';

  @override
  String get setupErrScanFailedAction => 'Reintentar';

  @override
  String get setupNoWifiTitle => 'Tu teléfono no está en Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Está usando datos móviles, así que no ve los dispositivos de casa. Activa el Wi-Fi y conéctate a la red de casa: la configuración se reinicia sola.';

  @override
  String get setupNoWifiOffline =>
      'Tu teléfono no tiene conexión de red. Activa el Wi-Fi y conéctate a la red de casa: la configuración se reinicia sola.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash no encuentra la dirección Wi-Fi de tu teléfono. Comprueba que el Wi-Fi esté activado y conectado a la red de casa: la configuración se reinicia sola. ¿Con VPN o fuera de casa? Introduce los datos manualmente.';

  @override
  String get setupOpenWifiSettings => 'Abrir ajustes de Wi-Fi';

  @override
  String get setupWaitingForWifi => 'Esperando Wi-Fi…';

  @override
  String get setupErrSaveFailedTitle => 'No se pudo guardar';

  @override
  String get setupErrSaveFailedBody =>
      'Error al guardar tu instalación. Nada se guardó a medias — puedes reintentarlo con seguridad.';

  @override
  String get setupErrSaveFailedAction => 'Reintentar';

  @override
  String get setupErrUnknownTitle => 'Algo salió mal';

  @override
  String get setupErrUnknownBody => 'Ocurrió un error inesperado.';

  @override
  String get setupErrUnknownAction => 'Reintentar';

  @override
  String get setupErrLoginNoAnswerTitle =>
      'El broker no respondió al inicio de sesión';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Se encontró tu broker, pero no respondió a tiempo al usuario y la contraseña. La aplicación Mosquitto broker de Home Assistant comprueba los inicios de sesión con Home Assistant, lo que puede tardar unos segundos en una Raspberry Pi. Vuelve a intentarlo y comprueba que este usuario existe en Home Assistant. En un hub SMLIGHT, activa en su lugar Allow Anonymous en Settings › MQTT y no hará falta acceso.';

  @override
  String get setupErrLoginNoAnswerAction => 'Reintentar';

  @override
  String get setupNoZ2mTitle =>
      'Tu bróker funciona, pero Zigbee2MQTT no publica aquí';

  @override
  String setupNoZ2mBody(String base) {
    return 'Escuchamos en $base/bridge y no llegó nada.';
  }

  @override
  String get setupBaseTopicQuestion => '¿Usas otro tema base?';

  @override
  String get setupGuidesTitle => 'Configurar Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Prueba la demo mientras tanto';

  @override
  String get setupPlatformQuestion =>
      'Mientras buscamos: ¿dónde se ejecuta Zigbee2MQTT?';

  @override
  String get setupPlatformQuestionDone => '¿Dónde se ejecuta Zigbee2MQTT?';

  @override
  String get setupScanDoneTitle => 'Elige una conexión';

  @override
  String get setupScanDoneHint =>
      'Respondió más de un broker. Elige el que usa Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'SMHUB';

  @override
  String get setupPlatformPi => 'Raspberry Pi o Docker';

  @override
  String get setupPlatformZha => 'ZHA, sin Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash muestra dispositivos de Zigbee2MQTT, así que no ve los dispositivos de ZHA, el Zigbee propio de Home Assistant. Puedes probar la casa de demostración para ver cómo funciona ZigDash.';

  @override
  String get setupPlatformNotSure => 'No lo sé';

  @override
  String setupScanProgress(int checked, int total) {
    return '$checked de $total direcciones comprobadas';
  }

  @override
  String get setupScanHintHa => 'Buscando Home Assistant y su broker MQTT…';

  @override
  String get setupScanHintSmlight => 'Buscando tu SMHUB…';

  @override
  String get setupScanHintPi => 'Buscando un broker MQTT en tu red…';

  @override
  String setupHubSeenHa(String host) {
    return 'Home Assistant encontrado en $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Zigbee2MQTT encontrado en $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Tu hub SMLIGHT encontrado en $host';
  }

  @override
  String get setupHubSeenHint => 'Seguimos buscando su broker MQTT…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant encontrado, pero sin broker MQTT';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant está en $host, pero nada responde en el puerto MQTT 1883. En Home Assistant, abre Configuración › Aplicaciones, instala e inicia la aplicación Mosquitto broker y vuelve a intentarlo.';
  }

  @override
  String get setupNoBrokerHaZha =>
      '¿Usas el Zigbee propio de Home Assistant (ZHA) en lugar de Zigbee2MQTT? ZigDash solo funciona con Zigbee2MQTT, así que no ve los dispositivos de ZHA. La demo muestra lo que tendrías.';

  @override
  String get setupNoBrokerHaDocker =>
      '¿No hay Aplicaciones en la Configuración de tu Home Assistant? Entonces funciona en Docker (Home Assistant Container), que no tiene aplicaciones: Mosquitto funciona en su propio contenedor. Escribe abajo la dirección del equipo donde funciona.';

  @override
  String get setupVpnHint =>
      'Hay una VPN activa, y puede ocultar tu red de casa a la búsqueda. Si estás en casa, desactiva la VPN y pulsa Reintentar. O déjala activa y permite el acceso a la red local (LAN) en los ajustes de la app de VPN.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT encontrado, pero su broker no es accesible';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT está en $host, pero su broker MQTT no acepta conexiones desde tu teléfono. Mosquitto 2 solo escucha en el propio hub hasta que su configuración tenga \'listener 1883\' y \'allow_anonymous true\' (o un usuario). Reinícialo y vuelve a intentarlo.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Hub SMLIGHT encontrado, pero MQTT está apagado';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Tu hub está en $host, pero su broker MQTT no es accesible. En la interfaz web del hub, abre Settings › MQTT, activa Allow External y comprueba que Zigbee2MQTT está en marcha. Luego vuelve a intentarlo.';
  }

  @override
  String get setupZ2mAsking =>
      'Preguntando a Zigbee2MQTT dónde está su broker…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Tu broker solo acepta conexiones desde su propio equipo';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT usa $server, y desde tu móvil no responde nada ahí. Mosquitto 2 lo hace así por defecto. Añade estas dos líneas a mosquitto.conf, reinicia Mosquitto y vuelve a intentarlo:';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      '¿Prefieres usuario y contraseña en lugar de acceso abierto? Usa un password_file en vez de allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT llega a su broker por un nombre que tu teléfono no puede usar';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT usa $server. \"$name\" es un nombre que solo conoce la máquina de Zigbee2MQTT, un servicio de Docker o un nombre de host. Escribe en su lugar la dirección IP de la máquina del broker con el puerto $port. Si el broker corre en un contenedor, su puerto también debe estar publicado en la máquina (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'La página web de Zigbee2MQTT está protegida con un token, así que la app no pudo leer dónde está su broker. Escribe la dirección del broker que aparece en Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT usa el broker en $server, pero no respondió desde tu móvil. Comprueba que el broker esté en marcha y que tu móvil esté en la misma red.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Conectar a $host';
  }

  @override
  String get setupNotFoundHa =>
      'No se encontró Home Assistant en esta red. Comprueba que tu teléfono esté en la misma Wi-Fi que Home Assistant (no una red de invitados) y vuelve a intentarlo. Si conoces su dirección, introdúcela abajo.';

  @override
  String get setupNotFoundSmlight =>
      'No se encontró ningún hub SMLIGHT en esta red. Comprueba que el hub esté encendido y tu teléfono en la misma Wi-Fi, y vuelve a intentarlo. Si conoces su dirección, introdúcela abajo.';

  @override
  String get setupNotFoundPi =>
      'No se encontró ningún broker MQTT en esta red. Comprueba que Mosquitto está en marcha y escucha en la red (puerto 1883) y que tu teléfono está en la misma Wi-Fi. Luego vuelve a intentarlo.';

  @override
  String get setupAddressQuestionHa => '¿Dónde abres Home Assistant?';

  @override
  String get setupAddressQuestionSmlight =>
      '¿Cuál es la dirección de tu hub SMLIGHT?';

  @override
  String get setupAddressWhereSmlight =>
      'Abre la página web de tu hub: smhub.local, o smhub.local:3000 en los primeros hubs. En el Dashboard, el recuadro Network muestra la dirección junto a IPv4. Escríbela aquí. Si la página no se abre, la app de tu router muestra el hub como SMHUB, con su IP.';

  @override
  String get setupAddressSlzbSmlight =>
      'Un SLZB-06, MR o UltimaX es solo la radio Zigbee y no tiene broker. Escribe en su lugar la dirección del ordenador que ejecuta Zigbee2MQTT y Mosquitto.';

  @override
  String get setupAddressQuestionPi =>
      '¿Cuál es la dirección de la máquina donde corre Mosquitto?';

  @override
  String get setupAddressQuestionAny =>
      '¿Cuál es la dirección de tu hub, o de la máquina donde corre Zigbee2MQTT?';

  @override
  String get setupAddressHint =>
      'Una dirección como 192.168.1.20, un nombre o el enlace de tu navegador';

  @override
  String get setupAddressCheck => 'Comprobar esta dirección';

  @override
  String setupAddressNothing(String host) {
    return 'Nada respondió en $host. Comprueba la dirección y que tu teléfono esté en la misma Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'No se pudo resolver $host. Los nombres acabados en .local suelen fallar en Android; prueba con la dirección IP. Home Assistant la muestra en Ajustes › Sistema › Red.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return 'No se encuentra $host desde este teléfono; Android a menudo no puede resolver los nombres .local. Toca $button arriba y usa la dirección con la que abres Home Assistant en el navegador, o escribe aquí su dirección IP. Home Assistant la muestra en Ajustes › Sistema › Red.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host no está en tu red doméstica. Usa la dirección que funciona en tu Wi-Fi, no un enlace remoto como Nabu Casa o DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Introduce primero una dirección.';

  @override
  String get setupChoicesTitle => '¿Cuál de estas encaja contigo?';

  @override
  String get setupChoiceNoHub => 'Aún no tengo un hub';

  @override
  String get setupChoiceNoHubSub =>
      'Ver los hubs pequeños que ejecutan Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'Uso Home Assistant';

  @override
  String get setupChoiceHaSub => 'Buscarlo en homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash se conecta al broker MQTT de Home Assistant, la aplicación Mosquitto broker en Configuración › Aplicaciones, y Zigbee2MQTT también tiene que usarlo. Si no se encuentra homeassistant.local, escribe abajo la dirección IP de Home Assistant. Está en Configuración › Sistema › Red.';

  @override
  String get setupChoiceOther => 'Mi hub está en otra red';

  @override
  String get setupChoiceOtherSub =>
      'Una Wi-Fi de invitados o un segundo router';

  @override
  String get setupChoiceOtherNote =>
      'Tu teléfono tiene que poder llegar a tu hub. Una Wi-Fi de invitados, o un segundo router con su propia Wi-Fi, los separa. Conéctate a la Wi-Fi en la que está tu hub y toca Reintentar. O introduce abajo la dirección IP del hub, o prueba uno de estos nombres habituales:';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Tu teléfono es $ip, así que el hub suele empezar por $prefix.';
  }

  @override
  String get guidedHostHa =>
      '¿Usas Home Assistant? El host es la dirección con la que abres Home Assistant, puerto 1883.';

  @override
  String get demoBannerText => 'Estás en modo demo';

  @override
  String get demoBannerAction => 'Conecta tu hogar';

  @override
  String get deviceOn => 'Encendido';

  @override
  String get deviceOff => 'Apagado';

  @override
  String get deviceOpen => 'Abierto';

  @override
  String get deviceClosed => 'Cerrado';

  @override
  String get deviceMotion => 'Movimiento';

  @override
  String get deviceClear => 'Sin novedad';

  @override
  String get deviceLeakDetected => 'Fuga detectada';

  @override
  String get deviceSmokeDetected => 'Humo detectado';

  @override
  String get deviceGasDetected => 'Gas detectado';

  @override
  String get deviceWaiting => 'Esperando el primer informe';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on encendidos · $off apagados';
  }

  @override
  String get deviceBrightness => 'Brillo';

  @override
  String get deviceWhite => 'Blanco';

  @override
  String get deviceColor => 'Color';

  @override
  String get deviceHue => 'Tono';

  @override
  String get devicePosition => 'Posición';

  @override
  String get deviceControls => 'Controles';

  @override
  String deviceBattery(int percent) {
    return 'Batería $percent %';
  }

  @override
  String get deviceToggle => 'Encender o apagar';

  @override
  String get deviceMore => 'Más';

  @override
  String get sectionLights => 'Luces';

  @override
  String get sectionSwitchesCovers => 'Interruptores y persianas';

  @override
  String get sectionSensors => 'Sensores';

  @override
  String get sectionOther => 'Otros';

  @override
  String get homeFirstName => 'Mi casa';

  @override
  String homeNumberedName(int number) {
    return 'Casa $number';
  }

  @override
  String get dashAddTile => 'Añadir mosaico';

  @override
  String get addTileSearch => 'Buscar dispositivos';

  @override
  String get addTileNotOnDashboard => 'En ningún panel';

  @override
  String get addTileAllDevices => 'Todos los dispositivos';

  @override
  String get addTileReading => 'Lectura';

  @override
  String get addTileReadingSubtitle => 'Un valor de un dispositivo o topic';

  @override
  String get readingShowAs => 'Mostrar como';

  @override
  String get readingStyleValue => 'Valor';

  @override
  String get readingStyleGauge => 'Indicador';

  @override
  String get gaugeBands => 'Franjas de color';

  @override
  String get gaugeBandsHelper =>
      'Hasta tres. La franja en la que está el valor colorea el arco.';

  @override
  String get gaugeBandFrom => 'Desde';

  @override
  String get gaugeBandTo => 'Hasta';

  @override
  String get gaugeBandAdd => 'Añadir franja';

  @override
  String get gaugeBandRemove => 'Quitar franja';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Bueno';

  @override
  String get gaugeToneAttention => 'Atención';

  @override
  String get addTileCustom => 'Mosaico MQTT personalizado';

  @override
  String get addTileCustomSubtitle =>
      'Cualquier tipo de mosaico, configurado por topic';

  @override
  String get addTileNoDevices =>
      'No hay dispositivos. Conéctate a tu broker o empareja un dispositivo en Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Añadir';

  @override
  String get addTileName => 'Nombre';

  @override
  String addTileNameHint(String model) {
    return 'p. ej. $model';
  }

  @override
  String get addTileSection => 'Sección';

  @override
  String get addTileNoSection => 'Sin sección';

  @override
  String get addTileSize => 'Tamaño';

  @override
  String get deviceClassColorLight => 'Luz de color';

  @override
  String get deviceClassLight => 'Luz';

  @override
  String get deviceClassSwitch => 'Interruptor o enchufe';

  @override
  String get deviceClassCover => 'Persiana';

  @override
  String get deviceClassLeak => 'Fuga o humo';

  @override
  String get deviceClassContact => 'Contacto';

  @override
  String get deviceClassMotion => 'Movimiento';

  @override
  String get deviceClassClimate => 'Sensor de clima';

  @override
  String get deviceClassGeneric => 'Dispositivo';

  @override
  String get deviceNotResponding => 'No responde';

  @override
  String get homeAdd => 'Añadir una casa';

  @override
  String get homeManage => 'Gestionar casas';

  @override
  String get homeSwitch => 'Cambiar de casa';

  @override
  String get navDevices => 'Dispositivos';

  @override
  String get navScenes => 'Escenas';

  @override
  String get devicesNewDot => 'Dispositivos nuevos';

  @override
  String get editEditing => 'Editando';

  @override
  String get editDashboard => 'Panel';

  @override
  String get editDone => 'Listo';

  @override
  String get editAddSection => 'Añadir sección';

  @override
  String get editSectionName => 'Nombre de la sección';

  @override
  String get editRenameSection => 'Renombrar sección';

  @override
  String get editDeleteSection => 'Eliminar sección';

  @override
  String get editDeleteSectionBody => '¿Qué pasa con sus mosaicos?';

  @override
  String get editKeepTiles => 'Conservar mosaicos, quitar sección';

  @override
  String get editDeleteTiles => 'Eliminar también los mosaicos';

  @override
  String get editMoveToSection => 'Mover a sección';

  @override
  String get editEditTile => 'Editar mosaico';

  @override
  String get editRemove => 'Quitar del panel';

  @override
  String get editRemoved => 'Mosaico quitado';

  @override
  String get editUndo => 'Deshacer';

  @override
  String get editReplaceWithDevice => 'Sustituir por mosaico de dispositivo';

  @override
  String get editMoveEarlier => 'Mover antes';

  @override
  String get editMoveLater => 'Mover después';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos no están en ningún panel',
      one: '1 dispositivo no está en ningún panel',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Opciones del mosaico';

  @override
  String get editSave => 'Guardar';

  @override
  String get editCancel => 'Cancelar';

  @override
  String get ageJustNow => 'Ahora mismo';

  @override
  String ageMinutes(int n) {
    return 'hace $n min';
  }

  @override
  String ageHours(int n) {
    return 'hace $n h';
  }

  @override
  String get statusCantReach => 'No se puede contactar con el broker';

  @override
  String get statusWhy => '¿Por qué?';

  @override
  String get statusWhyTitle => 'Tu broker no responde';

  @override
  String get statusWhyBody =>
      'ZigDash sigue intentándolo solo. Mientras tanto, los mosaicos muestran sus últimos valores conocidos, atenuados y con su antigüedad. Comprueba que el broker esté encendido y el teléfono en la misma red, o prueba la conexión en sus ajustes.';

  @override
  String get statusSettings => 'Ajustes de conexión';

  @override
  String get deviceAddToDashboard => 'Añadir a un panel';

  @override
  String get deviceDismiss => 'Descartar';

  @override
  String get devicesFilterAll => 'Todos';

  @override
  String devicesFilterAttention(int count) {
    return 'Requieren atención · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'En ningún panel · $count';
  }

  @override
  String get devicesNoMatch => 'Ningún dispositivo coincide';

  @override
  String get deviceBatteryLow => 'Batería baja';

  @override
  String get deviceLinkWeak => 'Débil';

  @override
  String get deviceUnsupported => 'No compatible con Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'El emparejamiento no terminó';

  @override
  String get deviceNoReport => 'Sin datos todavía';

  @override
  String get devicesAvailabilityOff =>
      'La disponibilidad de Zigbee2MQTT está desactivada, así que los dispositivos desconectados aparecen como No responde.';

  @override
  String get devicesAvailabilityHow => 'Cómo activarla';

  @override
  String get devicesDotBattery => 'Batería baja';

  @override
  String get deviceDetails => 'Detalles del dispositivo';

  @override
  String get deviceGone => 'Este dispositivo ya no está en Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Control';

  @override
  String get deviceReadingsTitle => 'Lecturas';

  @override
  String get deviceHealthTitle => 'Estado';

  @override
  String get deviceOnDashboards => 'En paneles';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT aún no es compatible con este dispositivo, así que no hay nada que controlar.';

  @override
  String get deviceAddReadingTile => 'Añadir como mosaico de lectura';

  @override
  String get deviceAddReadingTo => '¿A qué panel añadirlo?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Añadido a $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Calidad del enlace';

  @override
  String get deviceLinkGood => 'Buena';

  @override
  String get devicePowerSource => 'Alimentación';

  @override
  String get devicePowerBattery => 'Batería';

  @override
  String get devicePowerMains => 'Red eléctrica';

  @override
  String get deviceLastHeard => 'Última señal';

  @override
  String get deviceAvailability => 'Disponibilidad';

  @override
  String get deviceAvailabilityOff => 'Desactivada en Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsPrivacySubtitle =>
      'Sin telemetría. Todo se queda en este teléfono.';

  @override
  String get homeCurrent => 'Casa actual';

  @override
  String get homeConnection => 'Conexión';

  @override
  String get homeSwitchTo => 'Cambiar a esta casa';

  @override
  String get homeDelete => 'Eliminar casa';

  @override
  String get devicesSelect => 'Elige un dispositivo';

  @override
  String get scenesSelect => 'Elige una escena para editar';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Elegir un dispositivo';

  @override
  String get panelFormStateTopic => 'Topic de estado';

  @override
  String get panelFormCommandTopic => 'Topic de comando';

  @override
  String get panelFormCommandTopicDerived =>
      'Se rellena a partir del topic de estado hasta que lo cambies.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Vinculado a $device';
  }

  @override
  String get panelFormOpenDevice => 'Abrir dispositivo';

  @override
  String get panelFormUnlink => 'Desvincular';

  @override
  String get panelFormValueChoices => 'Valores de este dispositivo';

  @override
  String get panelFormAdvanced => 'Avanzado';

  @override
  String get panelFormAdvancedSubtitle => 'Anular prefijo, QoS, retener';

  @override
  String get panelFormStateTopicHelper =>
      'Vacío = el propio prefijo (estado de un dispositivo Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Pantalla de pared';

  @override
  String get analyticsSetupCheckbox =>
      'Compartir datos de uso anónimos para mejorar la configuración';

  @override
  String get analyticsWhatsShared => 'Qué se comparte';

  @override
  String get analyticsCardTitle => '¿Ayudar a mejorar ZigDash?';

  @override
  String get analyticsCardBody =>
      'Compartir datos de uso anónimos: qué pasos de configuración fallan y qué funciones se usan. Nunca tus dispositivos, topics ni tu broker.';

  @override
  String get analyticsShare => 'Compartir';

  @override
  String get analyticsNoThanks => 'No, gracias';

  @override
  String get settingsAnalytics => 'Compartir datos de uso anónimos';

  @override
  String get settingsAnalyticsSubtitle =>
      'Pasos de configuración y funciones usadas. Nunca tus dispositivos, topics ni tu broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Datos de uso anónimos. Desactívalos con el interruptor de arriba.';

  @override
  String get dashDefaultName => 'Casa';

  @override
  String get dashExportSaveFile => 'Guardar archivo';

  @override
  String get dashExportSaved => 'Copia guardada';

  @override
  String get dashImportChooseFile => 'Elegir archivo';

  @override
  String get dashImportFileUnreadable => 'No se pudo leer ese archivo';

  @override
  String get getHelpTitle => 'Obtener ayuda';

  @override
  String get getHelpTryFirst => 'Prueba esto primero';

  @override
  String get getHelpPromise =>
      '¿Sigues atascado? Suelo responder en menos de 3 días, en inglés o en hebreo. Nunca te pediré tus contraseñas.';

  @override
  String get getHelpIncluded => 'Qué se incluye';

  @override
  String get getHelpContact => 'Contactar con soporte';

  @override
  String get getHelpCopy => 'Copiar datos';

  @override
  String get getHelpCopied => 'Datos copiados';

  @override
  String get getHelpLink => '¿Sigues atascado? Obtén ayuda';

  @override
  String get getHelpEmailSubject => 'ZigDash: ayuda para que funcione';

  @override
  String get getHelpEmailPrompt => '¿Qué intentabas hacer y qué pasó?';

  @override
  String get settingsHelpSupport => 'Ayuda y soporte';

  @override
  String get settingsGetHelp => 'Obtener ayuda';

  @override
  String get settingsGetHelpSubtitle =>
      '¿No consigues que funcione? Primero consejos, luego contacto';

  @override
  String get settingsCommunity => 'Únete a la comunidad de ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Grupo de Telegram: preguntas, ideas y novedades';

  @override
  String get getHelpCommunity => 'Preguntar en el grupo de Telegram';

  @override
  String get demoBannerHelp => 'Obtener ayuda';

  @override
  String get tipSameWifiTitle => 'La misma Wi-Fi que tu hub';

  @override
  String get tipSameWifiBody =>
      'Tu teléfono debe estar en la misma red que el hub, no en una red de invitados. Desactiva los datos móviles mientras lo configuras.';

  @override
  String get tipBrokerRunningTitle => 'El broker está en marcha';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: la aplicación Mosquitto broker está iniciada. Raspberry Pi: Mosquitto está en marcha. SMLIGHT: Settings › MQTT está activado.';

  @override
  String get tipBrokerAcceptsTitle => 'El broker acepta tu teléfono';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: activa Allow External. Mosquitto 2 solo acepta conexiones del propio hub hasta que se configura para escuchar en la red (puerto 1883).';

  @override
  String get tipMeshTitle => '¿Wi-Fi en malla o dos routers?';

  @override
  String get tipMeshBody =>
      'Si el hub cuelga de un segundo router, puede que tu teléfono no lo vea. Conecta el hub al router principal o conéctate por su dirección.';

  @override
  String get tipByAddressTitle => 'Conectar por dirección';

  @override
  String get tipByAddressBody =>
      'Busca la dirección del hub en la app de tu router y luego toca «Introducir datos manualmente».';

  @override
  String get tipSameNetworkTitle => 'La misma red';

  @override
  String get tipSameNetworkBody =>
      'El teléfono y el hub deben estar en la misma Wi-Fi. Desactiva los datos móviles.';

  @override
  String get tipAddressChangedTitle => 'La dirección ha cambiado';

  @override
  String get tipAddressChangedBody =>
      'Los hubs pueden recibir una dirección nueva tras reiniciarse. Compruébala en la app de tu router y resérvala allí para que no cambie.';

  @override
  String get tipRightPortTitle => 'El puerto correcto';

  @override
  String get tipRightPortBody =>
      'MQTT suele ir en el 1883 (8883 con TLS). El 8080 o el 80 es la interfaz web del hub, no MQTT.';

  @override
  String get tipStartBrokerTitle => 'El broker está en marcha';

  @override
  String get tipStartBrokerBody =>
      'Inicia Mosquitto o la aplicación Mosquitto broker y vuelve a intentarlo.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 solo acepta conexiones del propio hub hasta que se configura para escuchar en la red (puerto 1883).';

  @override
  String get tipMqttLoginTitle => 'El acceso de MQTT, no el de la web';

  @override
  String get tipMqttLoginBody =>
      'La contraseña de la página web de tu hub no suele ser la de MQTT. Home Assistant: usa un usuario de Home Assistant, o el inicio de sesión configurado en la aplicación Mosquitto broker.';

  @override
  String get tipSpacesTitle => 'Revisa los espacios';

  @override
  String get tipSpacesBody =>
      'Al copiar una contraseña se puede colar un espacio al final.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT usa este broker';

  @override
  String get tipZ2mBrokerBody =>
      'En los ajustes de Zigbee2MQTT, comprueba que su servidor MQTT es este mismo broker.';

  @override
  String get tipBaseTopicTitle => 'Tema base';

  @override
  String get tipBaseTopicBody =>
      'Si cambiaste el tema base «zigbee2mqtt», introdúcelo en la configuración manual.';

  @override
  String get tipPairFirstTitle => 'Primero empareja dispositivos';

  @override
  String get tipPairFirstBody =>
      'Abre la interfaz web de Zigbee2MQTT, empareja al menos un dispositivo y vuelve a comprobarlo.';

  @override
  String get tipRestartZ2mTitle => 'Reiniciar Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Si hay dispositivos emparejados pero no llega ninguno, reinicia Zigbee2MQTT para que publique su lista de dispositivos.';

  @override
  String get tipNumberAddressTitle => 'Usa la dirección numérica';

  @override
  String get tipNumberAddressBody =>
      'Los nombres que terminan en .local no funcionan en todos los teléfonos Android. Prueba la dirección numérica del hub, como 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Puerto y protocolo';

  @override
  String get tipPortProtocolBody =>
      'Lo habitual es TCP en el 1883. Elige TLS o WebSocket solo si tu broker está configurado para ello.';

  @override
  String get tipManualLoginTitle => 'Usuario y contraseña';

  @override
  String get tipManualLoginBody =>
      'Deja el usuario y la contraseña vacíos si tu broker no los tiene. Si no, usa el acceso de MQTT, no el de la web del hub.';

  @override
  String get tipHubOnTitle => '¿Está encendido el hub?';

  @override
  String get tipHubOnBody =>
      'Un corte de luz o una actualización puede haberlo reiniciado. Dale un minuto cuando vuelva.';

  @override
  String get tipAwayTitle => '¿Estás en casa?';

  @override
  String get tipAwayBody =>
      'Fuera de casa, la app necesita una dirección remota (por ejemplo, Tailscale). Configúrala en los ajustes de conexión de la casa.';

  @override
  String get tipTailscaleIpTitle => 'Usa la IP de Tailscale, no el nombre';

  @override
  String get tipTailscaleIpBody =>
      'Los nombres que terminan en .ts.net a menudo no se resuelven dentro de las apps. Abre la app de Tailscale en el móvil y comprueba que está conectada; luego usa la dirección 100.x.y.z del hub como host remoto.';

  @override
  String get tipHomeAddressChangedTitle => '¿Ha cambiado la dirección?';

  @override
  String get tipHomeAddressChangedBody =>
      'Tras reiniciar el router, el hub puede recibir una dirección nueva. Reserva su dirección en la app de tu router y luego actualiza la casa.';

  @override
  String get tipRestartZ2mButtonTitle => 'Reiniciar Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Si el broker se reinició, la lista de dispositivos de Zigbee2MQTT desaparece hasta que Zigbee2MQTT se reinicia. Usa el botón «Reiniciar Zigbee2MQTT» de la pestaña Dispositivos.';

  @override
  String get tipZ2mRunningTitle => '¿Está en marcha Zigbee2MQTT?';

  @override
  String get tipZ2mRunningBody =>
      'Abre su interfaz web. Si no carga, reinícialo en tu hub.';

  @override
  String get tipCantConnectTitle => 'No puedo conectar con mi hub';

  @override
  String get tipCantConnectBody =>
      'Misma Wi-Fi, broker en marcha, Allow External activado o Mosquitto escuchando en la red; luego conéctate por dirección.';

  @override
  String get tipDeviceWrongTitle => 'Un dispositivo se ve mal o no responde';

  @override
  String get tipDeviceWrongBody =>
      'Compruébalo primero en la interfaz web de Zigbee2MQTT. Si allí funciona, usa «Informar de un problema».';

  @override
  String get tipHowDoITitle => '¿Cómo hago…?';

  @override
  String get tipHowDoIBody =>
      'Escenas, Pantalla de pared, programaciones y copias de seguridad están en «Ayuda y guía».';

  @override
  String get tipRenameHomeTitle => 'Renombrar una casa';

  @override
  String get tipRenameHomeBody =>
      '¿Una casa con el nombre de su dirección? Ajustes › Casas, toca la casa y luego Nombre.';

  @override
  String get tipWhatYouNeedTitle => 'Qué necesitas';

  @override
  String get tipWhatYouNeedBody =>
      'Un hub pequeño con Zigbee2MQTT y un broker MQTT (Mosquitto): un hub SMLIGHT, una Raspberry Pi o cualquier equipo Linux. Home Assistant también sirve, pero no hace falta.';

  @override
  String get tipSetupAtHomeTitle => 'En la misma Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Configúralo en casa, con el teléfono en la misma Wi-Fi que el hub.';

  @override
  String get tipFindSetupTitle => 'Después';

  @override
  String get tipFindSetupBody =>
      'Sal de la demo y toca «Encontrar mi instalación». ZigDash busca tu hub por sí solo.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'No se encontró ninguna app de correo. Copia los datos y escribe a $email.';
  }

  @override
  String get shortcutWorking => 'en curso…';

  @override
  String get shortcutCantReach => 'No se puede alcanzar tu casa';

  @override
  String get shortcutNotConfirmed => 'Sin confirmar';

  @override
  String get shortcutRemoved => 'Eliminado';

  @override
  String get shortcutSceneSent => 'Enviada';

  @override
  String get shortcutSceneConfirmed => 'Confirmada';

  @override
  String get shortcutChooseDevice => 'Elige un dispositivo';

  @override
  String get shortcutChooseScene => 'Elige una escena';

  @override
  String get shortcutOpenAppFirstScene =>
      'Abre ZigDash y crea primero una escena.';

  @override
  String get shortcutChooseGroup => 'Elige un grupo';

  @override
  String get shortcutPickDevices => 'Elegir dispositivos…';

  @override
  String get shortcutGroupName => 'Nombre del grupo';

  @override
  String get shortcutGroupLimit => 'Hasta 5 dispositivos y 3 escenas';

  @override
  String get shortcutAddTile => 'Añadir a Ajustes rápidos';

  @override
  String get shortcutAddShortcut => 'Añadir acceso directo';

  @override
  String get shortcutAddToHome => 'Añadir a la pantalla de inicio';

  @override
  String get shortcutWidgetHowToTitle => 'Añadir el widget';

  @override
  String get shortcutWidgetHowTo =>
      'Mantén pulsado un espacio libre de la pantalla de inicio, toca Widgets, busca ZigDash y arrastra el widget que quieras.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name está en el mosaico ZigDash $slot de Ajustes rápidos';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name ya está en el mosaico ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Añadir el mosaico';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Abre Ajustes rápidos (desliza hacia abajo dos veces), toca el lápiz para editar y arrastra «ZigDash $slot» a tus mosaicos.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Elige un dispositivo para ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Aún no hay dispositivos que encender. Pon primero una luz, un enchufe o una persiana en un panel.';

  @override
  String get shortcutSlotsFull =>
      'Los 4 mosaicos de ZigDash están en uso. ¿Cuál debería mostrar este dispositivo en su lugar?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Sin usar';

  @override
  String get deviceRename => 'Cambiar nombre';

  @override
  String get deviceRenameTitle => 'Cambiar nombre del dispositivo';

  @override
  String get deviceRenameHint =>
      'Un nombre para la habitación o el dispositivo, como Dormitorio';

  @override
  String deviceRenamed(Object name) {
    return 'Nombre cambiado a $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'No se pudo cambiar el nombre: $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT no respondió';

  @override
  String get shortcutOpenAppFirst =>
      'Abre ZigDash y pon primero un dispositivo en un panel.';

  @override
  String get pollTitle => '¿Qué debería hacer ZigDash ahora?';

  @override
  String get pollBody =>
      'Elige lo que más usarías. Tu respuesta se envía con tus datos de uso anónimos.';

  @override
  String get pollNotifications => 'Notificaciones';

  @override
  String get pollHistory => 'Gráficos de historial';

  @override
  String get pollKiosk => 'Modo quiosco para una tablet de pared';

  @override
  String get pollGroups => 'Grupos Zigbee';

  @override
  String get pollNotNow => 'Ahora no';

  @override
  String get pollThanks => '¡Gracias! Eso ayuda a decidir lo siguiente.';

  @override
  String get whyTitle => '¿Por qué probaste ZigDash?';

  @override
  String get whyBody =>
      'Un toque ayuda a decidir qué construir. Tu respuesta se envía con tus datos de uso anónimos.';

  @override
  String get whyFaster => 'Más rápido que mi otra app';

  @override
  String get whyFamily => 'Fácil para la familia';

  @override
  String get whyWallTablet => 'Una tableta en la pared';

  @override
  String get whyWithoutHa => 'Funciona sin Home Assistant';

  @override
  String get whyOther => 'Otra cosa';

  @override
  String get whyThanks => '¡Gracias por contárnoslo!';

  @override
  String get pollNoAnalytics =>
      'Los datos de uso están desactivados, así que no se envía nada desde aquí. Cuéntanoslo con Proponer una función.';

  @override
  String alertLeak(Object name) {
    return '💧 Fuga — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name vuelve a estar seco';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Humo — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Ya no hay humo en $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name abierto';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Batería baja — $name, $value %';
  }

  @override
  String get alertTest => 'Notificación de prueba de ZigDash';

  @override
  String get alertsChannel => 'Alertas';

  @override
  String get alertsChannelDescription => 'Fugas y humo';

  @override
  String get noticesChannel => 'Avisos';

  @override
  String get noticesChannelDescription => 'Puertas, ventanas y baterías';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsStatusOn => 'Las alertas están activas';

  @override
  String get alertsStatusPaused =>
      'Alertas en pausa: ZigDash Engine en tu hub no da señales';

  @override
  String get alertsStatusNotSetUp => 'Sin configurar';

  @override
  String get alertsStatusPhoneOff => 'Este móvil no recibe notificaciones';

  @override
  String get alertsIntro =>
      'Recibe un aviso en este teléfono cuando haya una fuga, humo, una puerta abierta o batería baja, incluso con ZigDash cerrado. ZigDash Engine en tu hub vigila los dispositivos; ZigDash lo configura.';

  @override
  String get alertsSetUpHub => 'Configurar alertas en el hub';

  @override
  String get alertsHubInstalled => 'Las alertas están configuradas en tu hub';

  @override
  String get alertsHubUpdated => 'El flujo de alertas del hub está actualizado';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED pide iniciar sesión, así que importa el flujo a mano:';

  @override
  String get alertsHubManualSteps =>
      'Abre Node-RED en el hub, elige Importar, pega el flujo copiado, elige tu broker en el nodo del broker y pulsa Deploy.';

  @override
  String get alertsCopyFlow => 'Copiar el flujo';

  @override
  String get alertsFlowCopied => 'Flujo copiado';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Las alertas necesitan Node-RED en el hub, y nada responde en el puerto 1880 de $host. En un SMLIGHT SMHUB, instálalo en Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT no aceptó ZigDash Engine';

  @override
  String get alertsRecent => 'Alertas recientes';

  @override
  String get alertsRecentNone => 'Nada todavía';

  @override
  String get alertsYourAlerts => 'Tus alertas';

  @override
  String get alertsAdd => 'Añadir alerta';

  @override
  String get alertsNotificationsOnThisPhone => 'Notificaciones en este móvil';

  @override
  String get alertsNoGoogle =>
      'Este móvil no tiene servicios de Google, así que ZigDash no puede recibir pushes aquí.';

  @override
  String get alertsSendTest => 'Enviar notificación de prueba';

  @override
  String get alertsTestSent => 'Prueba enviada. Debería llegar ahora.';

  @override
  String alertsTestFailed(Object status) {
    return 'El hub no pudo enviarla ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'El hub no responde. ¿Está en marcha el flujo de alertas?';

  @override
  String get alertsNotConnected => 'Sin conexión con el hub';

  @override
  String get alertsTurnOff => 'Desactivar las alertas';

  @override
  String get alertsTurnOffBody =>
      'Las alertas se detienen en todos los móviles de esta casa.';

  @override
  String get alertKindLeak => 'Fuga';

  @override
  String get alertKindSmoke => 'Humo';

  @override
  String get alertKindOpened => 'Puerta o ventana abierta';

  @override
  String get alertKindBattery => 'Batería baja';

  @override
  String get alertsEditTitle => 'Alerta';

  @override
  String get alertsKind => 'Qué';

  @override
  String get alertsDevices => 'Dispositivos';

  @override
  String get alertsNoDevicesForKind =>
      'Ningún dispositivo de esta casa informa de eso.';

  @override
  String get alertsHours => 'Solo entre';

  @override
  String get alertsHoursAny => 'A cualquier hora';

  @override
  String get alertsHoursFrom => 'Desde';

  @override
  String get alertsHoursTo => 'Hasta';

  @override
  String get alertsThreshold => 'Batería por debajo de';

  @override
  String get alertsDelete => 'Eliminar alerta';

  @override
  String get alertsNotifyMe => 'Avisarme…';

  @override
  String get alertsWhatLeaves =>
      'Las alertas a ZigDash van cifradas de extremo a extremo: el servicio push de Google las transporta pero no puede leerlas. Nada más sale de tu hub.';

  @override
  String get alertsRestricted =>
      'Android puede detener ZigDash en segundo plano, y las notificaciones llegarían tarde o se perderían. Permite que se ejecute en segundo plano en los ajustes de Android (en Samsung: Batería › Apps que nunca se suspenden).';

  @override
  String get alertsOpenSettings => 'Abrir ajustes de Android';

  @override
  String get alertsOff => 'Desactivada';

  @override
  String get alertsSuggested => 'Alertas sugeridas';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Activar';

  @override
  String get alertsShare => 'Compartir alertas';

  @override
  String get alertsShareBody =>
      'Cualquiera con este enlace recibe las alertas de esta casa en la app ntfy, sin necesidad de ZigDash. El texto de la alerta pasa por ntfy.sh sin cifrar.';

  @override
  String get alertsShareLink => 'Enlace';

  @override
  String get alertsShareNewLink => 'Nuevo enlace';

  @override
  String get alertsShareCopied => 'Enlace copiado';

  @override
  String get alertsShareOff => 'Dejar de compartir';

  @override
  String get alertsGetWithNtfy => 'Recibir notificaciones con ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Las alertas de humo y fuga se repiten hasta que las confirmes. Requiere una cuenta de Pushover (4,99 \$ una vez tras la prueba); sus claves se guardan en tu broker.';

  @override
  String get alertsPushoverUser => 'Clave de usuario';

  @override
  String get alertsPushoverToken => 'Token de la app';

  @override
  String get alertsHideNames => 'Ocultar nombres de dispositivos';

  @override
  String get alertsNtfyServer => 'Servidor ntfy';

  @override
  String get wallSheetTitle => 'Pantalla de pared';

  @override
  String get wallSheetSubtitle => 'Para una tablet en la pared.';

  @override
  String get wallKeepOn =>
      'Mantener la pantalla encendida y ocultar las barras';

  @override
  String get wallKeepOnSubtitle =>
      'Vuelven al tocar y se ocultan de nuevo tras 10 segundos.';

  @override
  String get wallFullscreen => 'Pantalla completa';

  @override
  String get wallFullscreenSubtitle =>
      'Oculta también las barras de estado y navegación de Android.';

  @override
  String get wallDimAfter => 'Atenuar tras';

  @override
  String get wallDimOff => 'No';

  @override
  String get wallIdleTitle => 'Cuando nadie lo toca';

  @override
  String get wallIdleAfter => 'Después de';

  @override
  String get wallIdleNever => 'Nunca';

  @override
  String get wallIdleShow => 'Mostrar';

  @override
  String get wallIdleShowDim => 'Atenuado';

  @override
  String get wallIdleShowClock => 'Reloj';

  @override
  String get wallIdleShowBlack => 'Negro';

  @override
  String get wallIdleShowReadings => 'Lecturas';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Este panel aún no tiene lecturas. Añade primero una lectura o un mosaico de sensor.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Lecturas en el reloj (hasta $count)';
  }

  @override
  String get wallProNote =>
      'Las lecturas en el reloj, despertar con movimiento, el horario nocturno y las alarmas forman parte de ZigDash Pro, una compra única.';

  @override
  String get wallAlarmLeak => 'Fuga de agua';

  @override
  String get wallAlarmSmoke => 'Humo';

  @override
  String get wallAlarmGas => 'Gas';

  @override
  String get wallAlarmCo => 'Monóxido de carbono';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Despertar con movimiento';

  @override
  String get wallMotionSubtitle =>
      'Un sensor que detecta a alguien despierta la pantalla.';

  @override
  String get wallMotionNone =>
      'No hay sensores de movimiento, presencia ni puertas en este hogar.';

  @override
  String get wallAlarmsTitle => 'Las alarmas ocupan la pantalla';

  @override
  String get wallAlarmsSubtitle =>
      'Una fuga, humo, gas o monóxido de carbono llena la pantalla hasta que alguien toca OK. Solo mientras ZigDash está abierto en esta tableta; los avisos llegan a los teléfonos en cualquier lugar.';

  @override
  String get wallAlarmSound => 'Reproducir un sonido';

  @override
  String get wallNightTitle => 'Noche';

  @override
  String get wallNightSubtitle =>
      'Negro entre estas horas. El movimiento solo la enciende tenue; las alarmas, siempre del todo.';

  @override
  String get wallNightFrom => 'De';

  @override
  String get wallNightTo => 'a';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Bloqueo de quiosco';

  @override
  String get kioskLockSubtitle =>
      'Solo quedan accesibles los paneles de esta casa y sus controles. Mantén pulsado el título para salir.';

  @override
  String get kioskPin => 'PIN';

  @override
  String get kioskPinSet => 'Definir';

  @override
  String get kioskPinNotSet => 'Sin definir';

  @override
  String get kioskPinChange => 'Cambiar';

  @override
  String get kioskPinRemove => 'Quitar';

  @override
  String get kioskPinSetTitle => 'Definir un PIN';

  @override
  String get kioskPinEnterTitle => 'Introduce el PIN';

  @override
  String get kioskPinHint => '4 dígitos';

  @override
  String get kioskPinConfirmHint => 'Otra vez';

  @override
  String get kioskPinMismatch => 'Los dos PIN no coinciden.';

  @override
  String get kioskPinWrong => 'PIN incorrecto.';

  @override
  String get kioskPinForgot => '¿Olvidaste el PIN?';

  @override
  String get kioskPinForgotBody =>
      'Un PIN olvidado solo se puede restablecer borrando los datos de ZigDash en los ajustes de Android, lo que elimina esta casa salvo que tengas una copia de seguridad. Exporta una antes de definir un PIN.';

  @override
  String get kioskExportBackup => 'Exportar copia';

  @override
  String get kioskOsPin => 'Fijar también ZigDash en Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android bloquea Inicio y las apps recientes hasta que ZigDash se desfija. Una tablet sin pantalla de bloqueo se desfija con un gesto, así que esto no es el bloqueo.';

  @override
  String get kioskOn =>
      'Quiosco activado. Mantén pulsado el título para salir.';

  @override
  String get kioskLeaveTitle => '¿Salir del quiosco?';

  @override
  String get kioskLeave => 'Salir';

  @override
  String get kioskStay => 'Quedarse';

  @override
  String get a11yKioskLeave => 'Mantén pulsado para salir del quiosco';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyRangeDay => '24 horas';

  @override
  String get historyRangeWeek => '7 días';

  @override
  String get historyRangeMonth => '30 días';

  @override
  String get historySetupTitle => 'Guarda el historial en tu hub';

  @override
  String get historySetupBody =>
      'ZigDash no tiene servidor, así que ZigDash Engine en tu hub registra los números de tus paneles cada 15 minutos. Guarda 30 días, en tu propio broker.';

  @override
  String get historySetupAction => 'Configurar en el hub';

  @override
  String get historyInstalled =>
      'Grabando. Los primeros valores aparecen en menos de 15 minutos.';

  @override
  String historyNoNodeRed(String host) {
    return 'El historial necesita Node-RED en el hub, y nada responde en el puerto 1880 de $host. En un SMLIGHT SMHUB, instálalo en Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Grabando desde $date';
  }

  @override
  String get historyEmpty =>
      'Aún no hay valores. El grabador guarda cada 15 minutos.';

  @override
  String get historyRecorderOffline =>
      'El grabador del hub no responde, así que pueden faltar valores recientes.';

  @override
  String get historyLocked =>
      'El historial más largo forma parte de ZigDash Pro, una compra única.';

  @override
  String get historyUnlock => 'Desbloquear';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Automatizaciones ilimitadas, más historial y extras para la tablet de pared. Apoya el proyecto de código abierto.';

  @override
  String get proUnlocked => 'Desbloqueado. Gracias por apoyar ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash es gratis y de código abierto, hecho por una sola persona en su tiempo libre. Pro es una compra única que lo mantiene en marcha.';

  @override
  String get proWhatYouGet => 'Lo que obtienes';

  @override
  String get proGetHistory => 'Historial de 7 y 30 días, no solo de hoy';

  @override
  String get proGetWall =>
      'Tablet de pared: lecturas en el reloj, activación por movimiento, horario nocturno y alarmas';

  @override
  String get proGetFuture =>
      'Todas las funciones Pro que lleguen después, sin coste extra';

  @override
  String get proFreeTitle => 'Gratis para siempre';

  @override
  String get proFreeBody =>
      'La configuración, los paneles, el control de cada dispositivo, los widgets, los iconos de ajustes rápidos, las alertas, tres automatizaciones por hogar y la tablet de pared siguen siendo gratis. Nada de lo que usas hoy se bloquea.';

  @override
  String get proBuy => 'Obtener Pro';

  @override
  String proBuyPrice(String price) {
    return 'Obtener Pro · $price';
  }

  @override
  String get proOnce =>
      'Un solo pago, sin suscripción. ¿Lo compraste en otro teléfono con la misma cuenta de Google? Se desbloquea solo.';

  @override
  String get historyNotRecorded =>
      'Solo se graban los números que aparecen en un panel. Añade este como mosaico para empezar su historial.';

  @override
  String get historyRecordHere => 'Grabar en este dispositivo';

  @override
  String get historyRecordHereHint =>
      '¿No puedes usar ZigDash Engine en tu hub? ZigDash puede registrar en un teléfono o tablet que se quede abierto, como una tablet de pared. Todos los teléfonos de este hogar ven el historial.';

  @override
  String get historyRecordingHere =>
      'Este dispositivo graba el historial mientras ZigDash está abierto. Los primeros valores aparecen en 15 minutos.';

  @override
  String get wallRecordHistory => 'Grabar el historial en este dispositivo';

  @override
  String get wallRecordHistorySubtitle =>
      'Cada 15 minutos mientras ZigDash está abierto, para todos los teléfonos de este hogar. No hace falta si registra ZigDash Engine en tu hub.';

  @override
  String historyNeedsPassword(String host) {
    return 'Un paso más: tu bróker pide inicio de sesión. Abre Node-RED en $host:1880, haz doble clic en \"ZigDash history broker\", escribe la contraseña MQTT en la pestaña Security y pulsa Deploy. ZigDash nunca envía tu contraseña al hub.';
  }

  @override
  String get historyNotConnected =>
      'El registro no da señales. Abre Automatizaciones para revisar ZigDash Engine en tu hub.';

  @override
  String get historyPersistence =>
      'El historial vive en tu bróker. Si gestionas Mosquitto tú mismo, asegúrate de que su configuración tenga \"persistence true\", o el historial se perderá al reiniciar el bróker.';

  @override
  String get haImportTitle => 'Importar desde Home Assistant';

  @override
  String get haImportSettingsSubtitle =>
      'Nombres y estancias de Home Assistant';

  @override
  String get haImportIntro =>
      'Trae los nombres y estancias que configuraste en Home Assistant. ZigDash los lee una vez y no guarda nada más de Home Assistant.';

  @override
  String get haImportAddress => 'Dirección de Home Assistant';

  @override
  String get haImportAddressHelp =>
      'La dirección con la que abres Home Assistant, como 192.168.1.20:8123';

  @override
  String get haImportToken => 'Token de acceso de larga duración';

  @override
  String get haImportTokenHelp =>
      'En Home Assistant, abre tu perfil y ve a Seguridad › Tokens de acceso de larga duración › Crear token. Cópialo y pégalo aquí. ZigDash lo usa una vez y no lo guarda; después puedes borrarlo en Home Assistant.';

  @override
  String get haImportRead => 'Leer de Home Assistant';

  @override
  String get haImportReading => 'Leyendo Home Assistant…';

  @override
  String get haImportApplying => 'Importando…';

  @override
  String get haImportNoAddress =>
      'Escribe la dirección con la que abres Home Assistant.';

  @override
  String get haImportNoToken => 'Pega un token de acceso de larga duración.';

  @override
  String get haImportUnreachable =>
      'Nada respondió en esa dirección. Revísala y comprueba que el móvil esté en la red de casa.';

  @override
  String get haImportNotHa =>
      'Algo respondió en esa dirección, pero no es Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant rechazó ese token. Crea uno nuevo y pégalo otra vez.';

  @override
  String get haImportCertificate =>
      'Tu móvil no confía en el certificado de este Home Assistant. Prueba su dirección http:// en la red de casa.';

  @override
  String get haImportFailed =>
      'Home Assistant respondió, pero la lectura falló. Inténtalo de nuevo.';

  @override
  String get haImportNoDevices =>
      'ZigDash no ve ahora los dispositivos de esta casa. Conéctate a ella y vuelve a intentarlo.';

  @override
  String get haImportAutomations =>
      'Tus automatizaciones siguen en Home Assistant y funcionando.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos encontrados en Home Assistant',
      one: '1 dispositivo encontrado en Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Los mosaicos que aún llevan el nombre de su dispositivo toman el nombre de Home Assistant. Los paneles que creaste quedan igual.';

  @override
  String get haImportMakeDashboards =>
      'Añadir también paneles de tus plantas y estancias';

  @override
  String get haImportOtherRooms => 'Otras estancias';

  @override
  String get haImportNoRoom => 'Sin estancia';

  @override
  String get haImportApply => 'Importar';

  @override
  String get haImportBack => 'Atrás';

  @override
  String get haImportZhaOnly =>
      'Estos dispositivos usan ZHA, el Zigbee propio de Home Assistant, no Zigbee2MQTT, así que ZigDash no puede mostrarlos.';

  @override
  String get haImportNothing =>
      'Ninguno de los dispositivos Zigbee2MQTT de esta casa está en Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Hecho. Mosaicos renombrados: $renamed. Paneles añadidos: $dashboards.';
  }

  @override
  String get haImportOpen => 'Abrir paneles';

  @override
  String get haImportOfferTitle =>
      '¿Traer tus nombres y estancias de Home Assistant?';

  @override
  String get haImportOfferBody =>
      'Home Assistant está en tu red. ZigDash puede nombrar tus mosaicos y añadir un panel por planta y estancia, tal como los configuraste allí.';

  @override
  String get haImportOfferLater => 'Ahora no';

  @override
  String get haImportOfferGo => 'Importar';

  @override
  String get haImportSignIn => 'Iniciar sesión con Home Assistant';

  @override
  String get haImportSignInHelp =>
      'El inicio de sesión de Home Assistant se abre en tu navegador. ZigDash nunca ve tu contraseña y cierra la sesión después de leer.';

  @override
  String get haImportOrToken => 'O usa un token de acceso de larga duración';

  @override
  String get haImportReadToken => 'Leer con token';

  @override
  String get haImportSignInRefused =>
      'Home Assistant no aceptó el inicio de sesión. Pasa cuando Home Assistant no tiene acceso a internet. Usa un token de acceso de larga duración aquí debajo.';

  @override
  String get setupIsolatedHint =>
      'Tu móvil apenas ve nada más en esta Wi-Fi. Puede estar en una red de invitados, o el router mantiene los dispositivos separados (suele llamarse aislamiento de clientes o de AP). Conéctate a tu Wi-Fi principal o desactiva eso, y vuelve a intentarlo.';

  @override
  String get setupAuthTrust =>
      'Tu acceso se queda en este móvil y solo va a tu propio broker. ZigDash no tiene servidor ni cuenta, y toda app MQTT inicia sesión así. Lo más seguro: un usuario MQTT aparte solo para ZigDash, que puedes quitar cuando quieras.';

  @override
  String get setupAuthWhatKept => 'Qué guarda ZigDash';

  @override
  String get setupAuthDemoFirst => 'Probar primero la demo';

  @override
  String get automationsTitle => 'Automatizaciones';

  @override
  String get engineRunningOnHub => 'En el hub';

  @override
  String get engineChecking => 'Comprobando el hub…';

  @override
  String get engineAwayNoHubTitle => 'Ahora no se puede llegar a tu hub';

  @override
  String get engineAwayNoHubBody =>
      'Estás fuera y tu hub no está conectado al acceso remoto de ZigDash, o no tiene internet. Tus automatizaciones siguen funcionando en el hub.';

  @override
  String get engineAwayReinstallAtHome =>
      'Puedes reinstalar el Engine cuando estés en casa.';

  @override
  String get engineNoConnection =>
      'ZigDash no llega ahora al broker de este hogar. Las automatizaciones se configuran con conexión en casa.';

  @override
  String get engineRestarting =>
      'Reiniciando Zigbee2MQTT… Los dispositivos vuelven en unos 30 segundos.';

  @override
  String get engineInstalling => 'Instalando en el hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT necesita una actualización';

  @override
  String engineTooOldBody(Object version) {
    return 'Tu Zigbee2MQTT es la versión $version. Las automatizaciones necesitan la 2.4 o posterior. Actualiza Zigbee2MQTT en el hub y vuelve aquí.';
  }

  @override
  String get engineIntroTitle =>
      'Las automatizaciones se ejecutan en el hub, no en el teléfono';

  @override
  String get engineIntroBody =>
      'ZigDash coloca ZigDash Engine dentro de Zigbee2MQTT en tu hub. Vigila tus dispositivos y ejecuta tus reglas, así una luz se enciende al abrir la puerta aunque el teléfono esté apagado y no haya internet.';

  @override
  String get engineIntroNothingByHand =>
      'No hay que instalar nada a mano. ZigDash lo hace por la red de casa.';

  @override
  String engineIntroVersion(Object version) {
    return 'Tu Zigbee2MQTT es la versión $version.';
  }

  @override
  String get engineIntroRemove =>
      'Puedes quitarlo cuando quieras desde esta pantalla.';

  @override
  String get engineInstall => 'Instalar en el hub';

  @override
  String get engineDeclinedTitle => 'Sin automatizaciones en este hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT en tu hub no permite complementos, así que nada puede ejecutar tus reglas cuando el teléfono no está. Escenas, alertas y el panel funcionan como antes.';

  @override
  String get engineAllowAfterAll => 'Permitir complementos';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT necesita cambiar un ajuste';

  @override
  String get engineConsentBody =>
      'Tu Zigbee2MQTT bloquea complementos como ZigDash Engine, como hacen las instalaciones nuevas. Para ejecutar automatizaciones en el hub, ZigDash activaría «Permitir JavaScript externo» en Zigbee2MQTT y lo reiniciaría.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT se reinicia una vez. Luces y sensores no responden durante unos 30 segundos.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine es de código abierto. Puedes leerlo en la página de Zigbee2MQTT, en Extensiones.';

  @override
  String get engineConsentUndo =>
      'Puedes desactivar el ajuste más tarde. Entonces se detienen las automatizaciones.';

  @override
  String get engineConsentYes => 'Cambiar el ajuste y reiniciar';

  @override
  String get engineConsentNo => 'Ahora no';

  @override
  String get automationsPausedTitle => 'Automatizaciones en pausa';

  @override
  String get automationsPausedBody =>
      'Tu hub no da señales desde hace más de un minuto, así que ninguna automatización puede ejecutarse hasta que vuelva. Tus reglas se conservan.';

  @override
  String get engineReinstall => 'Reinstalar en el hub';

  @override
  String get engineStoppedTitle =>
      'Automatizaciones en pausa: ZigDash Engine se detuvo solo';

  @override
  String get engineStoppedBody =>
      'Tuvo errores tres veces en una hora y se apagó para que Zigbee2MQTT siga funcionando. Tus reglas se conservan.';

  @override
  String get engineStartAgain => 'Iniciar de nuevo';

  @override
  String get engineReportProblem => 'Informar de un problema';

  @override
  String get engineRunningTitle => 'Tu hub está listo para automatizaciones';

  @override
  String engineRunningBody(Object count) {
    return 'Reglas cargadas en el hub: $count. Crear automatizaciones llega en el siguiente paso de esta versión.';
  }

  @override
  String get engineClockOff =>
      'El reloj de tu hub va desfasado más de cinco minutos. Las automatizaciones por hora se ejecutarán a destiempo hasta que se corrija.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Reglas que ZigDash Engine en tu hub aún no puede ejecutar: $count. Reinstálalo para actualizarlo.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT rechazó ZigDash Engine: $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT no respondió. Comprueba que el hogar está conectado e inténtalo de nuevo.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT no aceptó el cambio o no volvió. Revisa el hub e inténtalo de nuevo.';

  @override
  String get autoValMotion => 'movimiento';

  @override
  String get autoValNoMotion => 'sin movimiento';

  @override
  String get autoValClosed => 'cerrado';

  @override
  String get autoValOpened => 'abierto';

  @override
  String get autoValLeak => 'fuga';

  @override
  String get autoValDry => 'seco';

  @override
  String get autoValSmoke => 'humo';

  @override
  String get autoValNoSmoke => 'sin humo';

  @override
  String get autoValOn => 'encendido';

  @override
  String get autoValOff => 'apagado';

  @override
  String get autoValToggle => 'alternar';

  @override
  String get autoValOpen => 'abrir';

  @override
  String get autoValClose => 'cerrar';

  @override
  String get autoValStop => 'parar';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Cuando $device: $property por encima de $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Cuando $device: $property por debajo de $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Cuando $device: $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'A las $time';
  }

  @override
  String get autoSunrise => 'amanecer';

  @override
  String get autoSunset => 'atardecer';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min después del $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min antes del $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Al $sun';
  }

  @override
  String get autoEveryDay => 'todos los días';

  @override
  String get autoWeekdays => 'entre semana';

  @override
  String get autoWeekends => 'fines de semana';

  @override
  String autoBetween(Object from, Object to) {
    return 'entre $from y $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device está $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Ejecutar «$scene»';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device: $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, se apaga a los $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Elige un dispositivo y lo que hace.';

  @override
  String get autoErrValue => 'Escribe un número para la lectura.';

  @override
  String get autoErrDays => 'Elige al menos un día.';

  @override
  String get autoErrTown => 'Indica tu ciudad para el amanecer y el atardecer.';

  @override
  String get autoErrPickAction => 'Elige qué debe pasar.';

  @override
  String get autoErrEmptyScene => 'Esa escena no tiene nada que enviar.';

  @override
  String get autoErrNotConnected =>
      'ZigDash no está conectado a este hogar. Inténtalo en casa.';

  @override
  String get autoNewTitle => 'Nueva automatización';

  @override
  String get autoEditTitle => 'Editar automatización';

  @override
  String get autoName => 'Nombre';

  @override
  String get autoNameHint => 'Qué hace (opcional)';

  @override
  String get autoWhen => 'Cuando';

  @override
  String get autoOnlyIf => 'Solo si';

  @override
  String get autoThen => 'Entonces';

  @override
  String get autoEnabled => 'Activada';

  @override
  String get autoDelete => 'Eliminar automatización';

  @override
  String get autoSave => 'Guardar';

  @override
  String get autoDeviceChanges => 'Un dispositivo cambia';

  @override
  String get autoTimeComes => 'Llega una hora';

  @override
  String get autoDevice => 'Dispositivo';

  @override
  String get autoAbove => 'por encima de';

  @override
  String get autoBelow => 'por debajo de';

  @override
  String get autoClockTime => 'Hora';

  @override
  String get autoAt => 'A las';

  @override
  String get autoShift => 'Desfase en minutos (negativo es antes)';

  @override
  String get autoTownNone => 'Sin ciudad';

  @override
  String autoTownIs(Object town) {
    return 'Horas del sol para $town';
  }

  @override
  String get autoTownSet => 'Indicar ciudad';

  @override
  String get autoTownChange => 'Cambiar ciudad';

  @override
  String get autoDays => 'Días';

  @override
  String get autoNoConditions => 'Sin condiciones. Se ejecuta siempre.';

  @override
  String get autoAddHours => 'Entre horas';

  @override
  String get autoFrom => 'Desde';

  @override
  String get autoTo => 'Hasta';

  @override
  String get autoAddDeviceCondition => 'Un dispositivo está…';

  @override
  String get autoRunASceneOption => 'Ejecutar una escena';

  @override
  String get autoSetADevice => 'Ajustar un dispositivo';

  @override
  String get autoScene => 'Escena';

  @override
  String get autoTurnOffAgain => 'Volver a apagar';

  @override
  String get autoStaysAsSet => 'Se queda así';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minutos después';
  }

  @override
  String get autoTownSearch => 'Ciudad';

  @override
  String get autoTownWhy =>
      'Solo para el amanecer y el atardecer. Se guarda en tu hub, nunca tu ubicación.';

  @override
  String get autoNewButton => 'Nueva automatización';

  @override
  String get autoEmptyBody =>
      'Aún no se ejecuta nada. Toca Nueva automatización para crear la primera.';

  @override
  String autoOnlyIfList(Object list) {
    return 'solo si $list';
  }

  @override
  String get autoEdit => 'Editar';

  @override
  String get autoNeverRan => 'nunca se ejecutó';

  @override
  String autoRanAt(Object time) {
    return 'se ejecutó $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count de $max automatizaciones gratis';
  }

  @override
  String get autoRecentRuns => 'Últimas ejecuciones';

  @override
  String get autoDeleted => '(eliminada)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automatizaciones son gratis. ¿Quieres más?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash es gratis y de código abierto, hecho por una persona. Pro es un pago único: automatizaciones ilimitadas, historial de 7 y 30 días y los extras para tablet de pared. Tus automatizaciones siguen funcionando elijas lo que elijas.';

  @override
  String get autoCeilingSeePro => 'Ver Pro';

  @override
  String get engineRemove => 'Quitar del hub';

  @override
  String get engineRemoveTitle => '¿Quitar ZigDash Engine del hub?';

  @override
  String get engineRemoveBody =>
      'Las automatizaciones dejan de ejecutarse. Tus reglas se quedan en el hub, así que al reinstalar ZigDash Engine vuelven.';

  @override
  String get autoNoTargets =>
      'Este hogar aún no tiene luces, enchufes, interruptores ni persianas que controlar.';

  @override
  String get proGetAutomations =>
      'Automatizaciones ilimitadas; tres por hogar son gratis';

  @override
  String get proGetRemote =>
      'Control remoto desde cualquier lugar, a través del relay de ZigDash, sin cuota mensual';

  @override
  String get proRemoteFair =>
      'El acceso remoto está incluido mientras el relay de ZigDash funcione, para un hogar, hasta cinco teléfonos y un uso doméstico normal. Puede cambiar o terminar con aviso previo.';

  @override
  String get autoDeleteConfirm =>
      '¿Eliminar esta automatización? Deja de ejecutarse en tu hub.';

  @override
  String get statusConnectedRelay => 'Conectado · Fuera, vía ZigDash';

  @override
  String get shareHomeTitle => 'Compartir con otro teléfono';

  @override
  String get shareHomeSubtitle =>
      'Añade esta casa a otro teléfono con un código QR';

  @override
  String get shareHomeIntro =>
      'En el otro teléfono, en casa y en la misma Wi-Fi, escanea el código con la cámara. ZigDash añade esta casa con su acceso y tus paneles.';

  @override
  String get shareHomeLoginWarning =>
      'El código incluye el acceso al broker de esta casa. Se muestra 2 minutos; enséñalo solo a gente de confianza.';

  @override
  String get shareHomeShow => 'Mostrar el código';

  @override
  String get shareHomeAtHome =>
      'Conéctate primero en casa: compartir solo funciona en tu red doméstica.';

  @override
  String get shareHomeScanHint =>
      'Escanéalo con la cámara del otro teléfono. El código se oculta en 2 minutos.';

  @override
  String get shareHomeHide => 'Ocultar el código';

  @override
  String get shareHomeViaHa =>
      'Esta casa se conecta a través de Home Assistant. En el otro teléfono, instala ZigDash e inicia sesión con Home Assistant.';

  @override
  String get joinHomeTitle => 'Añadir una casa compartida';

  @override
  String get joinHomeInvalid =>
      'Este código no es una invitación de ZigDash o está dañado.';

  @override
  String joinHomeAlready(String name) {
    return '$name ya está en este teléfono.';
  }

  @override
  String get joinHomeOpen => 'Abrir';

  @override
  String joinHomeAsk(String name) {
    return '¿Añadir $name a este teléfono?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash añade la casa con la misma conexión y acceso, y toma los paneles del otro teléfono. Mantén este teléfono en la Wi-Fi de casa.';

  @override
  String get joinHomeAdd => 'Añadir casa';

  @override
  String get joinHomeNoDashboards =>
      'Casa añadida. Los paneles no llegaron; tus dispositivos están en la pestaña Dispositivos.';

  @override
  String get remoteTitle => 'Control remoto';

  @override
  String get remoteSettingsSubtitle =>
      'Controla este hogar desde cualquier lugar, con Pro';

  @override
  String get remoteIntroTitle => 'Controla tu hogar desde cualquier lugar';

  @override
  String get remoteOfferBody =>
      'Accede a tus dispositivos cuando estés fuera, a través del relay cifrado de ZigDash. Parte de Pro: un solo pago, sin cuota mensual. Configúralo mientras estás en casa.';

  @override
  String get remoteOfferBodyPro =>
      'Tienes Pro: activa el control remoto mientras estás en casa y accede a tus dispositivos desde cualquier lugar.';

  @override
  String get remoteOfferShow => 'Ver cómo';

  @override
  String get remoteIntroBody =>
      'Tu hub mantiene una conexión con el relé de ZigDash. Fuera de casa, este teléfono llega a tus dispositivos a través de él. Todo se cifra en tu hub y tu teléfono, así que el relé no puede leer tus dispositivos ni lo que hacen.';

  @override
  String get remoteNeedsEngine =>
      'El control remoto funciona en ZigDash Engine. Instálalo antes en Automatizaciones.';

  @override
  String get remoteSetUp => 'Activar el control remoto';

  @override
  String get remoteNeedsPro => 'El control remoto es parte de Pro.';

  @override
  String get remoteNotAtHome => 'Actívalo en casa, conectado a tu broker.';

  @override
  String get remoteUnreachable =>
      'El relé de ZigDash no respondió. Inténtalo más tarde.';

  @override
  String get remoteRefused =>
      'El relé lo rechazó. Inténtalo de nuevo o informa del problema.';

  @override
  String get remoteOnTitle => 'El control remoto está activado';

  @override
  String get remoteOnBody =>
      'Fuera de casa, ZigDash se conecta por el relé solo.';

  @override
  String get remoteHubOnline => 'Tu hub está conectado al relé';

  @override
  String get remoteHubOffline => 'Tu hub no está conectado al relé';

  @override
  String get remoteTurnOff => 'Desactivar el control remoto';

  @override
  String get remoteViaRelayNow =>
      'Este teléfono está conectado por el relé ahora mismo.';

  @override
  String get remotePhones => 'Teléfonos con acceso remoto';

  @override
  String get remoteThisPhone => 'Este teléfono';

  @override
  String get remoteOtherPhone => 'Otro teléfono';

  @override
  String remotePhoneAdded(Object date) {
    return 'Añadido el $date';
  }

  @override
  String get remoteRemovePhone => 'Quitar';

  @override
  String get remoteRemovePhoneConfirm =>
      '¿Quitar este teléfono? Ya no podrá llegar a este hogar desde fuera.';

  @override
  String get remoteAddPhone => 'Añadir un teléfono';

  @override
  String get remoteAddPhoneHint =>
      'En casa, escanéalo con la cámara del otro teléfono. Abre ZigDash y activa allí el control remoto. Muéstralo solo a tus propios teléfonos.';

  @override
  String get remoteAddPhoneFailed =>
      'El relé no dio un acceso para otro teléfono. Un hogar puede tener hasta cinco.';

  @override
  String get remoteBackupSave => 'Guardar copia de la clave';

  @override
  String get remoteBackupRestore => 'Restaurar desde una copia de la clave';

  @override
  String get remoteBackupPassphrase => 'Frase de contraseña de la copia';

  @override
  String get remoteBackupPassphraseHint =>
      'Si pierdes este teléfono, la copia y esta frase devuelven el control remoto en uno nuevo. Usa al menos 8 caracteres y guarda la frase en otro sitio que el archivo.';

  @override
  String get remoteBackupPassphraseAsk =>
      'La frase que elegiste al guardar la copia.';

  @override
  String get remoteBackupPassphraseAgain => 'Repite la frase';

  @override
  String get remoteBackupSaved => 'Copia de la clave guardada';

  @override
  String get remoteBackupWrong => 'Esa frase no abre esta copia.';

  @override
  String get remoteBackupWrongFile =>
      'Eso no es una copia de clave de ZigDash.';

  @override
  String get remotePlayOnly =>
      'Por ahora el control remoto está en la versión de Google Play de ZigDash.';

  @override
  String get remotePairTitle => 'Añadir control remoto';

  @override
  String get remotePairBody =>
      '¿Qué hogar es este? ZigDash guarda el acceso remoto para él.';

  @override
  String get remotePairNoHomes =>
      'Configura primero este hogar en este teléfono, en casa. Luego escanea el código otra vez.';

  @override
  String get remotePairInvalid =>
      'Este código no es de control remoto de ZigDash, o se cortó.';

  @override
  String remotePairDone(Object home) {
    return 'Control remoto activado para $home';
  }

  @override
  String get remoteReconnectHub => 'Volver a conectar el hub';

  @override
  String get remoteTurnOffConfirm =>
      'Este teléfono deja el control remoto y tu hub se desconecta del relé. Una copia de clave guardada desde este teléfono deja de funcionar; los demás teléfonos conservan su acceso hasta que los quites.';

  @override
  String remoteHomeId(Object id) {
    return 'ID del hogar $id';
  }

  @override
  String get alertsHintTitle => 'Recibe avisos en este teléfono';

  @override
  String get alertsHintBody =>
      'Una fuga, humo, una puerta abierta o una batería baja pueden enviar una notificación a este teléfono, incluso con ZigDash cerrado.';

  @override
  String get alertsHintButton => 'Configurar alertas';

  @override
  String get alertsHintNotNow => 'Ahora no';

  @override
  String get guidedNoZ2mBody =>
      'Aquí responde un broker MQTT, pero Zigbee2MQTT no envía nada por él. Comprueba que Zigbee2MQTT está iniciado y usa este broker, y que el topic base coincide con su configuración. Si tus dispositivos Zigbee están en ZHA de Home Assistant, ZigDash no puede verlos: funciona con Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT está en este broker con el topic base «$found», pero esta casa busca «$current».';
  }

  @override
  String devicesUseBase(String found) {
    return 'Usar «$found»';
  }

  @override
  String get devicesChangeConnection => 'Cambiar conexión';

  @override
  String get updateAvailableTitle => 'Hay una nueva versión de ZigDash';

  @override
  String get updateAvailableBody =>
      'Se descarga mientras sigues usando ZigDash.';

  @override
  String get updateAvailableButton => 'Actualizar';

  @override
  String get updateDownloading => 'Descargando la actualización…';

  @override
  String get updateReadyTitle => 'Actualización descargada';

  @override
  String get updateReadyButton => 'Reiniciar para terminar';

  @override
  String get nfcWriteTag => 'Escribir en etiqueta NFC';

  @override
  String get nfcHoldTitle => 'Acerca una etiqueta al teléfono';

  @override
  String nfcHoldBody(String name) {
    return 'Acerca una pegatina NFC vacía a la parte trasera del teléfono. Al tocarla después se ejecutará $name.';
  }

  @override
  String get nfcWrittenTitle => 'Etiqueta lista';

  @override
  String nfcWrittenBody(String name) {
    return 'Toca esta etiqueta con el teléfono para ejecutar $name. Funciona con ZigDash cerrado.';
  }

  @override
  String get nfcFailedTitle => 'No se pudo escribir la etiqueta';

  @override
  String get nfcReadonlyBody =>
      'Esta etiqueta está bloqueada y no se puede cambiar. Prueba con otra.';

  @override
  String get nfcTooSmallBody =>
      'Esta etiqueta es demasiado pequeña. Usa una pegatina NTAG213 o mayor.';

  @override
  String get nfcFailedBody =>
      'Mantén la etiqueta quieta contra la parte trasera del teléfono e inténtalo de nuevo.';

  @override
  String get nfcOffTitle => 'El NFC está desactivado';

  @override
  String get nfcOffBody =>
      'Activa el NFC en los ajustes de Android y vuelve a intentarlo.';

  @override
  String get nfcNoneTitle => 'Este teléfono no tiene NFC';

  @override
  String get nfcNoneBody =>
      'Este teléfono no puede leer ni escribir etiquetas NFC.';

  @override
  String get nfcWriteAnother => 'Escribir otra etiqueta';

  @override
  String get nfcUnsupportedBody =>
      'Este teléfono no puede escribir este tipo de etiqueta (a menudo MIFARE Classic). Usa una pegatina NTAG213, 215 o 216.';

  @override
  String get nfcTagsTitle => 'Etiquetas NFC';

  @override
  String get nfcTagsSubtitle =>
      'Etiquetas que ejecutan una escena o cambian un dispositivo';

  @override
  String get nfcTagsEmpty =>
      'Aún no hay etiquetas. Mantén pulsada una tarjeta de escena, luz, enchufe o persiana y elige Escribir en etiqueta NFC.';

  @override
  String get nfcTagRunsScene => 'Ejecuta la escena';

  @override
  String get nfcTagSwitches => 'Enciende y apaga';

  @override
  String nfcTagWritten(String when) {
    return 'escrita $when';
  }

  @override
  String nfcTagLastTap(String when) {
    return 'último toque $when';
  }

  @override
  String get nfcTagNeverTapped => 'aún sin usar';

  @override
  String get nfcTagOffLabel => 'Desactivada';

  @override
  String get nfcTagRewrite => 'Reescribir';

  @override
  String get nfcTagForget => 'Quitar de la lista';

  @override
  String get nfcTagOffToast => 'Esta etiqueta está desactivada en ZigDash';

  @override
  String get nfcTagsNote =>
      'Una etiqueta desactivada no hace nada en este teléfono. Las escritas antes de esta lista no aparecen: reescríbelas una vez.';

  @override
  String get nfcPopupHeader => 'Etiqueta ZigDash';

  @override
  String get nfcPopupRunning => 'Ejecutando…';

  @override
  String get nfcPopupSwitching => 'Cambiando…';

  @override
  String get nfcPopupDone => 'Hecho';

  @override
  String get nfcPopupClosing => 'Se cierra en 2 segundos';

  @override
  String get nfcPopupUnreachable =>
      'Este teléfono no llega a la casa ahora mismo. Revisa el Wi-Fi o activa el control remoto.';

  @override
  String get nfcPopupOffBody =>
      'No se cambió nada. Vuelve a activarla en los ajustes de la casa, en Etiquetas NFC.';

  @override
  String get nfcPopupOpenApp => 'Abrir ZigDash';
}
