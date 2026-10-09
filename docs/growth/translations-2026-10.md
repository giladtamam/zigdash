# Russian, Polish and Portuguese (Brazil): October 2026

Added because Play Console shows Russian as the second-largest user language (8.5%) and Polish and Brazilian Portuguese growing, all without a translation (play-insights-2026-10-06.md). All 605 app strings are machine translated and pass the key, placeholder and plural checks. **None has had a native speaker's review yet.** The word choices below are the ones to check first.

To change wording, edit `lib/l10n/app_ru.arb`, `app_pl.arb` or `app_pt.arb`, then run `tool/flutter gen-l10n`.

## Russian (`app_ru.arb`)

- **Terms:** дашборд (dashboard), плитка (tile), раздел (section), дом (home), брокер, топик, сопряжение (pairing), сцена, показание (reading). Old "panel" strings use панель.
- `deviceClear`: «Нет». Short; «Нет движения» is clearer.
- `deviceLeakDetected`: «Протечка», while smoke and gas use «Обнаружен …». «Обнаружена протечка» would match.
- `connFindBrokers`: «Найти брокеры». Some would write «брокеров».
- `panelStateOn` / `panelStateOff`: ВКЛ / ВЫКЛ. German and French keep ON / OFF.
- `tileSizeFull`: «Во всю ширину». Long for a chip.
- Covers are «Шторы» (`sectionSwitchesCovers` «Выключатели и шторы»).
- `deviceClassContact`: «Контакт». Many users say «Датчик открытия».
- "Payload", "Retain" and "Keep-alive" are left in English.
- `panelFormSubscribeTopicHelper`: the second sentence reads awkwardly.

## Polish (`app_pl.arb`)

- **Terms:** dashboard (loanword, as in Home Assistant), kafelek (tile, also used for old "panel" strings), dom, roleta (cover), temat (topic), zalanie (leak).
- `broker` is declined as an inanimate noun («Dodaj broker»). Polish tech writing often says «Dodaj brokera».
- `deviceLinkGood` / `deviceLinkWeak`: «Dobre» / «Słabe». They should be «Dobra» / «Słaba» if shown next to «Jakość łącza».
- `deviceOpen` / `deviceClosed`: neuter forms. A roleta would be «Otwarta» / «Zamknięta».
- `devicePowerMains`: «Sieć» could be read as "network"; «Sieciowe» is the alternative.
- `setupCreateWithCount`: «Utwórz dashboard (urządzenia: {count})» may be long for a button.
- `deviceWhite` «Biel», `deviceDismiss` «Odrzuć», `deviceHealthTitle` «Kondycja», `panelTypeRadio` «Przyciski opcji».

## Portuguese, Brazil (`app_pt.arb`)

- **Terms:** Casa (home), Painel (dashboard), Bloco (tile, also old "panel" strings), Seção, Persiana (cover), Tópico, Pareamento, Cena.
- `panelStateOn` / `panelStateOff`: LIGADO / DESLIGADO. May be too long where ON/OFF fit.
- `panelTypeSlider`: «Controle deslizante». Long for chips.
- `tileSizeSmall` / `Wide` / `Full`: Pequeno / Largo / Inteiro.
- `deviceClear` «Livre», `deviceLastHeard` «Último contato», `dashWallDisplay` «Tela de parede».
- `setupWelcomeTitle`: «Boas-vindas ao ZigDash», gender-neutral.

## Everywhere

SMLIGHT menu paths stay in English ("Settings > MQTT", "Allow External"), because the hub's web UI shows them that way.
