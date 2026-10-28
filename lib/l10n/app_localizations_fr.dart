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
  String get connUsername => 'Nom d\'utilisateur';

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
  String get dashFormLock => 'Verrou d\'édition';

  @override
  String get dashFormLockSubtitle => 'Masque Modifier pour ce tableau de bord';

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
      'Que s\'est-il passé, et qu\'attendiez-vous ?';

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
  String get scenesAllShutters => 'Tous les volets';

  @override
  String get sceneCloseAllShutters => 'Fermer tous les volets';

  @override
  String get sceneOpenAllShutters => 'Ouvrir tous les volets';

  @override
  String get sceneStopAllShutters => 'Arrêter tous les volets';

  @override
  String sceneShuttersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volets',
      one: '1 volet',
    );
    return '$_temp0';
  }

  @override
  String get sceneWhichShutters => 'Quels volets…';

  @override
  String get sceneWhichShuttersHint =>
      'Tous les volets de cette maison sont inclus. Décochez ceux qui doivent rester à l’écart, comme une porte de garage.';

  @override
  String get scenesYours => 'Vos scènes';

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
      'Le broker n\'a pas accepté la connexion. Vérifiez que votre broker MQTT (généralement Mosquitto) est lancé et accepte les connexions des autres appareils, et que l\'adresse et le port (généralement 1883) sont corrects.';

  @override
  String get diagTcpTimeout =>
      'La connexion au broker a expiré. Il est peut-être hors ligne ou injoignable.';

  @override
  String get diagConnackFail =>
      'Le broker n\'a pas terminé la négociation MQTT. Vérifiez qu\'il s\'agit bien d\'un broker MQTT (Mosquitto, Zigbee2MQTT).';

  @override
  String get diagLoginNoAnswer =>
      'Le broker n\'a pas répondu à la connexion à temps. Home Assistant peut mettre quelques secondes à la vérifier, réessayez.';

  @override
  String get diagAuthRejected =>
      'Le broker a refusé le nom d\'utilisateur ou le mot de passe. Vérifiez vos identifiants.';

  @override
  String get diagAuthRefused =>
      'Le broker a refusé la connexion. Vérifiez les paramètres de connexion.';

  @override
  String get diagResolveLocalName =>
      'Votre téléphone n\'a pas trouvé ce nom. Android ne résout souvent pas les noms en .local : saisissez plutôt l\'adresse IP (Home Assistant l\'affiche dans Paramètres › Système › Réseau).';

  @override
  String get diagTcpHaNoBroker =>
      'C\'est bien votre Home Assistant, mais aucun broker MQTT n\'y tourne. Installez et démarrez le module complémentaire Mosquitto broker (Paramètres › Modules complémentaires), puis réessayez.';

  @override
  String get diagTcpSmlightClosed =>
      'C\'est bien votre hub SMLIGHT, mais son broker MQTT n\'accepte pas les connexions des autres appareils. Sur la page web du hub, ouvrez Settings › MQTT, activez Allow External, enregistrez, puis réessayez.';

  @override
  String get diagTcpZ2mBrokerElsewhere =>
      'Zigbee2MQTT tourne à cette adresse, mais il joint son broker sous un autre nom (voir Zigbee2MQTT › Settings › MQTT › Server). Si c\'est une autre machine, saisissez son adresse, en général avec le port 1883. Si c\'est un conteneur sur cette machine, publiez son port (ports: \"1883:1883\") et laissez-le écouter sur le réseau, puis réessayez.';

  @override
  String get diagTcpZ2mNoBroker =>
      'Zigbee2MQTT tourne à cette adresse, mais son broker MQTT n\'accepte pas les connexions des autres appareils. Mosquitto n\'écoute que sur sa propre machine tant que vous n\'ajoutez pas les lignes « listener 1883 » et « allow_anonymous true » à mosquitto.conf (ou un mot de passe). Redémarrez Mosquitto, puis réessayez.';

  @override
  String get diagAuthRejectedHa =>
      'Le broker de Home Assistant a refusé cette connexion. Utilisez le nom et le mot de passe d\'un utilisateur Home Assistant (Paramètres › Personnes › Utilisateurs) ; idéalement un utilisateur réservé à MQTT.';

  @override
  String foundDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils trouvés',
      one: '1 appareil trouvé',
    );
    return '$_temp0';
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
  String get guidedStuckTitle => 'Bloqué ? Demandez à quelqu\'un';

  @override
  String get guidedStuckBody =>
      'Deux essais sans connexion. Dites-nous quel hub vous avez et ce que vous avez saisi, et nous vous aidons à le trouver.';

  @override
  String get guidedStuckTelegram => 'Demander sur Telegram';

  @override
  String get guidedStuckHelp => 'Conseils et e-mail';

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
  String get setupWelcomeHeadline => 'Votre maison Zigbee, sur votre mobile';

  @override
  String get setupWelcomeBody =>
      'Un petit hub avec Zigbee2MQTT suffit : un hub SMLIGHT, un Raspberry Pi ou n\'importe quelle machine Linux. Pas besoin de Home Assistant, et si vous l\'avez, ZigDash fonctionne aussi avec. Tout reste en local, sans cloud.';

  @override
  String get setupFindMySetup => 'Trouver mon installation';

  @override
  String get setupErrPageTitle => 'La page Zigbee2MQTT n\'a pas répondu';

  @override
  String get setupErrPageBody =>
      'Aucune page Zigbee2MQTT n\'a répondu à cette adresse. Ouvrez-la dans le navigateur de ce téléphone pour vérifier, et copiez l\'adresse exactement (avec son port, souvent 8080). Si la page demande un jeton, saisissez plutôt les infos de votre broker.';

  @override
  String get setupErrPageAction => 'Réessayer';

  @override
  String get setupLookWider => 'Chercher sur tout le réseau';

  @override
  String get setupAsk => 'Qu\'est-ce qui fait tourner votre Zigbee ?';

  @override
  String get setupAskZ2m => 'Zigbee2MQTT';

  @override
  String get setupAskZ2mSub => 'Sur un Raspberry Pi, un serveur ou Docker';

  @override
  String get setupAskHa => 'Home Assistant';

  @override
  String get setupAskHaSub => 'Avec le module Zigbee2MQTT, ou ZHA';

  @override
  String get setupAskSmlight => 'Un hub SMLIGHT';

  @override
  String get setupAskSmlightSub => 'SLZB ou SMHUB avec Zigbee2MQTT';

  @override
  String get setupAskNothing => 'Rien pour l\'instant ?';

  @override
  String get setupAskHaWhich =>
      'Comment votre Home Assistant gère-t-il Zigbee ?';

  @override
  String get setupAskHaZ2m => 'Le module Zigbee2MQTT';

  @override
  String get setupAskHaZ2mSub => 'Se connecter avec Home Assistant';

  @override
  String get setupAskHaZha => 'ZHA, le Zigbee intégré de Home Assistant';

  @override
  String get setupAskHaZhaSub => 'Zigbee Home Automation, sans Zigbee2MQTT';

  @override
  String get setupZ2mPageEntry => 'Me connecter à ma page Zigbee2MQTT';

  @override
  String get setupManualEntryAdvanced => 'Saisir les infos du broker (avancé)';

  @override
  String get z2mPageTitle => 'Votre page Zigbee2MQTT';

  @override
  String get z2mPageBody =>
      'L\'adresse dans votre navigateur quand la page Zigbee2MQTT est ouverte, celle où vous appairez vos appareils. Aucun identifiant ni mot de passe MQTT nécessaire.';

  @override
  String get z2mPageLabel => 'Adresse de la page';

  @override
  String get z2mPageConnect => 'Se connecter';

  @override
  String z2mPageFoundName(String host, String ip) {
    return '$host trouvé à $ip';
  }

  @override
  String z2mPageNoName(String host) {
    return 'Rien n\'a répondu pour $host sur ce réseau';
  }

  @override
  String get engineNeedsBrokerTitle =>
      'Les automatisations ont besoin de votre broker MQTT';

  @override
  String get engineNeedsBrokerBody =>
      'Ce domicile se connecte par la page Zigbee2MQTT, ce qui suffit pour vos tableaux de bord. Les automatisations, alertes et historique tournent dans le ZigDash Engine sur votre hub, qui passe par votre broker MQTT. Saisissez ses infos une fois, et ZigDash se connectera ensuite par le broker.';

  @override
  String get engineNeedsBrokerButton => 'Saisir les infos du broker';

  @override
  String get connFromPageNote =>
      'Ce domicile se connecte par la page Zigbee2MQTT. Saisissez votre broker MQTT (souvent la même machine, port 1883) pour activer automatisations, alertes et historique. Après l\'enregistrement, ZigDash se connecte par le broker.';

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
  String get reminderButton => 'Me le rappeler demain';

  @override
  String get reminderSet =>
      'Nous vous le rappellerons demain, sur ce téléphone.';

  @override
  String get reminderNoPermission =>
      'Les notifications de ZigDash sont désactivées, il n\'y aura donc pas de rappel. Vous pouvez les activer dans les paramètres d\'Android.';

  @override
  String get reminderChannel => 'Rappel de configuration';

  @override
  String get reminderTitle => 'Terminez la configuration de ZigDash';

  @override
  String get reminderBody =>
      'À la maison sur votre Wi-Fi ? Touchez pour réessayer : cela prend environ une minute.';

  @override
  String get setupWelcomeNoZ2m => 'Pas encore de Zigbee2MQTT ?';

  @override
  String get setupWelcomeDemo => 'Essayer la maison de démo';

  @override
  String get setupWelcomeHubs => 'Quel hub choisir';

  @override
  String get haConnectTitle => 'Se connecter via Home Assistant';

  @override
  String get haConnectIntro =>
      'Votre téléphone n\'atteint pas le broker, mais il atteint Home Assistant. Connectez-vous une fois, et ZigDash parle à Zigbee2MQTT via Home Assistant : à la maison ou ailleurs, sans réglages du broker.';

  @override
  String get haConnectAddressHelp =>
      'L\'adresse avec laquelle vous ouvrez Home Assistant : 192.168.1.20:8123, ou une adresse distante comme votre adresse Nabu Casa ou Cloudflare';

  @override
  String get haConnectSignInHelp =>
      'La page de connexion de Home Assistant s\'ouvre dans votre navigateur. ZigDash ne voit jamais votre mot de passe.';

  @override
  String get haConnectKeeps =>
      'ZigDash conserve cette connexion sur votre téléphone et agit en votre nom dans Home Assistant, pour MQTT uniquement. Mettez-y fin à tout moment dans Home Assistant, sous Profil › Sécurité.';

  @override
  String get haConnectTokenHelp =>
      'Dans Home Assistant, ouvrez votre profil, puis Sécurité › Jetons d\'accès longue durée › Créer un jeton. Copiez-le et collez-le ici. ZigDash le garde sur ce téléphone pour se connecter ; supprimez-le dans Home Assistant quand vous voulez y mettre fin.';

  @override
  String get haConnectWithToken => 'Se connecter avec un jeton';

  @override
  String get haConnectChecking => 'Vérification de Home Assistant…';

  @override
  String get setupStillChecking =>
      'Vérification en cours. Cela peut prendre jusqu\'à 30 secondes.';

  @override
  String get aiHelpTitle => 'Bloqué ? Demandez à votre assistant IA';

  @override
  String get aiHelpBody =>
      'ZigDash résume ce qu\'il a trouvé pour ChatGPT, Claude, Gemini ou toute app d\'IA, sans mots de passe ni adresses. Vous le voyez avant le partage.';

  @override
  String get aiHelpButton => 'Demander à une IA';

  @override
  String get aiHelpPreviewTitle => 'Ce qui sera partagé';

  @override
  String get aiHelpShare => 'Partager vers une app d\'IA';

  @override
  String get aiHelpCopied =>
      'Copié. Collez-le dans n\'importe quel chat d\'IA.';

  @override
  String get haConnectWhereAddress =>
      'Vous ne la connaissez pas ? Dans l\'app Home Assistant, ouvrez Paramètres › Application compagnon et touchez votre serveur : l\'adresse y figure. Sur un ordinateur, c\'est celle qu\'affiche le navigateur quand Home Assistant est ouvert.';

  @override
  String get haFindLooking => 'Recherche de Home Assistant sur ce réseau…';

  @override
  String get haFindSeveral =>
      'Plusieurs Home Assistant trouvés. Touchez celui à utiliser :';

  @override
  String get haFindNone =>
      'Ce téléphone ne voit pas Home Assistant sur ce Wi-Fi. Utilisez l\'adresse qu\'ouvre votre app Home Assistant : souvent une adresse distante, comme https://abcd1234.ui.nabu.casa ou https://maison.duckdns.org.';

  @override
  String haConnectOtherNetwork(String network) {
    return 'Cette adresse est sur un autre réseau que ce téléphone, qui est sur $network. Utilisez l\'adresse qu\'ouvre votre app Home Assistant, souvent une adresse distante, ou connectez le téléphone au réseau de Home Assistant.';
  }

  @override
  String get haConnectLocalNameUnreachable =>
      'Ce téléphone n\'a pas trouvé ce nom : Android ouvre souvent mal les noms en .local. Saisissez l\'adresse IP de Home Assistant (par exemple 192.168.1.20:8123), ou son adresse distante.';

  @override
  String get haConnectRemoteUnreachable =>
      'Rien n\'a répondu à cette adresse distante. Ouvrez-la dans le navigateur de ce téléphone pour vérifier qu\'elle fonctionne, et copiez-la exactement comme votre app Home Assistant l\'affiche.';

  @override
  String get setupNoWifiHa => 'Vous utilisez Home Assistant ? Se connecter';

  @override
  String get haConnectNotAdmin =>
      'Votre utilisateur Home Assistant n\'est pas administrateur. ZigDash en a besoin pour le MQTT de Home Assistant. Connectez-vous en tant qu\'administrateur, ou collez un jeton créé par un administrateur.';

  @override
  String get haConnectNoMqtt =>
      'Ce Home Assistant n\'a pas d\'intégration MQTT. Zigbee2MQTT en a aussi besoin : dans Home Assistant, ajoutez le module complémentaire Mosquitto broker et l\'intégration MQTT, puis réessayez.';

  @override
  String get haConnectSignInFailed =>
      'La connexion ne s\'est pas terminée. Réessayez, ou utilisez un jeton longue durée.';

  @override
  String get setupHaShortcut =>
      'Zigbee2MQTT tourne dans Home Assistant ? Oubliez le broker et son identifiant : connectez-vous avec votre compte administrateur Home Assistant. Ça marche depuis n\'importe quel réseau.';

  @override
  String get haConnectButton => 'Se connecter via Home Assistant';

  @override
  String get haConnectManualLink =>
      'Vous utilisez Home Assistant ? Connectez-vous plutôt via lui';

  @override
  String get haConnectEmptyNote =>
      'Ce téléphone n\'atteint pas le broker ? Home Assistant peut porter la connexion pour vous.';

  @override
  String get haHomeConnected => 'Connecté via Home Assistant';

  @override
  String get haHomeChange =>
      'Si la connexion ne fonctionne plus, sur un nouveau téléphone ou après avoir retiré le jeton dans Home Assistant, reconnectez-vous ici. Vous pouvez aussi y mettre fin dans Home Assistant, sous Profil › Sécurité.';

  @override
  String get haHomeSignInAgain => 'Se reconnecter';

  @override
  String get haHomeRemote => 'Adresse distante de Home Assistant (facultatif)';

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
  String get setupAuthRejectedZ2m =>
      'Zigbee2MQTT se connecte déjà à ce broker : sa page web affiche l\'utilisateur dans Paramètres › MQTT. Utilisez cet utilisateur et son mot de passe.';

  @override
  String get setupAuthWhich =>
      'C\'est l\'identifiant MQTT, pas le mot de passe de la page web de votre hub.';

  @override
  String get setupAuthHintHa =>
      'Home Assistant : utilisez un utilisateur Home Assistant. La plupart en créent un dédié à MQTT dans Paramètres › Personnes › Utilisateurs, et le module Mosquitto l\'accepte.';

  @override
  String get setupAuthHintPi =>
      'Raspberry Pi ou Docker : l\'utilisateur et le mot de passe du fichier de mots de passe de Mosquitto, les mêmes que dans configuration.yaml de Zigbee2MQTT sous mqtt.';

  @override
  String get setupAuthHintSmlight =>
      'SMLIGHT : l\'identifiant affiché sur la page web du hub dans Settings › MQTT.';

  @override
  String get setupVerifyingTitle => 'Vérification de la connexion…';

  @override
  String get setupReviewTitle => 'Vos appareils';

  @override
  String setupReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils trouvés.',
      one: '1 appareil trouvé.',
    );
    return '$_temp0 Choisissez ce qui ira sur votre premier tableau de bord.';
  }

  @override
  String get setupReviewLastStep =>
      'Dernière étape : cochez les appareils voulus, puis touchez Créer le tableau de bord en bas.';

  @override
  String get setupLeaveTitle => 'Créer votre tableau de bord ?';

  @override
  String get setupLeaveBody =>
      'Vos appareils sont trouvés. Créez le tableau de bord maintenant, ou recommencez la configuration et perdez cette liste.';

  @override
  String get setupStartOver => 'Recommencer';

  @override
  String setupCreateWithCount(Object count) {
    return 'Créer le tableau de bord avec $count';
  }

  @override
  String get setupReviewNoneSelected =>
      'Rien n\'est coché pour l\'instant. Cochez les appareils que vous voulez sur le tableau de bord, ou créez-le vide et ajoutez des tuiles plus tard.';

  @override
  String get setupCreateEmpty => 'Créer un tableau de bord vide';

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
  String get setupErrListMissingTitle =>
      'Zigbee2MQTT n\'a pas envoyé sa liste d\'appareils';

  @override
  String get setupErrListMissingBody =>
      'Zigbee2MQTT répond, mais sa liste d\'appareils n\'est pas arrivée. Cela arrive souvent après un redémarrage du broker MQTT : avant la version 2.14.2, Zigbee2MQTT ne renvoie la liste qu\'à son propre redémarrage. Redémarrez Zigbee2MQTT (ou mettez-le à jour), puis réessayez.';

  @override
  String get setupErrListMissingAction => 'Réessayer';

  @override
  String get setupErrHaNoZ2mTitle =>
      'Pas de Zigbee2MQTT dans ce Home Assistant';

  @override
  String get setupErrHaNoZ2mBody =>
      'Vous êtes connecté à Home Assistant, mais Zigbee2MQTT n\'envoie rien sur son MQTT. Si vos appareils Zigbee sont dans ZHA (le Zigbee intégré de Home Assistant), ZigDash ne peut pas les voir : il fonctionne avec Zigbee2MQTT. Si vous utilisez le module complémentaire Zigbee2MQTT, ouvrez-le dans Home Assistant, vérifiez qu\'il est démarré, puis réessayez.';

  @override
  String get setupErrHaNoZ2mAction => 'Réessayer';

  @override
  String get setupErrScanFailedTitle => 'Pas de réseau local';

  @override
  String get setupErrScanFailedBody =>
      'Impossible de déterminer le réseau local de cet appareil. Connectez-vous au Wi-Fi et réessayez.';

  @override
  String get setupErrScanFailedAction => 'Réessayer';

  @override
  String get setupNoWifiTitle => 'Votre téléphone n\'est pas en Wi-Fi';

  @override
  String get setupNoWifiMobileData =>
      'Il utilise les données mobiles, il ne voit donc pas les appareils de la maison. Activez le Wi-Fi et connectez-vous au réseau de la maison : la configuration reprend toute seule.';

  @override
  String get setupNoWifiOffline =>
      'Votre téléphone n\'a aucune connexion réseau. Activez le Wi-Fi et connectez-vous au réseau de la maison : la configuration reprend toute seule.';

  @override
  String get setupNoWifiUnknown =>
      'ZigDash ne trouve pas l\'adresse Wi-Fi de votre téléphone. Vérifiez que le Wi-Fi est activé et connecté au réseau de la maison : la configuration reprend toute seule. Sur un VPN ou hors de chez vous ? Saisissez les informations manuellement.';

  @override
  String get setupOpenWifiSettings => 'Ouvrir les réglages Wi-Fi';

  @override
  String get setupWaitingForWifi => 'En attente du Wi-Fi…';

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
  String get setupErrLoginNoAnswerTitle =>
      'Le broker n\'a pas répondu à la connexion';

  @override
  String get setupErrLoginNoAnswerBody =>
      'Votre broker a été trouvé, mais il n\'a pas répondu à l\'identifiant et au mot de passe à temps. Le module Mosquitto de Home Assistant vérifie les connexions auprès de Home Assistant, ce qui peut prendre quelques secondes sur un Raspberry Pi. Réessayez et vérifiez que cet utilisateur existe dans Home Assistant.';

  @override
  String get setupErrLoginNoAnswerAction => 'Réessayer';

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
  String get setupPlatformQuestion =>
      'Pendant la recherche : où tourne Zigbee2MQTT ?';

  @override
  String get setupPlatformQuestionDone => 'Où tourne Zigbee2MQTT ?';

  @override
  String get setupScanDoneTitle => 'Choisissez une connexion';

  @override
  String get setupScanDoneHint =>
      'Plusieurs brokers ont répondu. Choisissez celui qu\'utilise Zigbee2MQTT.';

  @override
  String get setupPlatformHa => 'Home Assistant';

  @override
  String get setupPlatformSmlight => 'Hub SMLIGHT';

  @override
  String get setupPlatformPi => 'Raspberry Pi ou Docker';

  @override
  String get setupPlatformZha => 'ZHA, pas de Zigbee2MQTT';

  @override
  String get setupZhaNote =>
      'ZigDash affiche les appareils de Zigbee2MQTT ; il ne voit donc pas les appareils de ZHA, le Zigbee intégré de Home Assistant. Essayez la maison de démo pour voir comment fonctionne ZigDash.';

  @override
  String get setupPlatformNotSure => 'Je ne sais pas';

  @override
  String setupScanProgress(int checked, int total) {
    return '$checked adresses sur $total vérifiées';
  }

  @override
  String get setupScanHintHa =>
      'Recherche de Home Assistant et de son broker MQTT…';

  @override
  String get setupScanHintSmlight => 'Recherche de votre hub SMLIGHT…';

  @override
  String get setupScanHintPi => 'Recherche d\'un broker MQTT sur votre réseau…';

  @override
  String setupHubSeenHa(String host) {
    return 'Home Assistant trouvé à l\'adresse $host';
  }

  @override
  String setupHubSeenZ2m(String host) {
    return 'Zigbee2MQTT trouvé à l\'adresse $host';
  }

  @override
  String setupHubSeenSmlight(String host) {
    return 'Votre hub SMLIGHT trouvé à l\'adresse $host';
  }

  @override
  String get setupHubSeenHint => 'Recherche de son broker MQTT en cours…';

  @override
  String get setupNoBrokerHaTitle =>
      'Home Assistant trouvé, mais aucun broker MQTT';

  @override
  String setupNoBrokerHaBody(String host) {
    return 'Home Assistant est à l\'adresse $host, mais rien ne répond sur le port MQTT 1883. Dans Home Assistant, ouvrez Paramètres › Modules complémentaires, installez et démarrez le module Mosquitto broker, puis réessayez.';
  }

  @override
  String get setupNoBrokerHaZha =>
      'Vous utilisez le Zigbee intégré de Home Assistant (ZHA) plutôt que Zigbee2MQTT ? ZigDash ne fonctionne qu\'avec Zigbee2MQTT et ne voit donc pas les appareils ZHA. La démo montre ce que vous obtiendriez.';

  @override
  String get setupVpnHint =>
      'Un VPN est actif et peut masquer votre réseau domestique à la recherche. Si vous êtes chez vous, coupez le VPN et touchez Réessayer. Ou gardez-le et autorisez l\'accès au réseau local (LAN) dans les réglages de l\'app VPN.';

  @override
  String get setupNoBrokerZ2mTitle =>
      'Zigbee2MQTT trouvé, mais son broker est injoignable';

  @override
  String setupNoBrokerZ2mBody(String host) {
    return 'Zigbee2MQTT est à l\'adresse $host, mais son broker MQTT n\'accepte pas les connexions de votre téléphone. Mosquitto 2 n\'écoute que sur le hub lui-même tant que sa configuration ne contient pas \'listener 1883\' et \'allow_anonymous true\' (ou un identifiant). Redémarrez-le, puis réessayez.';
  }

  @override
  String get setupNoBrokerSmlightTitle =>
      'Hub SMLIGHT trouvé, mais MQTT est désactivé';

  @override
  String setupNoBrokerSmlightBody(String host) {
    return 'Votre hub est à l\'adresse $host, mais son broker MQTT est injoignable. Dans l\'interface web du hub, ouvrez Settings › MQTT, activez Allow External et vérifiez que Zigbee2MQTT fonctionne. Puis réessayez.';
  }

  @override
  String get setupZ2mAsking =>
      'On demande à Zigbee2MQTT où se trouve son broker…';

  @override
  String get setupZ2mLocalOnlyTitle =>
      'Votre broker n\'accepte que les connexions de sa propre machine';

  @override
  String setupZ2mLocalOnlyBody(String server) {
    return 'Zigbee2MQTT utilise $server, et rien n\'y répond depuis votre téléphone. Mosquitto 2 fait cela par défaut. Ajoutez ces deux lignes à mosquitto.conf, redémarrez Mosquitto, puis réessayez :';
  }

  @override
  String get setupZ2mLocalOnlyNote =>
      'Vous préférez un identifiant plutôt qu\'un accès ouvert ? Utilisez un password_file au lieu de allow_anonymous.';

  @override
  String get setupZ2mNameOnlyTitle =>
      'Zigbee2MQTT joint son broker par un nom que votre téléphone ne peut pas utiliser';

  @override
  String setupZ2mNameOnlyBody(String server, String name, int port) {
    return 'Zigbee2MQTT utilise $server. « $name » est un nom que seule la machine de Zigbee2MQTT connaît, un service Docker ou un nom d\'hôte. Saisissez plutôt l\'adresse IP de la machine du broker avec le port $port. Si le broker tourne dans un conteneur, son port doit aussi être publié sur la machine (ports: \"$port:$port\").';
  }

  @override
  String get setupZ2mTokenRequired =>
      'La page web de Zigbee2MQTT est protégée par un jeton, l\'application n\'a donc pas pu lire où se trouve son broker. Saisissez l\'adresse du broker indiquée dans Zigbee2MQTT › Settings › MQTT.';

  @override
  String setupZ2mUnreachable(String server) {
    return 'Zigbee2MQTT utilise le broker à $server, mais il n\'a pas répondu à votre téléphone. Vérifiez que le broker tourne et que votre téléphone est sur le même réseau.';
  }

  @override
  String setupConnectTo(String host) {
    return 'Se connecter à $host';
  }

  @override
  String get setupNotFoundHa =>
      'Aucun Home Assistant trouvé sur ce réseau. Vérifiez que votre téléphone est sur le même Wi-Fi que Home Assistant (pas un réseau invité), puis réessayez. Si vous connaissez son adresse, saisissez-la ci-dessous.';

  @override
  String get setupNotFoundSmlight =>
      'Aucun hub SMLIGHT trouvé sur ce réseau. Vérifiez que le hub est allumé et que votre téléphone est sur le même Wi-Fi, puis réessayez. Si vous connaissez son adresse, saisissez-la ci-dessous.';

  @override
  String get setupNotFoundPi =>
      'Aucun broker MQTT trouvé sur ce réseau. Vérifiez que Mosquitto fonctionne et écoute sur le réseau (port 1883) et que votre téléphone est sur le même Wi-Fi. Puis réessayez.';

  @override
  String get setupAddressQuestionHa => 'Où ouvrez-vous Home Assistant ?';

  @override
  String get setupAddressQuestionSmlight =>
      'Quelle est l\'adresse de votre hub SMLIGHT ?';

  @override
  String get setupAddressQuestionPi =>
      'Quelle est l\'adresse de la machine qui fait tourner Mosquitto ?';

  @override
  String get setupAddressQuestionAny =>
      'Quelle est l\'adresse de votre hub, ou de la machine qui fait tourner Zigbee2MQTT ?';

  @override
  String get setupAddressHint =>
      'Une adresse comme 192.168.1.20, un nom, ou le lien de votre navigateur';

  @override
  String get setupAddressCheck => 'Vérifier cette adresse';

  @override
  String setupAddressNothing(String host) {
    return 'Rien n\'a répondu à $host. Vérifiez l\'adresse, et que votre téléphone est sur le même Wi-Fi.';
  }

  @override
  String setupAddressNotResolved(String host) {
    return 'Impossible de résoudre $host. Les noms en .local échouent souvent sur Android ; essayez l\'adresse IP. Home Assistant l\'affiche dans Paramètres › Système › Réseau.';
  }

  @override
  String setupAddressNotResolvedHa(String host, String button) {
    return '$host est introuvable depuis ce téléphone ; Android ne sait souvent pas résoudre les noms en .local. Touchez $button ci-dessus et utilisez l\'adresse avec laquelle vous ouvrez Home Assistant dans le navigateur, ou saisissez ici son adresse IP. Home Assistant l\'affiche dans Paramètres › Système › Réseau.';
  }

  @override
  String setupAddressNotLocal(String host) {
    return '$host n\'est pas sur votre réseau domestique. Utilisez l\'adresse qui fonctionne sur votre Wi-Fi, pas un lien distant comme Nabu Casa ou DuckDNS.';
  }

  @override
  String get setupAddressInvalid => 'Saisissez d\'abord une adresse.';

  @override
  String get setupChoicesTitle => 'Laquelle de ces situations est la vôtre ?';

  @override
  String get setupChoiceNoHub => 'Je n\'ai pas encore de hub';

  @override
  String get setupChoiceNoHubSub =>
      'Voir les petits hubs qui font tourner Zigbee2MQTT';

  @override
  String get setupChoiceHa => 'J\'utilise Home Assistant';

  @override
  String get setupChoiceHaSub => 'Le chercher à homeassistant.local';

  @override
  String get setupChoiceHaNote =>
      'ZigDash se connecte au broker MQTT de Home Assistant, le module Mosquitto broker dans Paramètres › Modules complémentaires, et Zigbee2MQTT doit l\'utiliser aussi. Si homeassistant.local est introuvable, saisissez ci-dessous l\'adresse IP de Home Assistant. Elle se trouve dans Paramètres › Système › Réseau.';

  @override
  String get setupChoiceOther => 'Mon hub est sur un autre réseau';

  @override
  String get setupChoiceOtherSub => 'Un Wi-Fi invité ou un second routeur';

  @override
  String get setupChoiceOtherNote =>
      'Votre téléphone doit pouvoir joindre votre hub. Un Wi-Fi invité, ou un second routeur avec son propre Wi-Fi, les sépare. Connectez-vous au Wi-Fi de votre hub et touchez Réessayer. Ou saisissez ci-dessous l\'adresse IP du hub, ou essayez l\'un de ces noms courants :';

  @override
  String guidedHostYourPhone(String ip, String prefix) {
    return 'Votre téléphone est en $ip, le hub commence donc généralement par $prefix.';
  }

  @override
  String get guidedHostHa =>
      'Vous utilisez Home Assistant ? L\'hôte est l\'adresse avec laquelle vous ouvrez Home Assistant, port 1883.';

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
  String get readingShowAs => 'Afficher comme';

  @override
  String get readingStyleValue => 'Valeur';

  @override
  String get readingStyleGauge => 'Jauge';

  @override
  String get gaugeBands => 'Plages de couleur';

  @override
  String get gaugeBandsHelper =>
      'Jusqu’à trois. La plage où se trouve la valeur colore l’arc.';

  @override
  String get gaugeBandFrom => 'De';

  @override
  String get gaugeBandTo => 'À';

  @override
  String get gaugeBandAdd => 'Ajouter une plage';

  @override
  String get gaugeBandRemove => 'Supprimer la plage';

  @override
  String get gaugeToneNormal => 'Normal';

  @override
  String get gaugeToneGood => 'Bon';

  @override
  String get gaugeToneAttention => 'Attention';

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
      'Données d\'utilisation anonymes. Désactivez-les avec l\'interrupteur ci-dessus.';

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
  String get getHelpTitle => 'Obtenir de l\'aide';

  @override
  String get getHelpTryFirst => 'Essayez d\'abord ceci';

  @override
  String get getHelpPromise =>
      'Toujours bloqué ? Je réponds en général sous 3 jours, en anglais ou en hébreu. Je ne vous demanderai jamais vos mots de passe.';

  @override
  String get getHelpIncluded => 'Ce qui est inclus';

  @override
  String get getHelpContact => 'Contacter le support';

  @override
  String get getHelpCopy => 'Copier les détails';

  @override
  String get getHelpCopied => 'Détails copiés';

  @override
  String get getHelpLink => 'Toujours bloqué ? Obtenir de l\'aide';

  @override
  String get getHelpEmailSubject => 'ZigDash : aide pour le faire fonctionner';

  @override
  String get getHelpEmailPrompt =>
      'Qu\'essayiez-vous de faire, et que s\'est-il passé ?';

  @override
  String get settingsHelpSupport => 'Aide et support';

  @override
  String get settingsGetHelp => 'Obtenir de l\'aide';

  @override
  String get settingsGetHelpSubtitle =>
      'Ça ne marche pas ? D\'abord des conseils, puis le contact';

  @override
  String get settingsCommunity => 'Rejoindre la communauté ZigDash';

  @override
  String get settingsCommunitySubtitle =>
      'Groupe Telegram : questions, idées et nouveautés à venir';

  @override
  String get getHelpCommunity => 'Demander dans le groupe Telegram';

  @override
  String get demoBannerHelp => 'Obtenir de l\'aide';

  @override
  String get tipSameWifiTitle => 'Même Wi-Fi que votre hub';

  @override
  String get tipSameWifiBody =>
      'Votre téléphone doit être sur le même réseau que le hub, pas sur un réseau invité. Coupez les données mobiles pendant la configuration.';

  @override
  String get tipBrokerRunningTitle => 'Le broker est lancé';

  @override
  String get tipBrokerRunningBody =>
      'Home Assistant : le module Mosquitto est démarré. Raspberry Pi : Mosquitto est lancé. SMLIGHT : Settings › MQTT est activé.';

  @override
  String get tipBrokerAcceptsTitle => 'Le broker accepte votre téléphone';

  @override
  String get tipBrokerAcceptsBody =>
      'SMLIGHT : activez Allow External. Mosquitto 2 n\'accepte que les connexions du hub lui-même tant qu\'il n\'est pas réglé pour écouter sur le réseau (port 1883).';

  @override
  String get tipMeshTitle => 'Wi-Fi maillé ou deux routeurs ?';

  @override
  String get tipMeshBody =>
      'Si le hub est branché sur un second routeur, votre téléphone risque de ne pas le voir. Branchez le hub sur le routeur principal, ou connectez-vous par son adresse.';

  @override
  String get tipByAddressTitle => 'Se connecter par l\'adresse';

  @override
  String get tipByAddressBody =>
      'Trouvez l\'adresse du hub dans l\'app de votre routeur, puis appuyez sur « Saisir les détails manuellement ».';

  @override
  String get tipSameNetworkTitle => 'Même réseau';

  @override
  String get tipSameNetworkBody =>
      'Le téléphone et le hub doivent être sur le même Wi-Fi. Coupez les données mobiles.';

  @override
  String get tipAddressChangedTitle => 'L\'adresse a changé';

  @override
  String get tipAddressChangedBody =>
      'Un hub peut obtenir une nouvelle adresse après un redémarrage. Vérifiez-la dans l\'app de votre routeur, et réservez-la pour qu\'elle ne change plus.';

  @override
  String get tipRightPortTitle => 'Le bon port';

  @override
  String get tipRightPortBody =>
      'MQTT utilise en général le 1883 (8883 avec TLS). Le 8080 ou le 80, c\'est l\'interface web du hub, pas MQTT.';

  @override
  String get tipStartBrokerTitle => 'Le broker est lancé';

  @override
  String get tipStartBrokerBody =>
      'Démarrez Mosquitto ou le module du broker, puis réessayez.';

  @override
  String get tipMosquitto2Title => 'Mosquitto 2';

  @override
  String get tipMosquitto2Body =>
      'Mosquitto 2 n\'accepte que les connexions du hub lui-même tant qu\'il n\'est pas réglé pour écouter sur le réseau (port 1883).';

  @override
  String get tipMqttLoginTitle => 'Les identifiants MQTT, pas ceux du web';

  @override
  String get tipMqttLoginBody =>
      'Le mot de passe de l\'interface web de votre hub n\'est généralement pas celui de MQTT. Home Assistant : utilisez un utilisateur Home Assistant, ou les identifiants définis dans le module Mosquitto.';

  @override
  String get tipSpacesTitle => 'Attention aux espaces';

  @override
  String get tipSpacesBody =>
      'Copier un mot de passe peut ajouter un espace à la fin.';

  @override
  String get tipZ2mBrokerTitle => 'Zigbee2MQTT utilise ce broker';

  @override
  String get tipZ2mBrokerBody =>
      'Dans les réglages de Zigbee2MQTT, vérifiez que son serveur MQTT est bien ce broker.';

  @override
  String get tipBaseTopicTitle => 'Topic de base';

  @override
  String get tipBaseTopicBody =>
      'Si vous avez changé le topic de base « zigbee2mqtt », saisissez-le dans la configuration manuelle.';

  @override
  String get tipPairFirstTitle => 'Appairez d\'abord des appareils';

  @override
  String get tipPairFirstBody =>
      'Ouvrez l\'interface web de Zigbee2MQTT, appairez au moins un appareil, puis vérifiez à nouveau.';

  @override
  String get tipRestartZ2mTitle => 'Redémarrer Zigbee2MQTT';

  @override
  String get tipRestartZ2mBody =>
      'Si des appareils sont appairés mais qu\'aucun n\'arrive, redémarrez Zigbee2MQTT pour qu\'il publie sa liste d\'appareils.';

  @override
  String get tipNumberAddressTitle => 'Utilisez l\'adresse en chiffres';

  @override
  String get tipNumberAddressBody =>
      'Les noms en .local ne fonctionnent pas sur tous les téléphones Android. Essayez l\'adresse en chiffres du hub, par exemple 192.168.1.20.';

  @override
  String get tipPortProtocolTitle => 'Port et protocole';

  @override
  String get tipPortProtocolBody =>
      'TCP sur 1883, c\'est le cas habituel. Choisissez TLS ou WebSocket seulement si votre broker est configuré pour.';

  @override
  String get tipManualLoginTitle => 'Identifiants';

  @override
  String get tipManualLoginBody =>
      'Laissez le nom d\'utilisateur et le mot de passe vides si votre broker n\'en a pas. Sinon, utilisez les identifiants MQTT, pas ceux de l\'interface web du hub.';

  @override
  String get tipHubOnTitle => 'Le hub est-il allumé ?';

  @override
  String get tipHubOnBody =>
      'Une coupure de courant ou une mise à jour l\'a peut-être redémarré. Laissez-lui une minute une fois revenu.';

  @override
  String get tipAwayTitle => 'Êtes-vous chez vous ?';

  @override
  String get tipAwayBody =>
      'Hors de chez vous, l\'app a besoin d\'une adresse distante (par exemple Tailscale). Indiquez-la dans les réglages de connexion de la maison.';

  @override
  String get tipTailscaleIpTitle => 'Utilisez l\'IP Tailscale, pas le nom';

  @override
  String get tipTailscaleIpBody =>
      'Les noms en .ts.net ne sont souvent pas résolus dans les apps. Ouvrez l\'app Tailscale sur le téléphone, vérifiez qu\'elle est connectée, puis utilisez l\'adresse 100.x.y.z du hub comme hôte distant.';

  @override
  String get tipHomeAddressChangedTitle => 'L\'adresse a-t-elle changé ?';

  @override
  String get tipHomeAddressChangedBody =>
      'Après un redémarrage du routeur, le hub peut obtenir une nouvelle adresse. Réservez son adresse dans l\'app de votre routeur, puis mettez à jour la maison.';

  @override
  String get tipRestartZ2mButtonTitle => 'Redémarrer Zigbee2MQTT';

  @override
  String get tipRestartZ2mButtonBody =>
      'Si le broker a redémarré, la liste d\'appareils de Zigbee2MQTT est perdue jusqu\'au redémarrage de Zigbee2MQTT. Utilisez le bouton « Redémarrer Zigbee2MQTT » dans l\'onglet Appareils.';

  @override
  String get tipZ2mRunningTitle => 'Zigbee2MQTT est-il lancé ?';

  @override
  String get tipZ2mRunningBody =>
      'Ouvrez son interface web. Si elle ne se charge pas, redémarrez-le sur votre hub.';

  @override
  String get tipCantConnectTitle => 'Impossible de me connecter à mon hub';

  @override
  String get tipCantConnectBody =>
      'Même Wi-Fi, broker lancé, Allow External activé ou Mosquitto à l\'écoute sur le réseau, puis connexion par l\'adresse.';

  @override
  String get tipDeviceWrongTitle =>
      'Un appareil s\'affiche mal ou ne répond pas';

  @override
  String get tipDeviceWrongBody =>
      'Vérifiez-le d\'abord dans l\'interface web de Zigbee2MQTT. S\'il y fonctionne, utilisez « Signaler un problème ».';

  @override
  String get tipHowDoITitle => 'Comment faire…';

  @override
  String get tipHowDoIBody =>
      'Scènes, Affichage mural, programmations et sauvegardes : tout est dans « Aide et guide ».';

  @override
  String get tipRenameHomeTitle => 'Renommer une maison';

  @override
  String get tipRenameHomeBody =>
      'Une maison nommée d\'après son adresse ? Réglages › Maisons, touchez la maison, puis Nom.';

  @override
  String get tipWhatYouNeedTitle => 'Ce qu\'il vous faut';

  @override
  String get tipWhatYouNeedBody =>
      'Un petit hub avec Zigbee2MQTT et un broker MQTT (Mosquitto) : un hub SMLIGHT, un Raspberry Pi ou n\'importe quelle machine Linux. Home Assistant convient aussi, mais il n\'est pas nécessaire.';

  @override
  String get tipSetupAtHomeTitle => 'Sur le même Wi-Fi';

  @override
  String get tipSetupAtHomeBody =>
      'Faites la configuration chez vous, avec votre téléphone sur le même Wi-Fi que le hub.';

  @override
  String get tipFindSetupTitle => 'Ensuite';

  @override
  String get tipFindSetupBody =>
      'Quittez la démo et appuyez sur « Trouver mon installation ». ZigDash cherche votre hub tout seul.';

  @override
  String getHelpNoEmailApp(Object email) {
    return 'Aucune app de messagerie trouvée. Copiez les informations et écrivez à $email.';
  }

  @override
  String get shortcutWorking => 'en cours…';

  @override
  String get shortcutCantReach => 'Maison injoignable';

  @override
  String get shortcutNotConfirmed => 'Non confirmé';

  @override
  String get shortcutRemoved => 'Supprimé';

  @override
  String get shortcutSceneSent => 'Envoyée';

  @override
  String get shortcutSceneConfirmed => 'Confirmée';

  @override
  String get shortcutChooseDevice => 'Choisir un appareil';

  @override
  String get shortcutChooseScene => 'Choisir une scène';

  @override
  String get shortcutOpenAppFirstScene =>
      'Ouvrez ZigDash et créez d\'abord une scène.';

  @override
  String get shortcutChooseGroup => 'Choisir un groupe';

  @override
  String get shortcutPickDevices => 'Choisir des appareils…';

  @override
  String get shortcutGroupName => 'Nom du groupe';

  @override
  String get shortcutGroupLimit => 'Jusqu\'à 5 appareils et 3 scènes';

  @override
  String get shortcutAddTile => 'Ajouter aux Réglages rapides';

  @override
  String get shortcutAddShortcut => 'Ajouter un raccourci';

  @override
  String get shortcutAddToHome => 'Ajouter à l\'écran d\'accueil';

  @override
  String get shortcutWidgetHowToTitle => 'Ajouter le widget';

  @override
  String get shortcutWidgetHowTo =>
      'Appuyez longuement sur un espace libre de l\'écran d\'accueil, touchez Widgets, trouvez ZigDash et faites glisser le widget voulu.';

  @override
  String shortcutTileReady(Object name, Object slot) {
    return '$name est sur la tuile ZigDash $slot des Réglages rapides';
  }

  @override
  String shortcutTileAlready(Object name, Object slot) {
    return '$name est déjà sur la tuile ZigDash $slot';
  }

  @override
  String get shortcutTileHowToTitle => 'Ajouter la tuile';

  @override
  String shortcutTileHowTo(Object slot) {
    return 'Ouvrez les Réglages rapides (balayez deux fois vers le bas), appuyez sur le crayon pour modifier et faites glisser « ZigDash $slot » parmi vos tuiles.';
  }

  @override
  String shortcutPickTitle(Object slot) {
    return 'Choisir un appareil pour ZigDash $slot';
  }

  @override
  String get shortcutPickEmpty =>
      'Aucun appareil à commander pour l\'instant. Placez d\'abord une lampe, une prise ou un volet sur un tableau de bord.';

  @override
  String get shortcutSlotsFull =>
      'Les 4 tuiles ZigDash sont utilisées. Laquelle doit afficher cet appareil à la place ?';

  @override
  String shortcutSlotLabel(Object slot) {
    return 'ZigDash $slot';
  }

  @override
  String get shortcutSlotEmpty => 'Non utilisée';

  @override
  String get deviceRename => 'Renommer';

  @override
  String get deviceRenameTitle => 'Renommer l\'appareil';

  @override
  String get deviceRenameHint =>
      'Un nom pour la pièce ou l\'appareil, comme Chambre';

  @override
  String deviceRenamed(Object name) {
    return 'Renommé en $name';
  }

  @override
  String deviceRenameFailed(Object reason) {
    return 'Impossible de renommer : $reason';
  }

  @override
  String get deviceRenameNoAnswer => 'Zigbee2MQTT n\'a pas répondu';

  @override
  String get shortcutOpenAppFirst =>
      'Ouvrez ZigDash et placez d\'abord un appareil sur un tableau de bord.';

  @override
  String get pollTitle => 'Que devrait faire ZigDash ensuite ?';

  @override
  String get pollBody =>
      'Choisissez ce que vous utiliseriez le plus. La réponse est envoyée avec vos données d\'utilisation anonymes.';

  @override
  String get pollNotifications => 'Notifications';

  @override
  String get pollHistory => 'Graphiques d\'historique';

  @override
  String get pollKiosk => 'Mode kiosque pour une tablette murale';

  @override
  String get pollGroups => 'Groupes Zigbee';

  @override
  String get pollNotNow => 'Pas maintenant';

  @override
  String get pollThanks => 'Merci ! Cela aide à choisir la suite.';

  @override
  String get whyTitle => 'Qu\'est-ce qui vous a fait essayer ZigDash ?';

  @override
  String get whyBody =>
      'Un appui aide à décider quoi développer. La réponse est envoyée avec vos données d\'utilisation anonymes.';

  @override
  String get whyFaster => 'Plus rapide que mon autre app';

  @override
  String get whyFamily => 'Simple pour la famille';

  @override
  String get whyWallTablet => 'Une tablette murale';

  @override
  String get whyWithoutHa => 'Fonctionne sans Home Assistant';

  @override
  String get whyOther => 'Autre chose';

  @override
  String get whyThanks => 'Merci de nous l\'avoir dit !';

  @override
  String get pollNoAnalytics =>
      'Les données d\'utilisation sont désactivées : rien n\'est envoyé d\'ici. Dites-le-nous plutôt via Proposer une fonction.';

  @override
  String alertLeak(Object name) {
    return '💧 Fuite — $name';
  }

  @override
  String alertLeakCleared(Object name) {
    return '✅ $name est de nouveau sec';
  }

  @override
  String alertSmoke(Object name) {
    return '🔥 Fumée — $name';
  }

  @override
  String alertSmokeCleared(Object name) {
    return '✅ Plus de fumée à $name';
  }

  @override
  String alertOpened(Object name) {
    return '🚪 $name ouvert';
  }

  @override
  String alertBattery(Object name, Object value) {
    return '🔋 Batterie faible — $name, $value %';
  }

  @override
  String get alertTest => 'Notification de test ZigDash';

  @override
  String get alertsChannel => 'Alertes';

  @override
  String get alertsChannelDescription => 'Fuites et fumée';

  @override
  String get noticesChannel => 'Avis';

  @override
  String get noticesChannelDescription => 'Portes, fenêtres et batteries';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsStatusOn => 'Les alertes sont actives';

  @override
  String get alertsStatusPaused =>
      'Alertes en pause : ZigDash Engine sur votre hub ne se manifeste pas';

  @override
  String get alertsStatusNotSetUp => 'Non configuré';

  @override
  String get alertsStatusPhoneOff =>
      'Ce téléphone ne reçoit pas de notifications';

  @override
  String get alertsIntro =>
      'Recevez une notification sur ce téléphone en cas de fuite, fumée, porte ouverte ou batterie faible, même ZigDash fermé. ZigDash Engine sur votre hub surveille les appareils ; ZigDash l\'installe.';

  @override
  String get alertsSetUpHub => 'Configurer les alertes sur le hub';

  @override
  String get alertsHubInstalled => 'Les alertes sont en place sur votre hub';

  @override
  String get alertsHubUpdated => 'Le flux d\'alertes du hub est à jour';

  @override
  String get alertsHubNeedsLogin =>
      'Node-RED demande une connexion : importez le flux à la main :';

  @override
  String get alertsHubManualSteps =>
      'Ouvrez Node-RED sur le hub, choisissez Importer, collez le flux copié, choisissez votre broker dans le nœud broker, puis Déployer.';

  @override
  String get alertsCopyFlow => 'Copier le flux';

  @override
  String get alertsFlowCopied => 'Flux copié';

  @override
  String alertsNoNodeRed(Object host) {
    return 'Les alertes ont besoin de Node-RED sur le hub, et rien ne répond sur le port 1880 de $host. Sur un SMLIGHT SMHUB, installez-le dans Apps.';
  }

  @override
  String get alertsHubFailed => 'Zigbee2MQTT n\'a pas accepté ZigDash Engine';

  @override
  String get alertsRecent => 'Alertes récentes';

  @override
  String get alertsRecentNone => 'Rien pour l\'instant';

  @override
  String get alertsYourAlerts => 'Vos alertes';

  @override
  String get alertsAdd => 'Ajouter une alerte';

  @override
  String get alertsNotificationsOnThisPhone => 'Notifications sur ce téléphone';

  @override
  String get alertsNoGoogle =>
      'Ce téléphone n\'a pas les services Google : ZigDash ne peut pas recevoir de push ici.';

  @override
  String get alertsSendTest => 'Envoyer une notification de test';

  @override
  String get alertsTestSent => 'Test envoyé. Il devrait arriver maintenant.';

  @override
  String alertsTestFailed(Object status) {
    return 'Le hub n\'a pas pu l\'envoyer ($status)';
  }

  @override
  String get alertsTestTimedOut =>
      'Pas de réponse du hub. Le flux d\'alertes tourne-t-il ?';

  @override
  String get alertsNotConnected => 'Pas connecté au hub';

  @override
  String get alertsTurnOff => 'Désactiver les alertes';

  @override
  String get alertsTurnOffBody =>
      'Les alertes s\'arrêtent pour tous les téléphones de cette maison.';

  @override
  String get alertKindLeak => 'Fuite';

  @override
  String get alertKindSmoke => 'Fumée';

  @override
  String get alertKindOpened => 'Porte ou fenêtre ouverte';

  @override
  String get alertKindBattery => 'Batterie faible';

  @override
  String get alertsEditTitle => 'Alerte';

  @override
  String get alertsKind => 'Quoi';

  @override
  String get alertsDevices => 'Appareils';

  @override
  String get alertsNoDevicesForKind =>
      'Aucun appareil de cette maison ne signale cela.';

  @override
  String get alertsHours => 'Seulement entre';

  @override
  String get alertsHoursAny => 'À toute heure';

  @override
  String get alertsHoursFrom => 'De';

  @override
  String get alertsHoursTo => 'À';

  @override
  String get alertsThreshold => 'Batterie sous';

  @override
  String get alertsDelete => 'Supprimer l\'alerte';

  @override
  String get alertsNotifyMe => 'Me prévenir…';

  @override
  String get alertsWhatLeaves =>
      'Les alertes vers ZigDash sont chiffrées de bout en bout : le service push de Google les transporte sans pouvoir les lire. Rien d\'autre ne quitte votre hub.';

  @override
  String get alertsRestricted =>
      'Android peut arrêter ZigDash en arrière-plan, et les notifications arriveraient en retard ou pas du tout. Autorisez l\'exécution en arrière-plan dans les réglages Android (sur Samsung : Batterie › Applis jamais en veille).';

  @override
  String get alertsOpenSettings => 'Ouvrir les réglages Android';

  @override
  String get alertsOff => 'Désactivée';

  @override
  String get alertsSuggested => 'Alertes suggérées';

  @override
  String alertsSuggestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils',
      one: '1 appareil',
    );
    return '$_temp0';
  }

  @override
  String get alertsTurnOn => 'Activer';

  @override
  String get alertsShare => 'Partager les alertes';

  @override
  String get alertsShareBody =>
      'Quiconque a ce lien reçoit les alertes de cette maison dans l\'app ntfy, sans ZigDash. Le texte de l\'alerte passe par ntfy.sh sans chiffrement.';

  @override
  String get alertsShareLink => 'Lien';

  @override
  String get alertsShareNewLink => 'Nouveau lien';

  @override
  String get alertsShareCopied => 'Lien copié';

  @override
  String get alertsShareOff => 'Arrêter le partage';

  @override
  String get alertsGetWithNtfy => 'Recevoir les notifications avec ntfy';

  @override
  String get alertsPushover => 'Pushover';

  @override
  String get alertsPushoverBody =>
      'Les alertes fumée et fuite se répètent jusqu\'à confirmation. Nécessite un compte Pushover (4,99 \$ une fois après l\'essai) ; ses clés restent sur votre broker.';

  @override
  String get alertsPushoverUser => 'Clé utilisateur';

  @override
  String get alertsPushoverToken => 'Jeton d\'app';

  @override
  String get alertsHideNames => 'Masquer les noms des appareils';

  @override
  String get alertsNtfyServer => 'Serveur ntfy';

  @override
  String get wallSheetTitle => 'Affichage mural';

  @override
  String get wallSheetSubtitle => 'Pour une tablette au mur.';

  @override
  String get wallKeepOn => 'Garder l\'écran allumé et masquer les barres';

  @override
  String get wallKeepOnSubtitle =>
      'Elles reviennent au toucher et disparaissent de nouveau après 10 secondes.';

  @override
  String get wallFullscreen => 'Plein écran';

  @override
  String get wallFullscreenSubtitle =>
      'Masque aussi les barres d\'état et de navigation d\'Android.';

  @override
  String get wallDimAfter => 'Atténuer après';

  @override
  String get wallDimOff => 'Non';

  @override
  String get wallIdleTitle => 'Quand personne n\'y touche';

  @override
  String get wallIdleAfter => 'Après';

  @override
  String get wallIdleNever => 'Jamais';

  @override
  String get wallIdleShow => 'Afficher';

  @override
  String get wallIdleShowDim => 'Assombri';

  @override
  String get wallIdleShowClock => 'Horloge';

  @override
  String get wallIdleShowBlack => 'Noir';

  @override
  String get wallIdleShowReadings => 'Mesures';

  @override
  String get proBadge => 'Pro';

  @override
  String get wallIdleReadingsNone =>
      'Ce tableau de bord n\'a pas encore de mesures. Ajoutez d\'abord une tuile de mesure ou de capteur.';

  @override
  String wallIdleReadingsPick(int count) {
    return 'Mesures sur l\'horloge (jusqu\'à $count)';
  }

  @override
  String get wallProNote =>
      'Les mesures sur l\'horloge, le réveil par mouvement, le mode nuit et les alarmes font partie de ZigDash Pro, un achat unique.';

  @override
  String get wallAlarmLeak => 'Fuite d\'eau';

  @override
  String get wallAlarmSmoke => 'Fumée';

  @override
  String get wallAlarmGas => 'Gaz';

  @override
  String get wallAlarmCo => 'Monoxyde de carbone';

  @override
  String get wallAlarmOk => 'OK';

  @override
  String get wallMotionTitle => 'Réveil par mouvement';

  @override
  String get wallMotionSubtitle =>
      'Un capteur qui détecte quelqu\'un réveille l\'écran.';

  @override
  String get wallMotionNone =>
      'Aucun capteur de mouvement, de présence ou de porte dans ce domicile.';

  @override
  String get wallAlarmsTitle => 'Les alarmes prennent tout l\'écran';

  @override
  String get wallAlarmsSubtitle =>
      'Une fuite, de la fumée, du gaz ou du monoxyde de carbone remplit l\'écran jusqu\'à ce que quelqu\'un touche OK. Uniquement quand ZigDash est ouvert sur cette tablette ; les alertes atteignent les téléphones partout.';

  @override
  String get wallAlarmSound => 'Jouer un son';

  @override
  String get wallNightTitle => 'Nuit';

  @override
  String get wallNightSubtitle =>
      'Noir entre ces heures. Un mouvement ne l\'allume que faiblement ; les alarmes toujours en plein.';

  @override
  String get wallNightFrom => 'De';

  @override
  String get wallNightTo => 'à';

  @override
  String wallDimMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get kioskLock => 'Verrou kiosque';

  @override
  String get kioskLockSubtitle =>
      'Seuls les tableaux de bord de cette maison et leurs commandes restent accessibles. Appui long sur le titre pour quitter.';

  @override
  String get kioskPin => 'Code PIN';

  @override
  String get kioskPinSet => 'Définir';

  @override
  String get kioskPinNotSet => 'Non défini';

  @override
  String get kioskPinChange => 'Modifier';

  @override
  String get kioskPinRemove => 'Supprimer';

  @override
  String get kioskPinSetTitle => 'Définir un code PIN';

  @override
  String get kioskPinEnterTitle => 'Saisir le code PIN';

  @override
  String get kioskPinHint => '4 chiffres';

  @override
  String get kioskPinConfirmHint => 'Encore';

  @override
  String get kioskPinMismatch => 'Les deux codes diffèrent.';

  @override
  String get kioskPinWrong => 'Code PIN incorrect.';

  @override
  String get kioskPinForgot => 'Code PIN oublié ?';

  @override
  String get kioskPinForgotBody =>
      'Un code PIN oublié ne peut être réinitialisé qu\'en effaçant les données de ZigDash dans les réglages d\'Android, ce qui supprime cette maison sauf si vous avez une sauvegarde. Exportez-en une avant de définir un code.';

  @override
  String get kioskExportBackup => 'Exporter une sauvegarde';

  @override
  String get kioskOsPin => 'Épingler aussi ZigDash dans Android';

  @override
  String get kioskOsPinSubtitle =>
      'Android bloque Accueil et les applications récentes jusqu\'à ce que ZigDash soit désépinglé. Une tablette sans écran de verrouillage se désépingle d\'un geste : ce n\'est donc pas le verrou.';

  @override
  String get kioskOn => 'Kiosque activé. Appui long sur le titre pour quitter.';

  @override
  String get kioskLeaveTitle => 'Quitter le kiosque ?';

  @override
  String get kioskLeave => 'Quitter';

  @override
  String get kioskStay => 'Rester';

  @override
  String get a11yKioskLeave => 'Appui long pour quitter le kiosque';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyRangeDay => '24 heures';

  @override
  String get historyRangeWeek => '7 jours';

  @override
  String get historyRangeMonth => '30 jours';

  @override
  String get historySetupTitle => 'Enregistrer l\'historique sur votre hub';

  @override
  String get historySetupBody =>
      'ZigDash n\'a pas de serveur : ZigDash Engine sur votre hub enregistre les valeurs de vos tableaux de bord toutes les 15 minutes. Il garde 30 jours, sur votre propre broker.';

  @override
  String get historySetupAction => 'Installer sur le hub';

  @override
  String get historyInstalled =>
      'Enregistrement lancé. Les premières valeurs arrivent sous 15 minutes.';

  @override
  String historyNoNodeRed(String host) {
    return 'L\'historique a besoin de Node-RED sur le hub, et rien ne répond sur le port 1880 de $host. Sur un SMLIGHT SMHUB, installez-le dans Apps.';
  }

  @override
  String historyRecordingSince(String date) {
    return 'Enregistré depuis le $date';
  }

  @override
  String get historyEmpty =>
      'Pas encore de valeurs. L\'enregistreur sauvegarde toutes les 15 minutes.';

  @override
  String get historyRecorderOffline =>
      'L\'enregistreur du hub ne répond pas, des valeurs récentes peuvent manquer.';

  @override
  String get historyLocked =>
      'L\'historique plus long fait partie de ZigDash Pro, un achat unique.';

  @override
  String get historyUnlock => 'Débloquer';

  @override
  String get proTitle => 'ZigDash Pro';

  @override
  String get proAbout =>
      'Automatisations illimitées, historique plus long et extras pour la tablette murale. Soutient le projet open source.';

  @override
  String get proUnlocked => 'Débloqué. Merci de soutenir ZigDash.';

  @override
  String get proScreenIntro =>
      'ZigDash est gratuit et open source, créé par une seule personne sur son temps libre. Pro est un achat unique qui le fait vivre.';

  @override
  String get proWhatYouGet => 'Ce que vous obtenez';

  @override
  String get proGetHistory =>
      'L\'historique sur 7 et 30 jours, pas seulement aujourd\'hui';

  @override
  String get proGetWall =>
      'Tablette murale : mesures sur l\'horloge, réveil au mouvement, horaire de nuit et alarmes';

  @override
  String get proGetFuture =>
      'Toutes les fonctions Pro à venir, sans supplément';

  @override
  String get proFreeTitle => 'Gratuit pour toujours';

  @override
  String get proFreeBody =>
      'La configuration, les tableaux de bord, le contrôle de chaque appareil, les widgets, les tuiles des réglages rapides, les alertes, trois automatisations par domicile et la tablette murale elle-même restent gratuits. Rien de ce que vous utilisez aujourd\'hui ne sera verrouillé.';

  @override
  String get proBuy => 'Obtenir Pro';

  @override
  String proBuyPrice(String price) {
    return 'Obtenir Pro · $price';
  }

  @override
  String get proOnce =>
      'Un seul paiement, sans abonnement. Acheté sur un autre téléphone avec le même compte Google ? Il se débloque automatiquement.';

  @override
  String get historyNotRecorded =>
      'Seules les valeurs affichées sur un tableau de bord sont enregistrées. Ajoutez celle-ci en tuile pour démarrer son historique.';

  @override
  String get historyRecordHere => 'Enregistrer sur cet appareil';

  @override
  String get historyRecordHereHint =>
      'Impossible d\'utiliser ZigDash Engine sur votre hub ? ZigDash peut enregistrer sur un téléphone ou une tablette qui reste ouvert, comme une tablette murale. Tous les téléphones de ce domicile voient l\'historique.';

  @override
  String get historyRecordingHere =>
      'Cet appareil enregistre l\'historique tant que ZigDash est ouvert. Les premières valeurs apparaissent sous 15 minutes.';

  @override
  String get wallRecordHistory => 'Enregistrer l\'historique sur cet appareil';

  @override
  String get wallRecordHistorySubtitle =>
      'Toutes les 15 minutes tant que ZigDash est ouvert, pour tous les téléphones de ce domicile. Inutile si ZigDash Engine enregistre sur votre hub.';

  @override
  String historyNeedsPassword(String host) {
    return 'Encore une étape : votre broker demande un identifiant. Ouvrez Node-RED sur $host:1880, double-cliquez sur « ZigDash history broker », saisissez le mot de passe MQTT dans l\'onglet Security, puis Deploy. ZigDash n\'envoie jamais votre mot de passe au hub.';
  }

  @override
  String get historyNotConnected =>
      'L\'enregistrement ne se manifeste pas. Ouvrez Automatisations pour vérifier ZigDash Engine sur votre hub.';

  @override
  String get historyPersistence =>
      'L\'historique est stocké sur votre broker. Si vous gérez Mosquitto vous-même, vérifiez que sa configuration contient \"persistence true\", sinon l\'historique est perdu au redémarrage du broker.';

  @override
  String get haImportTitle => 'Importer depuis Home Assistant';

  @override
  String get haImportSettingsSubtitle =>
      'Noms et pièces définis dans Home Assistant';

  @override
  String get haImportIntro =>
      'Récupérez les noms et les pièces définis dans Home Assistant. ZigDash les lit une fois et ne garde rien d\'autre de Home Assistant.';

  @override
  String get haImportAddress => 'Adresse de Home Assistant';

  @override
  String get haImportAddressHelp =>
      'L\'adresse avec laquelle vous ouvrez Home Assistant, par exemple 192.168.1.20:8123';

  @override
  String get haImportToken => 'Jeton d\'accès longue durée';

  @override
  String get haImportTokenHelp =>
      'Dans Home Assistant, ouvrez votre profil, puis Sécurité › Jetons d\'accès longue durée › Créer un jeton. Copiez-le et collez-le ici. ZigDash l\'utilise une fois et ne le garde pas ; vous pouvez ensuite le supprimer dans Home Assistant.';

  @override
  String get haImportRead => 'Lire depuis Home Assistant';

  @override
  String get haImportReading => 'Lecture de Home Assistant…';

  @override
  String get haImportApplying => 'Importation…';

  @override
  String get haImportNoAddress =>
      'Saisissez l\'adresse avec laquelle vous ouvrez Home Assistant.';

  @override
  String get haImportNoToken => 'Collez un jeton d\'accès longue durée.';

  @override
  String get haImportUnreachable =>
      'Rien n\'a répondu à cette adresse. Vérifiez-la, et que votre téléphone est sur le réseau de la maison.';

  @override
  String get haImportNotHa =>
      'Quelque chose a répondu à cette adresse, mais ce n\'est pas Home Assistant.';

  @override
  String get haImportBadToken =>
      'Home Assistant a refusé ce jeton. Créez-en un nouveau et collez-le à nouveau.';

  @override
  String get haImportCertificate =>
      'Votre téléphone ne fait pas confiance au certificat de ce Home Assistant. Essayez son adresse http:// sur le réseau de la maison.';

  @override
  String get haImportFailed =>
      'Home Assistant a répondu, mais la lecture a échoué. Réessayez.';

  @override
  String get haImportNoDevices =>
      'ZigDash ne voit pas les appareils de cette maison pour l\'instant. Connectez-vous à la maison, puis réessayez.';

  @override
  String get haImportAutomations =>
      'Vos automatisations restent dans Home Assistant et continuent de tourner.';

  @override
  String haImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils trouvés dans Home Assistant',
      one: '1 appareil trouvé dans Home Assistant',
    );
    return '$_temp0';
  }

  @override
  String get haImportRenameNote =>
      'Les tuiles qui portent encore le nom de leur appareil prennent le nom de Home Assistant. Vos tableaux de bord restent tels quels.';

  @override
  String get haImportMakeDashboards =>
      'Ajouter aussi des tableaux de bord par étage et par pièce';

  @override
  String get haImportOtherRooms => 'Autres pièces';

  @override
  String get haImportNoRoom => 'Sans pièce';

  @override
  String get haImportApply => 'Importer';

  @override
  String get haImportBack => 'Retour';

  @override
  String get haImportZhaOnly =>
      'Ces appareils utilisent ZHA, le Zigbee intégré de Home Assistant, et non Zigbee2MQTT : ZigDash ne peut pas les afficher.';

  @override
  String get haImportNothing =>
      'Aucun des appareils Zigbee2MQTT de cette maison n\'est dans Home Assistant.';

  @override
  String haImportDone(int renamed, int dashboards) {
    return 'Terminé. Tuiles renommées : $renamed. Tableaux de bord ajoutés : $dashboards.';
  }

  @override
  String get haImportOpen => 'Ouvrir les tableaux de bord';

  @override
  String get haImportOfferTitle =>
      'Récupérer vos noms et pièces depuis Home Assistant ?';

  @override
  String get haImportOfferBody =>
      'Home Assistant est sur votre réseau. ZigDash peut nommer vos tuiles et ajouter un tableau de bord par étage et par pièce, comme vous les avez définis là-bas.';

  @override
  String get haImportOfferLater => 'Pas maintenant';

  @override
  String get haImportOfferGo => 'Importer';

  @override
  String get haImportSignIn => 'Se connecter avec Home Assistant';

  @override
  String get haImportSignInHelp =>
      'La connexion de Home Assistant s\'ouvre dans votre navigateur. ZigDash ne voit jamais votre mot de passe et se déconnecte après la lecture.';

  @override
  String get haImportOrToken => 'Ou utiliser un jeton d\'accès longue durée';

  @override
  String get haImportReadToken => 'Lire avec le jeton';

  @override
  String get haImportSignInRefused =>
      'Home Assistant n\'a pas accepté la connexion. Cela arrive quand Home Assistant n\'a pas accès à internet. Utilisez plutôt un jeton d\'accès longue durée ci-dessous.';

  @override
  String get setupIsolatedHint =>
      'Votre téléphone ne voit presque rien d\'autre sur ce Wi-Fi. Il est peut-être sur un réseau invité, ou le routeur isole les appareils (souvent appelé isolation des clients ou de l\'AP). Rejoignez votre Wi-Fi principal ou désactivez cela, puis réessayez.';

  @override
  String get setupAuthTrust =>
      'Votre identifiant reste sur ce téléphone et ne va qu\'à votre propre broker. ZigDash n\'a ni serveur ni compte, et toute app MQTT se connecte ainsi. Le plus sûr : un utilisateur MQTT dédié à ZigDash, que vous pouvez supprimer à tout moment.';

  @override
  String get setupAuthWhatKept => 'Ce que ZigDash garde';

  @override
  String get setupAuthDemoFirst => 'Essayer d\'abord la démo';

  @override
  String get automationsTitle => 'Automatisations';

  @override
  String get engineRunningOnHub => 'Sur le hub';

  @override
  String get engineChecking => 'Vérification du hub…';

  @override
  String get engineAwayNoHubTitle => 'Votre hub est injoignable pour le moment';

  @override
  String get engineAwayNoHubBody =>
      'Vous êtes absent, et votre hub n\'est pas connecté à l\'accès à distance de ZigDash, ou son internet est coupé. Vos automatisations continuent sur le hub.';

  @override
  String get engineAwayReinstallAtHome =>
      'Vous pourrez réinstaller l\'Engine une fois chez vous.';

  @override
  String get engineNoConnection =>
      'ZigDash ne joint pas le broker de ce domicile pour l\'instant. Les automatisations se configurent connecté, à la maison.';

  @override
  String get engineRestarting =>
      'Redémarrage de Zigbee2MQTT… Vos appareils reviennent dans environ 30 secondes.';

  @override
  String get engineInstalling => 'Installation sur le hub…';

  @override
  String get engineTooOldTitle => 'Zigbee2MQTT doit être mis à jour';

  @override
  String engineTooOldBody(Object version) {
    return 'Votre Zigbee2MQTT est en version $version. Les automatisations demandent la 2.4 ou plus récente. Mettez à jour Zigbee2MQTT sur le hub, puis revenez ici.';
  }

  @override
  String get engineIntroTitle =>
      'Les automatisations tournent sur le hub, pas sur le téléphone';

  @override
  String get engineIntroBody =>
      'ZigDash place ZigDash Engine dans Zigbee2MQTT sur votre hub. Il surveille vos appareils et exécute vos règles : une lumière s\'allume quand la porte s\'ouvre, même téléphone éteint et sans internet.';

  @override
  String get engineIntroNothingByHand =>
      'Rien à installer à la main. ZigDash s\'en charge par le réseau de la maison.';

  @override
  String engineIntroVersion(Object version) {
    return 'Votre Zigbee2MQTT est en version $version.';
  }

  @override
  String get engineIntroRemove =>
      'Vous pouvez le retirer à tout moment depuis cet écran.';

  @override
  String get engineInstall => 'Installer sur le hub';

  @override
  String get engineDeclinedTitle => 'Pas d\'automatisations sur ce hub';

  @override
  String get engineDeclinedBody =>
      'Zigbee2MQTT sur votre hub n\'autorise pas les extensions, donc rien ne peut exécuter vos règles quand le téléphone est absent. Scènes, alertes et tableau de bord fonctionnent comme avant.';

  @override
  String get engineAllowAfterAll => 'Autoriser les extensions finalement';

  @override
  String get engineConsentTitle => 'Zigbee2MQTT doit changer un réglage';

  @override
  String get engineConsentBody =>
      'Votre Zigbee2MQTT bloque les extensions comme ZigDash Engine, comme le font les nouvelles installations. Pour exécuter les automatisations sur le hub, ZigDash activerait « Autoriser le JavaScript externe » dans Zigbee2MQTT et le redémarrerait.';

  @override
  String get engineConsentOutage =>
      'Zigbee2MQTT redémarre une fois. Lumières et capteurs sont injoignables environ 30 secondes.';

  @override
  String get engineConsentOpen =>
      'ZigDash Engine est open source. Vous pouvez le lire sur la page Zigbee2MQTT, sous Extensions.';

  @override
  String get engineConsentUndo =>
      'Vous pourrez désactiver ce réglage plus tard. Les automatisations s\'arrêteront alors.';

  @override
  String get engineConsentYes => 'Changer le réglage et redémarrer';

  @override
  String get engineConsentNo => 'Pas maintenant';

  @override
  String get automationsPausedTitle => 'Automatisations en pause';

  @override
  String get automationsPausedBody =>
      'Votre hub ne s\'est pas manifesté depuis plus d\'une minute, donc aucune automatisation ne peut tourner d\'ici là. Vos règles sont conservées.';

  @override
  String get engineReinstall => 'Réinstaller sur le hub';

  @override
  String get engineStoppedTitle =>
      'Automatisations en pause : ZigDash Engine s\'est arrêté';

  @override
  String get engineStoppedBody =>
      'Il a rencontré des erreurs trois fois en une heure et s\'est coupé pour que Zigbee2MQTT continue de tourner. Vos règles sont conservées.';

  @override
  String get engineStartAgain => 'Redémarrer';

  @override
  String get engineReportProblem => 'Signaler un problème';

  @override
  String get engineRunningTitle =>
      'Votre hub est prêt pour les automatisations';

  @override
  String engineRunningBody(Object count) {
    return 'Règles chargées sur le hub : $count. La création d\'automatisations arrive à l\'étape suivante de cette version.';
  }

  @override
  String get engineClockOff =>
      'L\'horloge de votre hub décale de plus de cinq minutes. Les automatisations horaires se déclencheront à la mauvaise heure jusqu\'à correction.';

  @override
  String engineRulesUnknown(Object count) {
    return 'Règles que ZigDash Engine sur votre hub ne sait pas encore exécuter : $count. Réinstallez-le pour le mettre à jour.';
  }

  @override
  String engineInstallRefused(Object error) {
    return 'Zigbee2MQTT a refusé ZigDash Engine : $error';
  }

  @override
  String get engineInstallNoAnswer =>
      'Zigbee2MQTT n\'a pas répondu. Vérifiez que le domicile est connecté et réessayez.';

  @override
  String get engineConsentFailed =>
      'Zigbee2MQTT n\'a pas accepté le changement ou n\'est pas revenu. Vérifiez le hub et réessayez.';

  @override
  String get autoValMotion => 'mouvement';

  @override
  String get autoValNoMotion => 'pas de mouvement';

  @override
  String get autoValClosed => 'fermé';

  @override
  String get autoValOpened => 'ouvert';

  @override
  String get autoValLeak => 'fuite';

  @override
  String get autoValDry => 'sec';

  @override
  String get autoValSmoke => 'fumée';

  @override
  String get autoValNoSmoke => 'pas de fumée';

  @override
  String get autoValOn => 'allumé';

  @override
  String get autoValOff => 'éteint';

  @override
  String get autoValToggle => 'basculer';

  @override
  String get autoValOpen => 'ouvrir';

  @override
  String get autoValClose => 'fermer';

  @override
  String get autoValStop => 'arrêter';

  @override
  String autoWhenAbove(Object device, Object property, Object value) {
    return 'Quand $device : $property au-dessus de $value';
  }

  @override
  String autoWhenBelow(Object device, Object property, Object value) {
    return 'Quand $device : $property en dessous de $value';
  }

  @override
  String autoWhenDevice(Object device, Object what) {
    return 'Quand $device : $what';
  }

  @override
  String autoAtTime(Object time) {
    return 'À $time';
  }

  @override
  String get autoSunrise => 'lever du soleil';

  @override
  String get autoSunset => 'coucher du soleil';

  @override
  String autoAfterSun(Object minutes, Object sun) {
    return '$minutes min après le $sun';
  }

  @override
  String autoBeforeSun(Object minutes, Object sun) {
    return '$minutes min avant le $sun';
  }

  @override
  String autoAtSun(Object sun) {
    return 'Au $sun';
  }

  @override
  String get autoEveryDay => 'tous les jours';

  @override
  String get autoWeekdays => 'en semaine';

  @override
  String get autoWeekends => 'le week-end';

  @override
  String autoBetween(Object from, Object to) {
    return 'entre $from et $to';
  }

  @override
  String autoDeviceIs(Object device, Object value) {
    return '$device est $value';
  }

  @override
  String autoRunScene(Object scene) {
    return 'Lancer « $scene »';
  }

  @override
  String autoSetDevice(Object device, Object state) {
    return '$device : $state';
  }

  @override
  String autoOffAfter(Object action, Object minutes) {
    return '$action, éteint après $minutes min';
  }

  @override
  String get autoErrPickTrigger => 'Choisissez un appareil et ce qu\'il fait.';

  @override
  String get autoErrValue => 'Saisissez un nombre pour la mesure.';

  @override
  String get autoErrDays => 'Choisissez au moins un jour.';

  @override
  String get autoErrTown =>
      'Indiquez votre ville pour le lever et le coucher du soleil.';

  @override
  String get autoErrPickAction => 'Choisissez ce qui doit se passer.';

  @override
  String get autoErrEmptyScene => 'Cette scène n\'a rien à envoyer.';

  @override
  String get autoErrNotConnected =>
      'ZigDash n\'est pas connecté à ce domicile. Réessayez à la maison.';

  @override
  String get autoNewTitle => 'Nouvelle automatisation';

  @override
  String get autoEditTitle => 'Modifier l\'automatisation';

  @override
  String get autoName => 'Nom';

  @override
  String get autoNameHint => 'Ce qu\'elle fait (facultatif)';

  @override
  String get autoWhen => 'Quand';

  @override
  String get autoOnlyIf => 'Seulement si';

  @override
  String get autoThen => 'Alors';

  @override
  String get autoEnabled => 'Activée';

  @override
  String get autoDelete => 'Supprimer l\'automatisation';

  @override
  String get autoSave => 'Enregistrer';

  @override
  String get autoDeviceChanges => 'Un appareil change';

  @override
  String get autoTimeComes => 'Une heure arrive';

  @override
  String get autoDevice => 'Appareil';

  @override
  String get autoAbove => 'au-dessus de';

  @override
  String get autoBelow => 'en dessous de';

  @override
  String get autoClockTime => 'Heure';

  @override
  String get autoAt => 'À';

  @override
  String get autoShift => 'Décalage en minutes (négatif = avant)';

  @override
  String get autoTownNone => 'Aucune ville';

  @override
  String autoTownIs(Object town) {
    return 'Heures du soleil pour $town';
  }

  @override
  String get autoTownSet => 'Choisir la ville';

  @override
  String get autoTownChange => 'Changer de ville';

  @override
  String get autoDays => 'Jours';

  @override
  String get autoNoConditions =>
      'Aucune condition. Elle s\'exécute à chaque fois.';

  @override
  String get autoAddHours => 'Entre deux heures';

  @override
  String get autoFrom => 'De';

  @override
  String get autoTo => 'À';

  @override
  String get autoAddDeviceCondition => 'Un appareil est…';

  @override
  String get autoRunASceneOption => 'Lancer une scène';

  @override
  String get autoSetADevice => 'Régler un appareil';

  @override
  String get autoScene => 'Scène';

  @override
  String get autoTurnOffAgain => 'Éteindre ensuite';

  @override
  String get autoStaysAsSet => 'Reste ainsi';

  @override
  String autoOffAfterMinutes(Object minutes) {
    return '$minutes minutes après';
  }

  @override
  String get autoTownSearch => 'Ville';

  @override
  String get autoTownWhy =>
      'Sert seulement au lever et au coucher du soleil. Gardée sur votre hub, jamais votre position.';

  @override
  String get autoNewButton => 'Nouvelle automatisation';

  @override
  String get autoEmptyBody =>
      'Rien ne tourne encore. Touchez Nouvelle automatisation pour créer la première.';

  @override
  String autoOnlyIfList(Object list) {
    return 'seulement si $list';
  }

  @override
  String get autoEdit => 'Modifier';

  @override
  String get autoNeverRan => 'jamais exécutée';

  @override
  String autoRanAt(Object time) {
    return 'exécutée à $time';
  }

  @override
  String autoFreeCount(Object count, Object max) {
    return '$count automatisations gratuites sur $max';
  }

  @override
  String get autoRecentRuns => 'Dernières exécutions';

  @override
  String get autoDeleted => '(supprimée)';

  @override
  String autoCeilingTitle(Object count) {
    return '$count automatisations sont gratuites. Envie de plus ?';
  }

  @override
  String get autoCeilingBody =>
      'ZigDash est gratuit et open source, fait par une seule personne. Pro est un achat unique : automatisations illimitées, historique sur 7 et 30 jours et les extras de tablette murale. Vos automatisations continuent quoi que vous choisissiez.';

  @override
  String get autoCeilingSeePro => 'Voir Pro';

  @override
  String get engineRemove => 'Retirer du hub';

  @override
  String get engineRemoveTitle => 'Retirer ZigDash Engine du hub ?';

  @override
  String get engineRemoveBody =>
      'Les automatisations s\'arrêtent. Vos règles restent sur le hub : réinstaller ZigDash Engine les fait revenir.';

  @override
  String get autoNoTargets =>
      'Ce domicile n\'a encore aucune lumière, prise, interrupteur ou volet à commander.';

  @override
  String get proGetAutomations =>
      'Automatisations illimitées ; trois par domicile sont gratuites';

  @override
  String get proGetRemote =>
      'Contrôle à distance de partout, via le relais ZigDash, sans abonnement mensuel';

  @override
  String get proRemoteFair =>
      'L\'accès à distance est inclus tant que le relais ZigDash fonctionne, pour une maison, jusqu\'à cinq téléphones et un usage domestique normal. Il peut changer ou prendre fin avec préavis.';

  @override
  String get autoDeleteConfirm =>
      'Supprimer cette automatisation ? Elle ne tournera plus sur votre hub.';

  @override
  String get statusConnectedRelay => 'Connecté · À distance via ZigDash';

  @override
  String get shareHomeTitle => 'Partager avec un autre téléphone';

  @override
  String get shareHomeSubtitle =>
      'Ajoutez ce domicile à un autre téléphone avec un seul QR code';

  @override
  String get shareHomeIntro =>
      'Sur l\'autre téléphone, à la maison sur le même Wi-Fi, scannez le code avec l\'appareil photo. ZigDash ajoute ce domicile avec ses identifiants et vos tableaux de bord.';

  @override
  String get shareHomeLoginWarning =>
      'Le code contient les identifiants du broker de ce domicile. Il s\'affiche 2 minutes ; ne le montrez qu\'à des personnes de confiance.';

  @override
  String get shareHomeShow => 'Afficher le code';

  @override
  String get shareHomeAtHome =>
      'Connectez-vous d\'abord à la maison : le partage ne marche que sur votre réseau local.';

  @override
  String get shareHomeScanHint =>
      'Scannez avec l\'appareil photo de l\'autre téléphone. Le code disparaît dans 2 minutes.';

  @override
  String get shareHomeHide => 'Masquer le code';

  @override
  String get shareHomeViaHa =>
      'Ce domicile se connecte via Home Assistant. Sur l\'autre téléphone, installez ZigDash et connectez-vous avec Home Assistant.';

  @override
  String get joinHomeTitle => 'Ajouter un domicile partagé';

  @override
  String get joinHomeInvalid =>
      'Ce code n\'est pas une invitation ZigDash, ou il est abîmé.';

  @override
  String joinHomeAlready(String name) {
    return '$name est déjà sur ce téléphone.';
  }

  @override
  String get joinHomeOpen => 'Ouvrir';

  @override
  String joinHomeAsk(String name) {
    return 'Ajouter $name à ce téléphone ?';
  }

  @override
  String get joinHomeBody =>
      'ZigDash ajoute le domicile avec la même connexion et les mêmes identifiants, et reprend les tableaux de bord de l\'autre téléphone. Restez sur le Wi-Fi de la maison.';

  @override
  String get joinHomeAdd => 'Ajouter le domicile';

  @override
  String get joinHomeNoDashboards =>
      'Domicile ajouté. Les tableaux de bord ne sont pas arrivés ; vos appareils sont dans l\'onglet Appareils.';

  @override
  String get remoteTitle => 'Contrôle à distance';

  @override
  String get remoteSettingsSubtitle =>
      'Commandez ce domicile de partout, avec Pro';

  @override
  String get remoteIntroTitle => 'Commandez votre domicile de partout';

  @override
  String get remoteOfferBody =>
      'Accédez à vos appareils quand vous êtes absent, via le relais chiffré de ZigDash. Inclus dans Pro : un seul paiement, sans abonnement mensuel. Configurez-le pendant que vous êtes chez vous.';

  @override
  String get remoteOfferBodyPro =>
      'Vous avez Pro : activez le contrôle à distance pendant que vous êtes chez vous, puis accédez à vos appareils de partout.';

  @override
  String get remoteOfferShow => 'Voir';

  @override
  String get remoteIntroBody =>
      'Votre hub garde une connexion au relais de ZigDash. Hors de chez vous, ce téléphone atteint vos appareils par ce relais. Tout est chiffré sur votre hub et votre téléphone : le relais ne peut lire ni vos appareils ni ce qu\'ils font.';

  @override
  String get remoteNeedsEngine =>
      'Le contrôle à distance tourne dans ZigDash Engine. Installez-le d\'abord dans Automatisations.';

  @override
  String get remoteSetUp => 'Activer le contrôle à distance';

  @override
  String get remoteNeedsPro => 'Le contrôle à distance fait partie de Pro.';

  @override
  String get remoteNotAtHome =>
      'Activez-le chez vous, connecté à votre broker.';

  @override
  String get remoteUnreachable =>
      'Le relais de ZigDash n\'a pas répondu. Réessayez plus tard.';

  @override
  String get remoteRefused =>
      'Le relais a refusé. Réessayez ou signalez un problème.';

  @override
  String get remoteOnTitle => 'Le contrôle à distance est activé';

  @override
  String get remoteOnBody =>
      'Hors de chez vous, ZigDash passe par le relais tout seul.';

  @override
  String get remoteHubOnline => 'Votre hub est connecté au relais';

  @override
  String get remoteHubOffline => 'Votre hub n\'est pas connecté au relais';

  @override
  String get remoteTurnOff => 'Désactiver le contrôle à distance';

  @override
  String get remoteViaRelayNow =>
      'Ce téléphone passe par le relais en ce moment.';

  @override
  String get remotePhones => 'Téléphones avec accès à distance';

  @override
  String get remoteThisPhone => 'Ce téléphone';

  @override
  String get remoteOtherPhone => 'Un autre téléphone';

  @override
  String remotePhoneAdded(Object date) {
    return 'Ajouté le $date';
  }

  @override
  String get remoteRemovePhone => 'Retirer';

  @override
  String get remoteRemovePhoneConfirm =>
      'Retirer ce téléphone ? Il ne pourra plus joindre ce domicile à distance.';

  @override
  String get remoteAddPhone => 'Ajouter un téléphone';

  @override
  String get remoteAddPhoneHint =>
      'À la maison, scannez ceci avec l\'appareil photo de l\'autre téléphone. Il ouvre ZigDash et y active le contrôle à distance. Ne le montrez qu\'à vos propres téléphones.';

  @override
  String get remoteAddPhoneFailed =>
      'Le relais n\'a pas fourni d\'accès pour un autre téléphone. Un domicile peut en avoir cinq.';

  @override
  String get remoteBackupSave => 'Enregistrer une sauvegarde de la clé';

  @override
  String get remoteBackupRestore => 'Restaurer depuis une sauvegarde de la clé';

  @override
  String get remoteBackupPassphrase => 'Phrase secrète de la sauvegarde';

  @override
  String get remoteBackupPassphraseHint =>
      'Si vous perdez ce téléphone, la sauvegarde et cette phrase rétablissent le contrôle à distance sur un nouveau. Au moins 8 caractères, et gardez la phrase ailleurs que le fichier.';

  @override
  String get remoteBackupPassphraseAsk =>
      'La phrase choisie en enregistrant la sauvegarde.';

  @override
  String get remoteBackupPassphraseAgain => 'Phrase secrète à nouveau';

  @override
  String get remoteBackupSaved => 'Sauvegarde de la clé enregistrée';

  @override
  String get remoteBackupWrong => 'Cette phrase n\'ouvre pas cette sauvegarde.';

  @override
  String get remoteBackupWrongFile =>
      'Ce n\'est pas une sauvegarde de clé ZigDash.';

  @override
  String get remotePlayOnly =>
      'Le contrôle à distance est pour l\'instant dans la version Google Play de ZigDash.';

  @override
  String get remotePairTitle => 'Ajouter le contrôle à distance';

  @override
  String get remotePairBody =>
      'Quel domicile est-ce ? ZigDash garde l\'accès à distance pour lui.';

  @override
  String get remotePairNoHomes =>
      'Configurez d\'abord ce domicile sur ce téléphone, à la maison. Puis scannez à nouveau le code.';

  @override
  String get remotePairInvalid =>
      'Ce code n\'est pas un code de contrôle à distance ZigDash, ou il a été coupé.';

  @override
  String remotePairDone(Object home) {
    return 'Contrôle à distance activé pour $home';
  }

  @override
  String get remoteReconnectHub => 'Reconnecter le hub';

  @override
  String get remoteTurnOffConfirm =>
      'Ce téléphone quitte le contrôle à distance et votre hub se déconnecte du relais. Une sauvegarde de clé enregistrée depuis ce téléphone ne fonctionne plus ; les autres téléphones gardent leur accès jusqu\'à ce que vous les retiriez.';

  @override
  String remoteHomeId(Object id) {
    return 'ID de la maison $id';
  }

  @override
  String get alertsHintTitle => 'Soyez prévenu sur ce téléphone';

  @override
  String get alertsHintBody =>
      'Une fuite, de la fumée, une porte ouverte ou une pile faible peuvent envoyer une notification à ce téléphone, même ZigDash fermé.';

  @override
  String get alertsHintButton => 'Configurer les alertes';

  @override
  String get alertsHintNotNow => 'Pas maintenant';

  @override
  String get guidedNoZ2mBody =>
      'Un broker MQTT répond ici, mais Zigbee2MQTT n\'y envoie rien. Vérifiez que Zigbee2MQTT est démarré et utilise ce broker, et que le topic de base correspond à ses réglages. Si vos appareils Zigbee sont dans ZHA de Home Assistant, ZigDash ne peut pas les voir : il fonctionne avec Zigbee2MQTT.';

  @override
  String devicesOtherBaseBody(String found, String current) {
    return 'Zigbee2MQTT est sur ce broker avec le topic de base « $found », mais cette maison cherche « $current ».';
  }

  @override
  String devicesUseBase(String found) {
    return 'Utiliser « $found »';
  }

  @override
  String get devicesChangeConnection => 'Modifier la connexion';

  @override
  String get updateAvailableTitle =>
      'Une nouvelle version de ZigDash est prête';

  @override
  String get updateAvailableBody =>
      'Elle se télécharge pendant que vous utilisez ZigDash.';

  @override
  String get updateAvailableButton => 'Mettre à jour';

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour…';

  @override
  String get updateReadyTitle => 'Mise à jour téléchargée';

  @override
  String get updateReadyButton => 'Redémarrer pour terminer';

  @override
  String get nfcWriteTag => 'Écrire sur un tag NFC';

  @override
  String get nfcHoldTitle => 'Approchez un tag du téléphone';

  @override
  String nfcHoldBody(String name) {
    return 'Approchez un sticker NFC vierge du dos du téléphone. Le toucher ensuite lancera $name.';
  }

  @override
  String get nfcWrittenTitle => 'Tag prêt';

  @override
  String nfcWrittenBody(String name) {
    return 'Touchez ce tag avec le téléphone pour lancer $name. Ça marche même app fermée.';
  }

  @override
  String get nfcFailedTitle => 'Impossible d\'écrire le tag';

  @override
  String get nfcReadonlyBody =>
      'Ce tag est verrouillé et ne peut pas être modifié. Essayez-en un autre.';

  @override
  String get nfcTooSmallBody =>
      'Ce tag est trop petit. Utilisez un sticker NTAG213 ou plus grand.';

  @override
  String get nfcFailedBody =>
      'Tenez le tag immobile contre le dos du téléphone et réessayez.';

  @override
  String get nfcOffTitle => 'Le NFC est désactivé';

  @override
  String get nfcOffBody =>
      'Activez le NFC dans les réglages Android, puis réessayez.';

  @override
  String get nfcNoneTitle => 'Pas de NFC sur ce téléphone';

  @override
  String get nfcNoneBody =>
      'Ce téléphone ne peut pas lire ni écrire de tags NFC.';

  @override
  String get nfcWriteAnother => 'Écrire un autre tag';
}
