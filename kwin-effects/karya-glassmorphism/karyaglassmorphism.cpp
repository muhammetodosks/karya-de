#include <kwineffects.h>
#include <kwinglutils.h>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

namespace KWin
{

class KaryaGlassmorphismEffect : public Effect
{
    Q_OBJECT
public:
    KaryaGlassmorphismEffect();
    ~KaryaGlassmorphismEffect() override;

    void drawWindow(const RenderTarget& renderTarget, const RenderWindow& renderWindow,
                    int mask, QRegion region, WindowPaintData& data) override;

    static bool supported();
    static bool enabledByDefault() { return false; }

private:
    double m_blurRadius;
    double m_opacity;
    bool m_enabled;
};

KaryaGlassmorphismEffect::KaryaGlassmorphismEffect()
    : m_blurRadius(12.0)
    , m_opacity(0.75)
    , m_enabled(true)
{
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigHome) + "/karya-glassmorphism.conf";
    QFile configFile(configPath);
    if (configFile.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(configFile.readAll());
        QJsonObject obj = doc.object();
        m_blurRadius = obj.value("blurRadius").toDouble(12.0);
        m_opacity = obj.value("opacity").toDouble(0.75);
        m_enabled = obj.value("enabled").toBool(true);
    }
}

KaryaGlassmorphismEffect::~KaryaGlassmorphismEffect()
{
}

void KaryaGlassmorphismEffect::drawWindow(const RenderTarget& renderTarget,
                                           const RenderWindow& renderWindow,
                                           int mask, QRegion region, WindowPaintData& data)
{
    if (m_enabled) {
        data.opacity *= m_opacity;
    }

    effects->drawWindow(renderTarget, renderWindow, mask, region, data);
}

bool KaryaGlassmorphismEffect::supported()
{
    return effects->isOpenGLCompositing();
}

} // namespace KWin

#include "karyaglassmorphism.moc"
