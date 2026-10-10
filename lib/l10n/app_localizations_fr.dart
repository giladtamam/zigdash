// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get reliabilityLastKnown => 'Dernière valeur connue';

  @override
  String get reliabilityControlsUnavailable => 'Commandes indisponibles';

  @override
  String get appTitle => 'ZigDash';

  @override
  String get onboardingDemo => 'Essayer la démo';

  @override
  String get navBrokers => 'Brokers';

  @override
  String get navDashboards => 'Tableaux de bord';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsDynamicColor => 'Utiliser les couleurs Material You';

  @override
  String get settingsDynamicColorSubtitle =>
      'Android 12+ ; sinon la couleur de l\'application est utilisée';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get connectionsTitle => 'Maisons';

  @override
  String connLoadFailed(Object error) {
    return 'Échec du chargement : $error';
  }

  @override
  String get connAddBroker => 'Ajouter un broker';

  @override
  String get connEmpty =>
      'Aucune connexion pour l\'instant.\nAppuyez sur « Ajouter un broker » pour pointer ZigDash vers votre serveur MQTT.';

  @override
  String get connNew => 'Nouvelle connexion';

  @override
  String get connEdit => 'Modifier la connexion';

  @override
  String get save => 'Enregistrer';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get fieldRequired => 'Obligatoire';

  @override
  String get connName => 'Nom';

  @override
  String get connNameHint => 'Broker maison';

  @override
  String get connHost => 'Hôte';

  @override
  String get connHostHint => '192.168.1.10';

  @override
  String get connLocalHost => 'Hôte local';

  @override
  String get connFindBrokers => 'Rechercher des brokers';

  @override
  String get connHowToFind => 'Comment le trouver ?';

  @override
  String get connRescan => 'Relancer la recherche';

  @override
  String get connBrokerNeedsLogin => 'Identifiants requis';

  @override
  String connFindBrokersScanning(Object subnet) {
    return 'Analyse de $subnet…';
  }

  @override
  String connFindBrokersFound(int count) {
    return '$count broker(s) trouvé(s) — appuyez pour utiliser';
  }

  @override
  String get connFindBrokersNone => 'Aucun broker trouvé sur votre Wi-Fi.';

  @override
  String get connFindBrokersNoIp =>
      'Impossible de lire votre adresse Wi-Fi. Vérifiez que le Wi-Fi est activé et réessayez.';

  @override
  String get connHelpTitle => 'Trouver l\'IP de votre broker';

  @override
  String get connHelpDockerTitle => 'Zigbee2MQTT dans Docker';

  @override
  String get connHelpDockerBody =>
      'L\'IP du broker est l\'adresse LAN de la machine qui exécute Docker (votre NAS, Raspberry Pi, etc.). Trouvez-la dans la liste des appareils de votre routeur, ou exécutez \'hostname -I\' / \'ip addr\' sur cette machine. Le port est généralement 1883 (Mosquitto). Utilisez l\'IP LAN de l\'hôte, pas 127.0.0.1, même si Mosquitto tourne dans son propre conteneur.';

  @override
  String get connHelpSmhubTitle => 'SMLIGHT SMHUB';

  @override
  String get connHelpSmhubBody =>
      'L\'IP du broker est l\'adresse IP du hub. Trouvez-la dans l\'interface web SMLIGHT sous Paramètres → Réseau, ou dans votre routeur. Le port est 1883, sans identifiant ni mot de passe par défaut.';

  @override
  String get connHelpZhaTitle => 'Home Assistant ZHA';

  @override
  String get connHelpZhaBody =>
      'ZHA n\'a pas de broker MQTT : il parle directement à Home Assistant, donc ZigDash ne peut pas s\'y connecter. Pour utiliser ZigDash, passez à Zigbee2MQTT (disponible comme module complémentaire Home Assistant ou conteneur Docker), qui fournit un broker MQTT.';

  @override
  String get connHelpSameNetwork =>
      'Votre téléphone et le broker doivent être sur le même réseau Wi-Fi (pas un réseau invité ni un VLAN isolé).';

  @override
  String get connRemoteHost => 'Hôte distant (Tailscale)';

  @override
  String get connRemoteHostHint =>
      'Utilisé quand l\'hôte local est injoignable. Privilégiez l\'IP Tailscale du hub, ex. 100.x.y.z';

  @override
  String get connPort => 'Port';

  @override
  String get connPortRange => '1–65535';

  @override
  String get connUsernameOptional => 'Nom d\'utilisateur (facultatif)';

  @override
  String get connPasswordOptional => 'Mot de passe (facultatif)';

  @override
  String get connPasswordKeepHint => 'Laissez vide pour conserver l\'actuel';

  @override
  String get connAutoConnect => 'Connexion automatique au démarrage';

  @override
  String get advanced => 'Avancé';

  @override
  String get connKeepAlive => 'Keep-alive (secondes)';

  @override
  String get connKeepAliveRange => '5–3600';

  @override
  String get connProtocol => 'Protocole';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get connDeleteTitle => 'Supprimer la connexion ?';

  @override
  String connDeleteContent(Object name) {
    return 'Supprime « $name », ses tableaux de bord/panneaux et son mot de passe enregistré.';
  }

  @override
  String get statusDisconnected => 'Déconnecté';

  @override
  String get statusConnecting => 'Connexion';

  @override
  String get statusConnected => 'Connecté';

  @override
  String get statusReconnecting => 'Reconnexion';

  @override
  String get statusError => 'Erreur';

  @override
  String get statusConnectedRemote => 'Connecté · Distant';

  @override
  String get dashPlaceholder =>
      'Ouvrez un broker depuis l\'onglet Brokers pour voir et gérer ses tableaux de bord.';

  @override
  String get dashAddDashboard => 'Ajouter un tableau de bord';

  @override
  String get dashEditDashboard => 'Modifier le tableau de bord';

  @override
  String get dashAddPanel => 'Ajouter un panneau';

  @override
  String get dashEmpty =>
      'Aucun tableau de bord pour l\'instant.\nAppuyez sur « Ajouter un tableau de bord » pour en créer un pour ce broker.';

  @override
  String dashLoadFailed(Object error) {
    return 'Échec : $error';
  }

  @override
  String get panelPickerTitle => 'Ajouter un panneau';

  @override
  String get panelPickerSectionControl => 'Commande';

  @override
  String get panelPickerSectionState => 'État';

  @override
  String get panelPickerToggleTitle => 'Interrupteur';

  @override
  String get panelPickerToggleSubtitle =>
      'Marche/arrêt pour l\'état d\'un appareil';

  @override
  String get panelPickerSliderBrightnessTitle => 'Curseur — Luminosité';

  @override
  String get panelPickerSliderBrightnessSubtitle =>
      'Variation de lumière (0–254, brightness:N)';

  @override
  String get panelPickerSliderPositionTitle => 'Curseur — Position';

  @override
  String get panelPickerSliderPositionSubtitle =>
      'Volet / store (0–100, position:N)';

  @override
  String get panelPickerCoverTitle => 'Volet';

  @override
  String get panelPickerCoverSubtitle =>
      'Volet/store : OUVRIR·STOP·FERMER + curseur de position';

  @override
  String get panelPickerScheduleTitle => 'Programmation';

  @override
  String get panelPickerScheduleSubtitle =>
      'Heures d\'ouverture/fermeture quotidiennes, exécutées sur le hub (Node-RED)';

  @override
  String get panelPickerAutoCloseTitle => 'Règle d\'arrêt auto';

  @override
  String get panelPickerAutoCloseSubtitle =>
      'Éteint un appareil automatiquement N secondes après son allumage, exécuté sur le hub (Node-RED)';

  @override
  String get panelPickerMultiStateTitle => 'Multi-état';

  @override
  String get panelPickerMultiStateSubtitle =>
      'Boutons segmentés pour une énumération (ex. OPEN/STOP/CLOSE)';

  @override
  String get panelPickerComboTitle => 'Liste';

  @override
  String get panelPickerComboSubtitle =>
      'Sélecteur déroulant pour une énumération';

  @override
  String get panelPickerRadioTitle => 'Radio';

  @override
  String get panelPickerRadioSubtitle =>
      'Liste de boutons radio pour une énumération';

  @override
  String get panelPickerButtonTitle => 'Bouton';

  @override
  String get panelPickerButtonSubtitle => 'Envoie une commande ponctuelle';

  @override
  String get panelPickerTextInputTitle => 'Saisie de texte';

  @override
  String get panelPickerTextInputSubtitle =>
      'Publie une valeur libre ou du JSON';

  @override
  String get panelPickerLedTitle => 'LED';

  @override
  String get panelPickerLedSubtitle =>
      'Voyant coloré pour un état booléen (contact, fuite)';

  @override
  String get panelPickerNodeStatusTitle => 'État du nœud';

  @override
  String get panelPickerNodeStatusSubtitle =>
      'Disponibilité de l\'appareil Z2M (en ligne/hors ligne)';

  @override
  String get panelPickerProgressTitle => 'Progression';

  @override
  String get panelPickerProgressSubtitle =>
      'Barre numérique pour batterie, qualité du lien, etc.';

  @override
  String get panelPickerTextLogTitle => 'Journal';

  @override
  String get panelPickerTextLogSubtitle =>
      'Historique défilant des messages d\'un topic';

  @override
  String get dashExportMenu => 'Exporter les tableaux de bord';

  @override
  String get dashImportMenu => 'Importer des tableaux de bord';

  @override
  String get dashExportTitle => 'Exporter les tableaux de bord';

  @override
  String get dashExportClose => 'Fermer';

  @override
  String get dashExportCopy => 'Copier';

  @override
  String get dashExportCopied => 'Copié dans le presse-papiers';

  @override
  String get dashImportTitle => 'Importer des tableaux de bord';

  @override
  String get dashImportHint => 'Collez ici le JSON exporté';

  @override
  String get dashImportButton => 'Importer';

  @override
  String dashImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tableaux de bord importés',
      one: '1 tableau de bord importé',
    );
    return '$_temp0';
  }

  @override
  String dashImportFailed(Object error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get dashFormNew => 'Nouveau tableau de bord';

  @override
  String get dashFormEdit => 'Modifier le tableau de bord';

  @override
  String get dashFormName => 'Nom';

  @override
  String get dashFormNameHint => 'Bureau';

  @override
  String get dashFormTopicPrefix => 'Préfixe de topic (facultatif)';

  @override
  String get dashFormTopicPrefixHint => 'zigbee2mqtt/salon';

  @override
  String get dashFormTopicPrefixHelper =>
      'Ajouté devant chaque topic de panneau de ce tableau de bord';

  @override
  String get dashFormColorSeed => 'Couleur de base';

  @override
  String get dashFormIcon => 'Icône';

  @override
  String get dashFormLock => 'Verrouiller';

  @override
  String get dashFormLockSubtitle =>
      'Masque les commandes d\'édition tant que verrouillé';

  @override
  String get dashFormDelete => 'Supprimer le tableau de bord';

  @override
  String get dashDeleteTitle => 'Supprimer ce tableau de bord ?';

  @override
  String get dashDeleteContent =>
      'Tous ses panneaux seront également supprimés.';

  @override
  String get dashDeleteConfirm => 'Supprimer';

  @override
  String panelFormNew(Object type) {
    return 'Nouveau $type';
  }

  @override
  String panelFormEdit(Object type) {
    return 'Modifier $type';
  }

  @override
  String get panelTypeButton => 'Bouton';

  @override
  String get panelTypeToggle => 'Interrupteur';

  @override
  String get panelTypeSlider => 'Curseur';

  @override
  String get panelTypeLed => 'LED';

  @override
  String get panelTypeNodeStatus => 'État du nœud';

  @override
  String get panelTypeProgress => 'Progression';

  @override
  String get panelTypeMultiState => 'Multi-état';

  @override
  String get panelTypeCombo => 'Liste';

  @override
  String get panelTypeRadio => 'Radio';

  @override
  String get panelTypeCover => 'Volet';

  @override
  String get panelTypeTextInput => 'Saisie de texte';

  @override
  String get panelTypeTextLog => 'Journal';

  @override
  String get panelTypeSchedule => 'Programmation';

  @override
  String get panelTypeAutoClose => 'Arrêt auto';

  @override
  String get panelTypeDevice => 'Appareil';

  @override
  String get panelTypeReading => 'Mesure';

  @override
  String get panelFormName => 'Nom';

  @override
  String panelFormDashboardPrefix(Object prefix) {
    return 'Préfixe du tableau de bord : $prefix/ (utilisé sauf remplacement ci-dessous)';
  }

  @override
  String get panelFormTopicPrefixOverride =>
      'Remplacement du préfixe de topic (facultatif)';

  @override
  String get panelFormTopicPrefixOverrideHint => 'zigbee2mqtt/volet';

  @override
  String get panelFormTopicPrefixOverrideHelper =>
      'Utilisez un autre appareil sur ce tableau de bord. Vide = préfixe du tableau de bord.';

  @override
  String get panelFormPublishTopic => 'Topic de publication (suffixe)';

  @override
  String get panelFormPublishTopicHint => 'set';

  @override
  String get panelFormPublishTopicHelper =>
      'Ajouté au préfixe effectif. Laissez vide pour publier sur le préfixe lui-même.';

  @override
  String get panelFormTopicSuffix => 'Topic (suffixe)';

  @override
  String get panelFormSubscribeTopic =>
      'Topic d\'abonnement (suffixe, facultatif)';

  @override
  String get panelFormSubscribeTopicHelperReadOnly =>
      'Ajouté au préfixe du tableau de bord. Vide = abonnement au préfixe lui-même (état Z2M).';

  @override
  String get panelFormSubscribeTopicHelper =>
      'Vide = abonnement au préfixe lui-même (état Z2M). Identique au topic de publication = utiliser celui-ci.';

  @override
  String get tileSize => 'Taille';

  @override
  String get tileSizeSmall => 'Petit';

  @override
  String get tileSizeWide => 'Large';

  @override
  String get tileSizeFull => 'Pleine largeur';

  @override
  String get panelFormQos => 'QoS';

  @override
  String get panelFormQos0 => '0 — au plus une fois';

  @override
  String get panelFormQos1 => '1 — au moins une fois';

  @override
  String get panelFormQos2 => '2 — exactement une fois';

  @override
  String get panelFormRetain => 'Retain';

  @override
  String get panelToggleOnPayload => 'Charge utile « marche »';

  @override
  String get panelToggleOffPayload => 'Charge utile « arrêt »';

  @override
  String get panelToggleJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelToggleJsonPathHint => 'state';

  @override
  String get panelToggleOnMatch => 'Valeur « marche »';

  @override
  String get panelToggleOnMatchHelper =>
      'Valeur au chemin JSON qui signifie « marche » (ex. « ON »)';

  @override
  String get panelSliderMin => 'Min';

  @override
  String get panelSliderMax => 'Max';

  @override
  String get panelSliderStep => 'Pas';

  @override
  String get panelSliderTemplate => 'Modèle de valeur';

  @override
  String get panelSliderTemplateHelper =>
      'Utilisez le mot value comme espace réservé : il est remplacé par la valeur du curseur';

  @override
  String get panelSliderJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelSliderJsonPathHint => 'brightness';

  @override
  String get panelButtonPayload => 'Charge utile';

  @override
  String get panelLedJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelLedJsonPathHint => 'contact';

  @override
  String get panelLedJsonPathHelper =>
      'ex. « contact », « occupancy », « water_leak »';

  @override
  String get panelLedOnMatch => 'Valeur « allumé »';

  @override
  String get panelLedOnMatchHelper =>
      'Valeur au chemin JSON qui allume la LED (ex. « true », « ON »)';

  @override
  String get panelLedOnLabel => 'Libellé allumé (facultatif)';

  @override
  String get panelLedOnLabelHint => 'ON';

  @override
  String get panelLedOffLabel => 'Libellé éteint (facultatif)';

  @override
  String get panelLedOffLabelHint => 'OFF';

  @override
  String get panelNodeOnlinePayload => 'Charge utile « en ligne »';

  @override
  String get panelNodeOnlinePayloadHelper =>
      'Valeur qui signifie « en ligne » (défaut Z2M : « online »)';

  @override
  String get panelNodeJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelNodeJsonPathHelper =>
      'Laissez vide pour le défaut Z2M (chaîne brute « online »/« offline »)';

  @override
  String get panelProgressMin => 'Min';

  @override
  String get panelProgressMax => 'Max';

  @override
  String get panelProgressUnit => 'Unité';

  @override
  String get panelProgressUnitHint => '%';

  @override
  String get panelProgressJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelProgressJsonPathHint => 'battery';

  @override
  String get panelProgressJsonPathHelper => 'ex. « battery », « linkquality »';

  @override
  String get panelOptionsJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelOptionsJsonPathHint => 'state';

  @override
  String get panelOptionsJsonPathHelper =>
      'Champ de la charge utile reçue qui contient la valeur actuelle';

  @override
  String get panelOptionsHeader => 'Options';

  @override
  String get panelOptionsLabel => 'Libellé';

  @override
  String get panelOptionsPayload => 'Charge utile';

  @override
  String get panelOptionsMatch => 'Correspondance (valeur actuelle)';

  @override
  String get panelOptionsAdd => 'Ajouter une option';

  @override
  String get panelCoverDescription =>
      'Boutons OUVRIR / STOP / FERMER plus une rangée de positions prédéfinies. Utilise les charges utiles Z2M standard pour les volets (state et position).';

  @override
  String get panelCoverPresets => 'Positions prédéfinies';

  @override
  String get panelCoverPresetsHint => '0, 25, 50, 100';

  @override
  String get panelCoverPresetsHelper =>
      'Pourcentages séparés par des virgules (0–100). Vide = pas de rangée de positions.';

  @override
  String get panelCoverShowSlider => 'Afficher le curseur de position';

  @override
  String get panelTextInputHint => 'Indication (facultatif)';

  @override
  String get panelTextInputHintHint => 'Saisissez une valeur…';

  @override
  String get panelTextInputTemplate => 'Modèle';

  @override
  String get panelTextInputTemplateHelper =>
      'Utilisez le mot value comme espace réservé : il est remplacé par le texte saisi. Par défaut, le texte brut est publié.';

  @override
  String get panelTextInputClearAfterSend => 'Effacer après envoi';

  @override
  String get panelTextLogMaxLines => 'Lignes max';

  @override
  String get panelTextLogMaxLinesHelper =>
      'Nombre de messages récents à conserver';

  @override
  String get panelTextLogJsonPath => 'Chemin JSON (facultatif)';

  @override
  String get panelTextLogJsonPathHelper =>
      'Journalise uniquement ce champ au lieu de toute la charge utile';

  @override
  String get panelScheduleDescription =>
      'S\'exécute sur le SMHUB via Node-RED : se déclenche même quand ce téléphone est éteint. Le topic de publication ci-dessus est la cible de commande du volet.';

  @override
  String get panelScheduleOpenTime => 'Heure d\'ouverture';

  @override
  String get panelScheduleCloseTime => 'Heure de fermeture';

  @override
  String get panelScheduleOpenPayload => 'Charge utile d\'ouverture';

  @override
  String get panelScheduleClosePayload => 'Charge utile de fermeture';

  @override
  String get panelScheduleEnabled => 'Activé';

  @override
  String get panelScheduleSavedOffline =>
      'Enregistré — non connecté ; la programmation se synchronisera une fois en ligne.';

  @override
  String get panelAutoCloseDescription =>
      'S\'exécute sur le SMHUB via Node-RED : se déclenche même quand ce téléphone est éteint. Le topic de publication ci-dessus est la cible de commande de l\'appareil (ex. porte).';

  @override
  String get panelAutoCloseTriggerPath => 'Chemin JSON du déclencheur';

  @override
  String get panelAutoCloseTriggerPathHelper =>
      'Champ du JSON d\'état de l\'appareil à surveiller (défaut : state)';

  @override
  String get panelAutoCloseTriggerValue => 'Valeur de déclenchement';

  @override
  String get panelAutoCloseTriggerValueHelper =>
      'Lance le minuteur quand le champ déclencheur vaut cette valeur (défaut : ON)';

  @override
  String get panelAutoCloseClosePayload => 'Charge utile de fermeture';

  @override
  String get panelAutoCloseDelaySeconds => 'Délai (secondes)';

  @override
  String get panelAutoCloseDelaySecondsHelper =>
      '1-3600. Temps d\'attente après l\'allumage de l\'appareil avant de publier la charge utile de fermeture.';

  @override
  String get panelAutoCloseEnabled => 'Activé';

  @override
  String get panelAutoCloseSavedOffline =>
      'Enregistré — non connecté ; la règle se synchronisera une fois en ligne.';

  @override
  String get panelTileEdit => 'Modifier le panneau';

  @override
  String get panelTileDuplicate => 'Dupliquer le panneau';

  @override
  String get panelTileMoveUp => 'Monter';

  @override
  String get panelTileMoveDown => 'Descendre';

  @override
  String get panelTileDelete => 'Supprimer le panneau';

  @override
  String get panelCoverOpen => 'Ouvrir';

  @override
  String get panelCoverStop => 'Stop';

  @override
  String get panelCoverClose => 'Fermer';

  @override
  String get panelToggleNoState => '(aucun état)';

  @override
  String get panelToggleError => 'err';

  @override
  String get panelStateOn => 'ON';

  @override
  String get panelStateOff => 'OFF';

  @override
  String get panelNodeStatusOnline => 'en ligne';

  @override
  String get panelNodeStatusOffline => 'hors ligne';

  @override
  String get panelNodeStatusUnknown => 'inconnu';

  @override
  String get panelNodeStatusError => 'erreur';

  @override
  String get panelMultiStateNoOptions => 'Aucune option configurée';

  @override
  String get panelTextInputDefaultHint => 'Saisissez une valeur…';

  @override
  String get panelTextLogWaiting => 'En attente de messages…';

  @override
  String panelScheduleOpensAt(Object time) {
    return 'Ouvre à $time';
  }

  @override
  String panelScheduleClosesAt(Object time) {
    return 'Ferme à $time';
  }

  @override
  String get panelScheduleOfflineWarning =>
      'Programmateur hors ligne — ne s\'exécutera pas';

  @override
  String get panelScheduleDisabled => 'Désactivé';

  @override
  String panelScheduleNext(Object action, Object at) {
    return 'Prochain : $action à $at';
  }

  @override
  String get panelScheduleActionOpen => 'ouverture';

  @override
  String get panelScheduleActionClose => 'fermeture';

  @override
  String get panelAutoCloseIdle => 'Inactif';

  @override
  String get panelAutoCloseDisabled => 'Désactivé';

  @override
  String get panelAutoCloseOffline =>
      'Automatisation hors ligne — la règle ne s\'exécutera pas';

  @override
  String panelAutoCloseClosingIn(int seconds) {
    return 'Fermeture dans $seconds s';
  }

  @override
  String get panelAutoCloseClosingNow => 'Fermeture en cours…';

  @override
  String get panelGridEmpty =>
      'Aucune tuile pour l’instant.\nAppuyez sur Ajouter une tuile pour placer vos appareils ici.';

  @override
  String get panelsOffline => 'Hors ligne — dernières valeurs affichées';

  @override
  String get connectionConnecting => 'Connexion…';

  @override
  String get connectionReconnecting => 'Reconnexion…';

  @override
  String get connectionShowingLastKnownValues =>
      'Dernières valeurs connues affichées';

  @override
  String get connectionFailed => 'Échec de la connexion';

  @override
  String get connectionAutomaticRetry =>
      'Les tentatives automatiques continuent';

  @override
  String get connectionReconnectNow => 'Reconnecter maintenant';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsHelp => 'Aide et guide';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsRateApp => 'Noter ZigDash';

  @override
  String get settingsRateAppSubtitle =>
      'Vous aimez l\'appli ? Un avis rapide aide les autres à la trouver.';

  @override
  String get settingsFeatureRequest => 'Proposer une fonction';

  @override
  String get settingsFeatureRequestSubtitle =>
      'Dites-moi ce qui améliorerait ZigDash.';

  @override
  String get featureRequestGithub => 'Sur GitHub';

  @override
  String get featureRequestGithubSubtitle =>
      'Public : d\'autres peuvent le voir et voter.';

  @override
  String get featureRequestEmail => 'Par e-mail';

  @override
  String get featureRequestEmailSubtitle =>
      'Privé, directement au développeur.';

  @override
  String get featureRequestEmailSubject => 'ZigDash : demande de fonction';

  @override
  String get featureRequestEmailPrompt =>
      'Que voudriez-vous que ZigDash fasse, et pourquoi ?';

  @override
  String get settingsReportProblem => 'Signaler un problème';

  @override
  String get settingsReportProblemSubtitle =>
      'Quelque chose ne marche pas ou n\'est pas clair ? Dites-le-moi.';

  @override
  String get reportProblemEmailSubject => 'ZigDash : signalement de problème';

  @override
  String get reportProblemEmailPrompt =>
      'Que s\'est-il passé, et qu\'attendiez-vous ? Le modèle de l\'appareil et la version de Zigbee2MQTT aident.';

  @override
  String get settingsBuyCoffee => 'M\'offrir un café';

  @override
  String get settingsBuyCoffeeSubtitle =>
      'Gratuit et open source — les pourboires font tourner la machine.';

  @override
  String get a11yBackupMenu => 'Sauvegarde et restauration';

  @override
  String get a11ySelectColor => 'Choisir la couleur';

  @override
  String get a11ySelectIcon => 'Choisir l\'icône';

  @override
  String get a11yDeleteOption => 'Supprimer l\'option';

  @override
  String get a11yPanelOptions => 'Options du panneau';

  @override
  String get a11yMoreOptions => 'Plus d\'options';

  @override
  String get a11yRefresh => 'Actualiser';

  @override
  String get a11yDeleteConnection => 'Supprimer la connexion';

  @override
  String get controlNotConnected => 'Non connecté — modification non envoyée';

  @override
  String get discoverFromDevice => 'Ajouter depuis un appareil…';

  @override
  String get discoverFromDeviceSubtitle =>
      'Détecter automatiquement un appareil Zigbee2MQTT';

  @override
  String get discoverTitle => 'Ajouter depuis un appareil';

  @override
  String get discoverBaseTopic => 'Topic de base Zigbee2MQTT';

  @override
  String get discoverScanning => 'Recherche d\'appareils…';

  @override
  String get discoverNone => 'Aucun appareil trouvé.';

  @override
  String get discoverFailed =>
      'Aucune liste d\'appareils trouvée. Vérifiez le topic de base et que le broker est connecté.';

  @override
  String get retry => 'Réessayer';

  @override
  String get previewTitle => 'Aperçu en direct';

  @override
  String previewWaiting(Object topic) {
    return 'En attente d\'un message sur $topic…';
  }

  @override
  String previewExtracted(Object path, Object value) {
    return 'Extrait ($path) : $value';
  }

  @override
  String get previewNoValue => '(aucune valeur à ce chemin)';

  @override
  String get connErrorTitle => 'Erreur de connexion';

  @override
  String get connErrorUnknown => 'Aucun détail d\'erreur disponible.';

  @override
  String get connTestButton => 'Tester la connexion';

  @override
  String get connTestOk => 'Connexion réussie';

  @override
  String connTestFailed(Object error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get devicesTitle => 'Appareils';

  @override
  String get devicesAddButton => 'Ajouter un appareil';

  @override
  String get devicesPairingTitle =>
      'Appairage — appuyez sur le bouton de l\'appareil';

  @override
  String devicesPairingHint(int seconds) {
    return 'Recherche de nouveaux appareils… $seconds s';
  }

  @override
  String get devicesPairingStop => 'Arrêter';

  @override
  String get devicesNone => 'Aucun appareil trouvé.';

  @override
  String get devicesListMissing =>
      'Zigbee2MQTT n\'a pas envoyé sa liste d\'appareils. Cela peut arriver après un redémarrage du broker MQTT.';

  @override
  String get devicesRestartZ2m => 'Redémarrer Zigbee2MQTT';

  @override
  String get devicesRestartingZ2m =>
      'Redémarrage de Zigbee2MQTT. Vos appareils devraient apparaître dans quelques secondes.';

  @override
  String get devicesBattery => 'Batterie';

  @override
  String get devicesLinkQuality => 'Lien';

  @override
  String get devicesOnline => 'En ligne';

  @override
  String get devicesOffline => 'Hors ligne';

  @override
  String devicesPaired(Object name) {
    return 'Prêt : $name';
  }

  @override
  String get devicesPairedHint =>
      'Ajouté à votre réseau. Pour le placer sur un tableau de bord, utilisez « Ajouter depuis un appareil » sur ce tableau de bord.';

  @override
  String get scenesTitle => 'Scènes';

  @override
  String get scenesNone =>
      'Aucune scène pour l\'instant. Réglez vos appareils comme vous le souhaitez, puis capturez-les en scène.';

  @override
  String get scenesNewButton => 'Nouvelle scène';

  @override
  String scenesActivated(Object name) {
    return '$name activée';
  }

  @override
  String get scenesActivateOffline =>
      'Non connecté — impossible d\'activer la scène';

  @override
  String get sceneFormNewTitle => 'Nouvelle scène';

  @override
  String get sceneFormEditTitle => 'Modifier la scène';

  @override
  String get sceneFormNameLabel => 'Nom de la scène';

  @override
  String get sceneFormDevicesHeader => 'Appareils à capturer';

  @override
  String get sceneFormCaptureHint =>
      'L\'état réglable actuel de chaque appareil sélectionné (marche/arrêt, luminosité, couleur, position…) est enregistré. Les valeurs en lecture seule sont ignorées.';

  @override
  String get sceneFormNoDevices =>
      'Aucun appareil contrôlable trouvé. Vérifiez qu\'ils sont appairés, puis appuyez sur actualiser.';

  @override
  String get sceneFormReadingState => 'Lecture de l\'état actuel…';

  @override
  String get sceneCtrlPower => 'Alimentation';

  @override
  String get sceneCtrlBrightness => 'Luminosité';

  @override
  String get sceneCtrlPosition => 'Position';

  @override
  String sceneFormSelectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get sceneFormNoDevicesSelected =>
      'Sélectionnez au moins un appareil à capturer.';

  @override
  String get sceneFormNothingCaptured =>
      'Rien de réglable n\'a été capturé sur les appareils sélectionnés.';

  @override
  String get sceneDeleteTitle => 'Supprimer la scène ?';

  @override
  String sceneDeleteMessage(Object name) {
    return '« $name » sera supprimée. Les appareils conservent leur état actuel.';
  }

  @override
  String get sceneEditAction => 'Modifier';

  @override
  String get sceneDeleteAction => 'Supprimer';

  @override
  String get sceneAddToDashboard => 'Ajouter au tableau de bord';

  @override
  String sceneAddedToDashboard(Object name) {
    return 'Ajouté à $name';
  }

  @override
  String sceneActionsCount(int count) {
    return '$count appareils';
  }

  @override
  String get panelTypeScene => 'Scène';

  @override
  String get panelPickerSceneTitle => 'Bouton de scène';

  @override
  String get panelPickerSceneSubtitle =>
      'Une pression active une scène enregistrée';

  @override
  String get panelSceneChoose => 'Scène';

  @override
  String get panelSceneMissing =>
      'Scène introuvable — sélectionnez-la à nouveau';

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
  String get guidedConnectTitle => 'Configurez votre broker';

  @override
  String get guidedConnectIntro =>
      'Nous testerons chaque étape de la connexion et afficherons vos appareils Zigbee.';

  @override
  String get guidedBaseTopic => 'Topic de base';

  @override
  String get guidedBaseTopicHint => 'zigbee2mqtt';

  @override
  String get guidedConnect => 'Tester et connecter';

  @override
  String get guidedTesting => 'Test de votre connexion…';

  @override
  String get stepResolve => 'Résolution de l\'hôte';

  @override
  String get stepTcp => 'Connexion TCP';

  @override
  String get stepConnack => 'Négociation MQTT';

  @override
  String get stepAuth => 'Authentification';

  @override
  String get stepDevices => 'Recherche d\'appareils';

  @override
  String get diagResolveFail =>
      'Le nom d\'hôte n\'a pas pu être résolu. Vérifiez l\'adresse saisie.';

  @override
  String get diagResolveTimeout =>
      'La résolution de l\'hôte a expiré. Vérifiez l\'adresse et votre réseau.';

  @override
  String get diagTcpFail =>
      'Impossible de joindre le broker. Zigbee2MQTT est-il lancé ? Vérifiez l\'adresse et le port.';

  @override
  String get diagTcpTimeout =>
      'La connexion au broker a expiré. Il est peut-être hors ligne ou injoignable.';

  @override
  String get diagConnackFail =>
      'Le broker n\'a pas terminé la négociation MQTT. Vérifiez qu\'il s\'agit bien d\'un broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagAuthRejected =>
      'Le broker a refusé le nom d\'utilisateur ou le mot de passe. Vérifiez vos identifiants.';

  @override
  String get diagAuthRefused =>
      'Le broker a refusé la connexion. Vérifiez les paramètres de connexion.';

  @override
  String foundDevices(Object count) {
    return '$count appareils trouvés';
  }

  @override
  String get foundDevicesHint =>
      'Vos appareils Zigbee sont visibles. Continuez pour créer votre tableau de bord.';

  @override
  String get noDevicesTitle =>
      'Connecté — aucun appareil trouvé pour l\'instant';

  @override
  String get noDevicesHint =>
      'ZigDash voit votre broker, mais n\'a pas encore trouvé d\'appareils Zigbee. Vous pouvez lancer l\'appairage pour en ajouter.';

  @override
  String get startPairing => 'Lancer l\'appairage';

  @override
  String get pairingEnabled =>
      'L\'appairage est activé. Appuyez sur le bouton d\'appairage de votre appareil pour le connecter.';

  @override
  String get continueToDashboard => 'Continuer vers le tableau de bord';

  @override
  String get guidedBackToForm => 'Modifier les paramètres';

  @override
  String ladderTriedHint(Object count) {
    return '$count adresses essayées';
  }

  @override
  String get guidedSaveFailed =>
      'Impossible d\'enregistrer la connexion. Veuillez réessayer.';

  @override
  String get setupWelcomeTitle => 'Bienvenue dans ZigDash';

  @override
  String get setupWelcomeBody =>
      'ZigDash pilote votre installation Zigbee2MQTT existante, en local et sans cloud. Vérifiez que Zigbee2MQTT est lancé, puis laissez ZigDash le trouver.';

  @override
  String get setupFindMySetup => 'Trouver mon installation';

  @override
  String get setupManualEntry => 'Saisir les détails manuellement';

  @override
  String get setupScanningTitle => 'Recherche d\'une connexion…';

  @override
  String get setupScanningHint =>
      'Gardez cet appareil sur le même réseau local que votre hôte Zigbee2MQTT.';

  @override
  String get setupCandidateFound => 'Connexion possible trouvée';

  @override
  String get setupNoCandidatesTitle => 'Aucune connexion trouvée';

  @override
  String get setupNoCandidatesBody => 'Où s\'exécute Zigbee2MQTT ?';

  @override
  String get setupGuideHa =>
      'Home Assistant : vérifiez que le module MQTT (ex. Mosquitto) et le module Zigbee2MQTT sont installés et lancés.';

  @override
  String get setupGuidePi =>
      'Raspberry Pi / Linux : vérifiez que votre broker (ex. Mosquitto) et le service Zigbee2MQTT sont lancés, et que le port 1883 est joignable.';

  @override
  String get setupGuideSmlight =>
      'SMLIGHT / SMHUB : ouvrez l\'interface web, allez dans Settings > MQTT, activez Allow External pour que le téléphone atteigne le broker, et vérifiez que Zigbee2MQTT tourne.';

  @override
  String get setupTryAgain => 'Réessayer';

  @override
  String get setupAuthTitle => 'Ce broker requiert des identifiants';

  @override
  String setupAuthBody(Object host) {
    return 'Saisissez le nom d\'utilisateur et le mot de passe MQTT pour $host.';
  }

  @override
  String get setupAuthRejectedBody =>
      'Le nom d\'utilisateur ou le mot de passe a été refusé. Vérifiez-les et réessayez.';

  @override
  String get setupVerifyingTitle => 'Vérification de la connexion…';

  @override
  String get setupReviewTitle => 'Vos appareils';

  @override
  String setupReviewSubtitle(Object count) {
    return '$count appareils trouvés. Choisissez ce qui ira sur votre premier tableau de bord.';
  }

  @override
  String setupCreateWithCount(Object count) {
    return 'Créer le tableau de bord avec $count';
  }

  @override
  String get setupGroupOther => 'Autres appareils';

  @override
  String get setupGroupUnsupported => 'Appareils non pris en charge';

  @override
  String get setupCreatingTitle => 'Création de votre tableau de bord…';

  @override
  String get setupReadyTitle => 'Votre tableau de bord est prêt';

  @override
  String setupReadyBody(Object count) {
    return '$count commandes créées.';
  }

  @override
  String get setupOpenDashboard => 'Ouvrir le tableau de bord';

  @override
  String get setupErrUnreachableTitle => 'Impossible de joindre cette adresse';

  @override
  String get setupErrUnreachableBody =>
      'Cet appareil et l\'hôte Zigbee2MQTT ne peuvent pas communiquer. Vérifiez qu\'ils sont sur le même réseau local.';

  @override
  String get setupErrUnreachableAction => 'Réessayer';

  @override
  String get setupErrPortClosedTitle => 'Rien ne répond sur ce port';

  @override
  String get setupErrPortClosedBody =>
      'L\'hôte est joignable, mais aucun broker MQTT n\'a répondu. Vérifiez que le broker est lancé et que le port est correct.';

  @override
  String get setupErrPortClosedAction => 'Réessayer';

  @override
  String get setupErrAuthRequiredTitle => 'Identifiants requis';

  @override
  String get setupErrAuthRequiredBody =>
      'Ce broker requiert un nom d\'utilisateur et un mot de passe.';

  @override
  String get setupErrAuthRequiredAction => 'Saisir les identifiants';

  @override
  String get setupErrAuthRejectedTitle => 'Identifiants refusés';

  @override
  String get setupErrAuthRejectedBody => 'Le broker a refusé ces identifiants.';

  @override
  String get setupErrAuthRejectedAction => 'Réessayer';

  @override
  String get setupErrNotZ2mTitle => 'Pas de Zigbee2MQTT ici';

  @override
  String get setupErrNotZ2mBody =>
      'Un broker MQTT répond ici, mais aucun topic Zigbee2MQTT n\'a été trouvé. C\'est peut-être un autre broker.';

  @override
  String get setupErrNotZ2mAction => 'En choisir un autre';

  @override
  String get setupErrNoDevicesTitle => 'Aucun appareil reçu';

  @override
  String get setupErrNoDevicesBody =>
      'Zigbee2MQTT est lancé, mais aucun appareil n\'a été publié pendant la vérification. Appairez d\'abord des appareils dans Zigbee2MQTT.';

  @override
  String get setupErrNoDevicesAction => 'Vérifier à nouveau';

  @override
  String get setupErrScanFailedTitle => 'Pas de réseau local';

  @override
  String get setupErrScanFailedBody =>
      'Impossible de déterminer le réseau local de cet appareil. Connectez-vous au Wi-Fi et réessayez.';

  @override
  String get setupErrScanFailedAction => 'Réessayer';

  @override
  String get setupErrSaveFailedTitle => 'Enregistrement impossible';

  @override
  String get setupErrSaveFailedBody =>
      'L\'enregistrement de votre configuration a échoué. Rien n\'a été enregistré à moitié, vous pouvez réessayer sans risque.';

  @override
  String get setupErrSaveFailedAction => 'Réessayer';

  @override
  String get setupErrUnknownTitle => 'Un problème est survenu';

  @override
  String get setupErrUnknownBody => 'Une erreur inattendue s\'est produite.';

  @override
  String get setupErrUnknownAction => 'Réessayer';

  @override
  String get setupNoZ2mTitle =>
      'Votre broker fonctionne, mais Zigbee2MQTT ne publie pas ici';

  @override
  String setupNoZ2mBody(String base) {
    return 'Nous avons écouté $base/bridge sans rien recevoir.';
  }

  @override
  String get setupBaseTopicQuestion => 'Un autre topic de base ?';

  @override
  String get setupGuidesTitle => 'Configurer Zigbee2MQTT';

  @override
  String get setupTryDemoMeanwhile => 'Essayer la démo en attendant';

  @override
  String get demoBannerText => 'Vous êtes en mode démo';

  @override
  String get demoBannerAction => 'Connecter votre maison';

  @override
  String get deviceOn => 'Allumé';

  @override
  String get deviceOff => 'Éteint';

  @override
  String get deviceOpen => 'Ouvert';

  @override
  String get deviceClosed => 'Fermé';

  @override
  String get deviceMotion => 'Mouvement';

  @override
  String get deviceClear => 'Calme';

  @override
  String get deviceLeakDetected => 'Fuite détectée';

  @override
  String get deviceSmokeDetected => 'Fumée détectée';

  @override
  String get deviceGasDetected => 'Gaz détecté';

  @override
  String get deviceWaiting => 'En attente du premier relevé';

  @override
  String deviceEndpointsOnOff(int on, int off) {
    return '$on allumés · $off éteints';
  }

  @override
  String get deviceBrightness => 'Luminosité';

  @override
  String get deviceWhite => 'Blanc';

  @override
  String get deviceColor => 'Couleur';

  @override
  String get deviceHue => 'Teinte';

  @override
  String get devicePosition => 'Position';

  @override
  String get deviceControls => 'Commandes';

  @override
  String deviceBattery(int percent) {
    return 'Batterie $percent %';
  }

  @override
  String get deviceToggle => 'Allumer ou éteindre';

  @override
  String get deviceMore => 'Plus';

  @override
  String get sectionLights => 'Lumières';

  @override
  String get sectionSwitchesCovers => 'Interrupteurs et volets';

  @override
  String get sectionSensors => 'Capteurs';

  @override
  String get sectionOther => 'Autres';

  @override
  String get homeFirstName => 'Ma maison';

  @override
  String homeNumberedName(int number) {
    return 'Maison $number';
  }

  @override
  String get dashAddTile => 'Ajouter une tuile';

  @override
  String get addTileSearch => 'Rechercher des appareils';

  @override
  String get addTileNotOnDashboard => 'Sur aucun tableau de bord';

  @override
  String get addTileAllDevices => 'Tous les appareils';

  @override
  String get addTileReading => 'Mesure';

  @override
  String get addTileReadingSubtitle => 'Une valeur d’un appareil ou d’un topic';

  @override
  String get addTileCustom => 'Tuile MQTT personnalisée';

  @override
  String get addTileCustomSubtitle => 'Tout type de tuile, configuré par topic';

  @override
  String get addTileNoDevices =>
      'Aucun appareil. Connectez-vous à votre broker ou appairez un appareil dans Zigbee2MQTT.';

  @override
  String get addTileAdd => 'Ajouter';

  @override
  String get addTileName => 'Nom';

  @override
  String addTileNameHint(String model) {
    return 'ex. $model';
  }

  @override
  String get addTileSection => 'Section';

  @override
  String get addTileNoSection => 'Aucune section';

  @override
  String get addTileSize => 'Taille';

  @override
  String get deviceClassColorLight => 'Lumière couleur';

  @override
  String get deviceClassLight => 'Lumière';

  @override
  String get deviceClassSwitch => 'Interrupteur ou prise';

  @override
  String get deviceClassCover => 'Volet';

  @override
  String get deviceClassLeak => 'Fuite ou fumée';

  @override
  String get deviceClassContact => 'Contact';

  @override
  String get deviceClassMotion => 'Mouvement';

  @override
  String get deviceClassClimate => 'Capteur climatique';

  @override
  String get deviceClassGeneric => 'Appareil';

  @override
  String get deviceNotResponding => 'Ne répond pas';

  @override
  String get homeAdd => 'Ajouter une maison';

  @override
  String get homeManage => 'Gérer les maisons';

  @override
  String get homeSwitch => 'Changer de maison';

  @override
  String get navDevices => 'Appareils';

  @override
  String get navScenes => 'Scènes';

  @override
  String get devicesNewDot => 'Nouveaux appareils';

  @override
  String get editEditing => 'Modification';

  @override
  String get editDashboard => 'Tableau de bord';

  @override
  String get editDone => 'Terminé';

  @override
  String get editAddSection => 'Ajouter une section';

  @override
  String get editSectionName => 'Nom de la section';

  @override
  String get editRenameSection => 'Renommer la section';

  @override
  String get editDeleteSection => 'Supprimer la section';

  @override
  String get editDeleteSectionBody => 'Que faire de ses tuiles ?';

  @override
  String get editKeepTiles => 'Garder les tuiles, retirer la section';

  @override
  String get editDeleteTiles => 'Supprimer aussi les tuiles';

  @override
  String get editMoveToSection => 'Déplacer vers une section';

  @override
  String get editEditTile => 'Modifier la tuile';

  @override
  String get editRemove => 'Retirer du tableau de bord';

  @override
  String get editRemoved => 'Tuile retirée';

  @override
  String get editUndo => 'Annuler';

  @override
  String get editReplaceWithDevice => 'Remplacer par une tuile d’appareil';

  @override
  String get editMoveEarlier => 'Avancer';

  @override
  String get editMoveLater => 'Reculer';

  @override
  String editUnassigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils ne sont sur aucun tableau de bord',
      one: '1 appareil n’est sur aucun tableau de bord',
    );
    return '$_temp0';
  }

  @override
  String get editTileActions => 'Options de la tuile';

  @override
  String get editSave => 'Enregistrer';

  @override
  String get editCancel => 'Annuler';

  @override
  String get ageJustNow => 'À l’instant';

  @override
  String ageMinutes(int n) {
    return 'il y a $n min';
  }

  @override
  String ageHours(int n) {
    return 'il y a $n h';
  }

  @override
  String get statusCantReach => 'Broker injoignable';

  @override
  String get statusWhy => 'Pourquoi ?';

  @override
  String get statusWhyTitle => 'Votre broker ne répond pas';

  @override
  String get statusWhyBody =>
      'ZigDash réessaie tout seul. En attendant, les tuiles affichent leurs dernières valeurs connues, estompées, avec leur âge. Vérifiez que le broker est allumé et que ce téléphone est sur le même réseau, ou testez la connexion dans ses réglages.';

  @override
  String get statusSettings => 'Réglages de connexion';

  @override
  String get deviceAddToDashboard => 'Ajouter à un tableau de bord';

  @override
  String get deviceDismiss => 'Ignorer';

  @override
  String get devicesFilterAll => 'Tous';

  @override
  String devicesFilterAttention(int count) {
    return 'À vérifier · $count';
  }

  @override
  String devicesFilterUnassigned(int count) {
    return 'Sur aucun tableau de bord · $count';
  }

  @override
  String get devicesNoMatch => 'Aucun appareil ne correspond';

  @override
  String get deviceBatteryLow => 'Batterie faible';

  @override
  String get deviceLinkWeak => 'Faible';

  @override
  String get deviceUnsupported => 'Non pris en charge par Zigbee2MQTT';

  @override
  String get deviceInterviewFailed => 'Appairage inachevé';

  @override
  String get deviceNoReport => 'Aucun rapport pour l\'instant';

  @override
  String get devicesAvailabilityOff =>
      'La disponibilité est désactivée dans Zigbee2MQTT, donc les appareils hors ligne s\'affichent comme « Ne répond pas ».';

  @override
  String get devicesAvailabilityHow => 'Comment l\'activer';

  @override
  String get devicesDotBattery => 'Batterie faible';

  @override
  String get deviceDetails => 'Détails de l\'appareil';

  @override
  String get deviceGone => 'Cet appareil n\'est plus dans Zigbee2MQTT.';

  @override
  String get deviceControlTitle => 'Contrôle';

  @override
  String get deviceReadingsTitle => 'Mesures';

  @override
  String get deviceHealthTitle => 'État';

  @override
  String get deviceOnDashboards => 'Sur les tableaux de bord';

  @override
  String get deviceUnsupportedBody =>
      'Zigbee2MQTT ne prend pas encore en charge cet appareil, il n\'y a donc rien à contrôler.';

  @override
  String get deviceAddReadingTile => 'Ajouter comme tuile de mesure';

  @override
  String get deviceAddReadingTo => 'Ajouter à quel tableau de bord ?';

  @override
  String deviceAddedTo(Object dashboard) {
    return 'Ajouté à $dashboard';
  }

  @override
  String get deviceLinkQuality => 'Qualité du lien';

  @override
  String get deviceLinkGood => 'Bonne';

  @override
  String get devicePowerSource => 'Alimentation';

  @override
  String get devicePowerBattery => 'Batterie';

  @override
  String get devicePowerMains => 'Secteur';

  @override
  String get deviceLastHeard => 'Dernier signal';

  @override
  String get deviceAvailability => 'Disponibilité';

  @override
  String get deviceAvailabilityOff => 'Désactivée dans Zigbee2MQTT';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsPrivacySubtitle =>
      'Aucune télémétrie. Tout reste sur ce téléphone.';

  @override
  String get homeCurrent => 'Maison actuelle';

  @override
  String get homeConnection => 'Connexion';

  @override
  String get homeSwitchTo => 'Passer à cette maison';

  @override
  String get homeDelete => 'Supprimer la maison';

  @override
  String get devicesSelect => 'Sélectionnez un appareil';

  @override
  String get scenesSelect => 'Sélectionnez une scène à modifier';

  @override
  String get panelFormTopic => 'Topic';

  @override
  String get panelFormPickDevice => 'Choisir un appareil';

  @override
  String get panelFormStateTopic => 'Topic d\'état';

  @override
  String get panelFormCommandTopic => 'Topic de commande';

  @override
  String get panelFormCommandTopicDerived =>
      'Rempli à partir du topic d\'état tant que vous ne le modifiez pas.';

  @override
  String panelFormLinkedTo(Object device) {
    return 'Lié à $device';
  }

  @override
  String get panelFormOpenDevice => 'Ouvrir l\'appareil';

  @override
  String get panelFormUnlink => 'Dissocier';

  @override
  String get panelFormValueChoices => 'Valeurs de cet appareil';

  @override
  String get panelFormAdvanced => 'Avancé';

  @override
  String get panelFormAdvancedSubtitle =>
      'Remplacement du préfixe, QoS, retain';

  @override
  String get panelFormStateTopicHelper =>
      'Vide = le préfixe lui-même (état d’un appareil Zigbee2MQTT).';

  @override
  String get dashWallDisplay => 'Affichage mural';

  @override
  String get dashWallDisplayOn =>
      'Affichage mural activé : l\'écran reste allumé et les barres se masquent après 10 secondes sans toucher. Touchez pour les revoir.';

  @override
  String get dashWallDisplayOff => 'Affichage mural désactivé.';

  @override
  String get analyticsSetupCheckbox =>
      'Partager des données d\'utilisation anonymes pour améliorer la configuration';

  @override
  String get analyticsWhatsShared => 'Ce qui est partagé';

  @override
  String get analyticsCardTitle => 'Aider à améliorer ZigDash ?';

  @override
  String get analyticsCardBody =>
      'Partager des données d\'utilisation anonymes : les étapes de configuration qui échouent et les fonctions utilisées. Jamais vos appareils, topics ou broker.';

  @override
  String get analyticsShare => 'Partager';

  @override
  String get analyticsNoThanks => 'Non merci';

  @override
  String get settingsAnalytics =>
      'Partager des données d\'utilisation anonymes';

  @override
  String get settingsAnalyticsSubtitle =>
      'Étapes de configuration et fonctions utilisées. Jamais vos appareils, topics ou broker.';

  @override
  String get settingsPrivacySubtitleOptIn =>
      'Données d\'utilisation anonymes, uniquement si vous l\'acceptez.';

  @override
  String get dashDefaultName => 'Maison';

  @override
  String get dashExportSaveFile => 'Enregistrer le fichier';

  @override
  String get dashExportSaved => 'Sauvegarde enregistrée';

  @override
  String get dashImportChooseFile => 'Choisir un fichier';

  @override
  String get dashImportFileUnreadable => 'Impossible de lire ce fichier';

  @override
  String get getHelpTitle => 'Get help';

  @override
  String get getHelpTryFirst => 'Try these first';

  @override
  String get getHelpPromise =>
      'Still stuck? I usually reply within 3 days, in English or Hebrew. I\'ll never ask for your passwords.';

  @override
  String get getHelpIncluded => 'What\'s included';

  @override
  String get getHelpContact => 'Contact support';

  @override
  String get getHelpCopy => 'Copy details';

  @override
  String get getHelpCopied => 'Details copied';

  @override
  String get getHelpLink => 'Still stuck? Get help';

  @override
  String get getHelpEmailSubject => 'ZigDash: help getting it working';

  @override
  String get getHelpEmailPrompt =>
      'What were you trying to do, and what happened?';

  @override
  String get settingsHelpSupport => 'Help & support';

  @override
  String get settingsGetHelp => 'Get help';

  @override
  String get settingsGetHelpSubtitle =>
      'Can\'t get it working? Tips first, then contact';

  @override
  String get demoBannerHelp => 'Get help';

  @override
  String get tipSameWifiTitle => 'Same Wi-Fi as your hub';

  @override
  String get tipSameWifiBody =>
      'Your phone must be on the same network as the hub, not a guest network. Turn mobile data off while you set up.';

  @override
  String get tipBrokerRunningTitle => 'The broker is running';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant: the Mosquitto add-on is started. Raspberry Pi: Mosquitto is running. SMLIGHT: Settings › MQTT is on.';

  @override
  String get tipBrokerAcceptsTitle => 'The broker accepts your phone';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT: turn on Allow External. Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).';

  @override
  String get tipMeshTitle => 'Mesh Wi-Fi or two routers?';

  @override
  String get tipMeshBody =>
      'If the hub hangs off a second router, your phone may not see it. Plug the hub into the main router, or connect by its address.';

  @override
  String get tipByAddressTitle => 'Connect by address';

  @override
  String get tipByAddressBody =>
      'Find the hub\'s address in your router\'s app, then tap Enter details manually.';

  @override
  String get tipSameNetworkTitle => 'Same network';

  @override
  String get tipSameNetworkBody =>
      'Phone and hub must be on the same Wi-Fi. Turn mobile data off.';

  @override
  String get tipAddressChangedTitle => 'The address changed';

  @override
  String get tipAddressChangedBody =>
      'Hubs can get a new address after a restart. Check it in your router\'s app, and reserve it there so it stays the same.';

  @override
  String get tipRightPortTitle => 'The right port';

  @override
  String get tipRightPortBody =>
      'MQTT is usually 1883 (8883 with TLS). 8080 or 80 is the hub\'s web page, not MQTT.';

  @override
  String get tipStartBrokerTitle => 'The broker is running';

  @override
  String get tipStartBrokerBody =>
      'Start Mosquitto or the broker add-on, then try again.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 only accepts connections from the hub itself until it\'s set to listen on the network (port 1883).';

  @override
  String get tipMqttLoginTitle => 'The MQTT login, not the web login';

  @override
  String get tipMqttLoginBody =>
      'Your hub\'s web page password is usually not the MQTT one. Home Assistant: use a Home Assistant user, or the login set in the Mosquitto add-on.';

  @override
  String get tipSpacesTitle => 'Check for spaces';

  @override
  String get tipSpacesBody => 'Copying a password can add a space at the end.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT uses this broker';

  @override
  String get tipZ2mBrokerBody =>
      'In Zigbee2MQTT\'s settings, check that its MQTT server is this same broker.';

  @override
  String get tipBaseTopicTitle => 'Base topic';

  @override
  String get tipBaseTopicBody =>
      'If you changed the base topic from \"zigbee2mqtt\", enter it in manual setup.';

  @override
  String get tipPairFirstTitle => 'Pair devices first';

  @override
  String get tipPairFirstBody =>
      'Open Zigbee2MQTT\'s web page and pair at least one device, then check again.';

  @override
  String get tipRestartZ2mTitle => 'Restart Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'If devices are paired but none arrive, restart Zigbee2MQTT so it publishes its device list.';

  @override
  String get tipNumberAddressTitle => 'Use the number address';

  @override
  String get tipNumberAddressBody =>
      'Names ending in .local don\'t work on every Android phone. Try the hub\'s number address, like 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port and protocol';

  @override
  String get tipPortProtocolBody =>
      'TCP on 1883 is the usual. Pick TLS or WebSocket only if your broker is set up for it.';

  @override
  String get tipManualLoginTitle => 'Login';

  @override
  String get tipManualLoginBody =>
      'Leave username and password empty if your broker has none. Otherwise use the MQTT login, not the hub\'s web login.';

  @override
  String get tipHubOnTitle => 'Is the hub on?';

  @override
  String get tipHubOnBody =>
      'A power cut or update may have restarted it. Give it a minute after it comes back.';

  @override
  String get tipAwayTitle => 'Are you at home?';

  @override
  String get tipAwayBody =>
      'Away from home, the app needs a remote address (for example Tailscale). Set it in the home\'s connection settings.';

  @override
  String get tipHomeAddressChangedTitle => 'Did the address change?';

  @override
  String get tipHomeAddressChangedBody =>
      'After a router restart the hub may get a new address. Reserve its address in your router\'s app, then update the home.';

  @override
  String get tipRestartZ2mButtonTitle => 'Restart Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'If the broker restarted, Zigbee2MQTT\'s device list is gone until Zigbee2MQTT restarts. Use the Restart Zigbee2MQTT button on the Devices tab.';

  @override
  String get tipZ2mRunningTitle => 'Is Zigbee2MQTT running?';

  @override
  String get tipZ2mRunningBody =>
      'Open its web page. If it doesn\'t load, restart it on your hub.';

  @override
  String get tipCantConnectTitle => 'Can\'t connect to my hub';

  @override
  String get tipCantConnectBody =>
      'Same Wi-Fi, broker running, Allow External or Mosquitto listening on the network, then connect by address.';

  @override
  String get tipDeviceWrongTitle => 'A device shows wrong or doesn\'t respond';

  @override
  String get tipDeviceWrongBody =>
      'Check it in Zigbee2MQTT\'s web page first. If it works there, use Report a problem.';

  @override
  String get tipHowDoITitle => 'How do I…';

  @override
  String get tipHowDoIBody =>
      'Scenes, Wall display, schedules and backups are in Help & Guide.';

  @override
  String get tipWhatYouNeedTitle => 'What you need';

  @override
  String get tipWhatYouNeedBody =>
      'An MQTT broker (Mosquitto) and Zigbee2MQTT running on a hub: Home Assistant, a Raspberry Pi, or an SMLIGHT hub.';

  @override
  String get tipSetupAtHomeTitle => 'On the same Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Set up at home, with your phone on the same Wi-Fi as the hub.';

  @override
  String get tipFindSetupTitle => 'Then';

  @override
  String get tipFindSetupBody =>
      'Leave the demo and tap Find my setup. ZigDash looks for your hub on its own.';
}
