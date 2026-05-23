import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  group('SceneConfig', () {
    test('round-trips sceneId through encode/decode', () {
      const cfg = SceneConfig(sceneId: 'abc-123');
      final decoded = PanelConfig.decode(PanelType.scene, cfg.encode());
      expect(decoded, isA<SceneConfig>());
      expect((decoded as SceneConfig).sceneId, 'abc-123');
    });

    test('defaultFor(scene) is an empty SceneConfig', () {
      final cfg = PanelConfig.defaultFor(PanelType.scene);
      expect(cfg, isA<SceneConfig>());
      expect((cfg as SceneConfig).sceneId, '');
    });

    test('decode tolerates a missing sceneId key', () {
      final decoded = PanelConfig.decode(PanelType.scene, '{}');
      expect((decoded as SceneConfig).sceneId, '');
    });
  });
}
