// Karya Glassmorphism Effect - KWin Script
// Yüklemek için: kpackagetool6 -t KWin/Script -i karya-glassmorphism.js

var KaryaGlassmorphism = {
    blurRadius: 12,
    opacity: 0.75,
    enabled: true,

    init: function() {
        print("[Karya] Glassmorphism efekti başlatılıyor...");

        // KWin compositor ayarlarını oku
        var config = KWin.readConfig("blurRadius", 12);
        this.blurRadius = config;
        this.opacity = KWin.readConfig("opacity", 0.75);
        this.enabled = KWin.readConfig("enabled", true);

        // Pencere açılma/kapanma olaylarını dinle
        workspace.clientAdded.connect(function(client) {
            if (KaryaGlassmorphism.enabled && client.normalWindow) {
                client.setOpacity(KaryaGlassmorphism.opacity);
            }
        });

        // Kısayol: Meta+Shift+G toggle
        KWin.registerShortcut(
            "KaryaGlassmorphismToggle",
            "Karya Glassmorphism Efektini Aç/Kapat",
            "Meta+Shift+G",
            function() {
                KaryaGlassmorphism.enabled = !KaryaGlassmorphism.enabled;
                KWin.writeConfig("enabled", KaryaGlassmorphism.enabled);
                print("[Karya] Glassmorphism: " + (KaryaGlassmorphism.enabled ? "AÇIK" : "KAPALI"));
                KWin.reconfigureEffect();
            }
        );

        print("[Karya] Glassmorphism efekti hazır.");
    }
};

KaryaGlassmorphism.init();
