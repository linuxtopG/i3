
# i3

# تثبيت dependencies مسبقاً
sudo apt update
sudo apt install meson ninja-build libxcb1-dev libxcb-keysyms1-dev \
libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
libstartup-notification0-dev libxcb-randr0-dev libev-dev \
libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev \
libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0-dev \
libxcb-shape0-dev

# نسخ الريپو
git clone https://github.com/Airblader/i3.git
cd i3

# البناء والتثبيت
meson -Ddocs=true -Dmans=true build
ninja -C build
sudo ninja -C build install
