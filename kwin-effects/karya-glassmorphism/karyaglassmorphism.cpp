#include <kwineffects.h>
#include <kwinglutils.h>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

namespace KWin
{

class KaryaGlassmorphismEffect : public Effect
{
    Q_OBJECT
public:
    KaryaGlassmorphismEffect();
    ~KaryaGlassmorphismEffect() override;

    void paintWindow(const RenderTarget& renderTarget, const RenderWindow& renderWindow,
                     QRegion region, WindowPaintData& data) override;

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
    QFile configFile(QStandardPaths::locate(QStandardPaths::ConfigLocation,
                                             "karyaglassmorphism.conf"));
    if (configFile.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(configFile.readAll());
        QJsonObject obj = doc.object();
        m_blurRadius = obj.value("blurRadius").toDouble(12.0);
        m_opacity = obj.value("opacity").toDouble(0.75);
        m_enabled = obj.value("enabled").toBool(true);
    }

    reconfigure(ReconfigureAll);
}

KaryaGlassmorphismEffect::~KaryaGlassmorphismEffect()
{
}

void KaryaGlassmorphismEffect::paintWindow(const RenderTarget& renderTarget,
                                            const RenderWindow& renderWindow,
                                            QRegion region, WindowPaintData& data)
{
    if (m_enabled && effects->isCurrentApp()) {
        data.opacity *= m_opacity;

        if (effects->compositingType() == OpenGLCompositing) {
            GLFramebuffer::pushFramebuffer(renderTarget.frameBuffer());

            int screenWidth = effects->displayWidth();
            int screenHeight = effects->displayHeight();

            glViewport(0, 0, screenWidth, screenHeight);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
            glClear(GL_COLOR_BUFFER_BIT);

            GLFramebuffer::popFramebuffer();

            GLShader* blurShader = ShaderManager::instance()->getShader(ShaderTrait::MapTexture);
            if (blurShader) {
                blurShader->setUniform("blurRadius", (float)m_blurRadius);
            }
        }
    }

    effects->paintWindow(renderTarget, renderWindow, region, data);
}

bool KaryaGlassmorphismEffect::supported()
{
    return effects->isOpenGLCompositing();
}

} // namespace KWin

#include "karyaglassmorphism.moc"
