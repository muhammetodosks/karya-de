# Karya DE - runit + elogind Kurulumu

## elogind

elogind, systemd-logind'in bağımsız bir implementasyonudur.
Karya DE'nin oturum yönetimi için gereklidir.

```bash
# elogind kur
sudo pacman -S elogind

# servisi başlat
sudo ln -s /etc/runit/sv/elogind /etc/runit/runsvdir/current/
```

## runit Servisleri

```bash
# runit kur
sudo pacman -S runit

# Gerekli servis dizinleri
sudo mkdir -p /etc/runit/sv

# elogind servisi
cat > /etc/runit/sv/elogind/run << 'EOF'
#!/bin/sh
exec /usr/lib/elogind/elogind
EOF
chmod +x /etc/runit/sv/elogind/run

# NetworkManager servisi
cat > /etc/runit/sv/NetworkManager/run << 'EOF'
#!/bin/sh
exec /usr/bin/NetworkManager --no-daemon
EOF
chmod +x /etc/runit/sv/NetworkManager/run

# PipeWire servisi (kullanıcı için)
cat > /etc/runit/sv/pipewire/run << 'EOF'
#!/bin/sh
exec /usr/bin/pipewire
EOF
chmod +x /etc/runit/sv/pipewire/run

# Servisleri etkinleştir
sudo ln -s /etc/runit/sv/elogind /etc/runit/runsvdir/default/
sudo ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default/
```

## Oturum Başlatma

KDM / SDDM yerine Karya DE kendi oturum yöneticisini kullanır:

```bash
# ~/.xinitrc
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=Karya
export XDG_SESSION_DESKTOP=Karya
exec /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
```

Veya konsoldan:

```bash
# Wayland
dbus-run-session startplasma-wayland

# X11
startx
```
