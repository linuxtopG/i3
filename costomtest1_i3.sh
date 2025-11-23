#!/bin/bash

# ألوان لل output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# دالة للطباعة الملونة
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# التحقق من أن المستخدم ليس root
if [ "$EUID" -eq 0 ]; then
    print_error "لا تقم بتشغيل هذا السكريبت كـ root!"
    exit 1
fi

# التحقق من وجود i3wm
if ! command -v i3 &> /dev/null; then
    print_error "i3wm غير مثبت! يرجى تثبيته أولاً."
    exit 1
fi

print_status "بدء تثبيت وتخصيص i3wm على غرار Hyprland..."

# إنشاء المجلدات المطلوبة
print_status "إنشاء مجلدات التكوين..."
mkdir -p ~/.config/i3
mkdir -p ~/.config/polybar
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi
mkdir -p ~/.config/dunst
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/.local/bin

# تثبيت الحزم المطلوبة
print_status "تثبيت الحزم المطلوبة..."

if command -v apt &> /dev/null; then
    # ديبيان/أوبونتو
    sudo apt update
    sudo apt install -y feh rofi picom polybar dunst alacritty curl wget xdotool wmctrl fonts-font-awesome fonts-dejavu
    
elif command -v pacman &> /dev/null; then
    # أرش لينكس
    sudo pacman -Sy --noconfirm feh rofi picom polybar dunst alacritty curl wget xdotool wmctrl ttf-font-awesome ttf-dejavu
    
elif command -v dnf &> /dev/null; then
    # فيدورا
    sudo dnf install -y feh rofi picom polybar dunst alacritty curl wget xdotool wmctrl fontawesome-fonts dejavu-fonts
    
else
    print_warning "لم يتم التعرف على مدير الحزم، سيتم المتابعة بدون تثبيت الحزم..."
fi

# نسخ ملفات التكوين الحالية احتياطياً
print_status "إنشاء نسخة احتياطية من ملفات التكوين الحالية..."
BACKUP_DIR="$HOME/i3-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

[ -f ~/.config/i3/config ] && cp ~/.config/i3/config "$BACKUP_DIR/"
[ -f ~/.config/polybar/config.ini ] && cp ~/.config/polybar/config.ini "$BACKUP_DIR/"
[ -f ~/.config/picom/picom.conf ] && cp ~/.config/picom/picom.conf "$BACKUP_DIR/"
[ -f ~/.config/dunst/dunstrc ] && cp ~/.config/dunst/dunstrc "$BACKUP_DIR/"

print_success "تم إنشاء نسخة احتياطية في: $BACKUP_DIR"

# كتابة ملف تكوين i3
print_status "كتابة تكوين i3..."
cat > ~/.config/i3/config << 'I3_CONFIG'
# i3 config file (v4)
# https://i3wm.org/docs/userguide.html

# Set mod key (Win key)
set $mod Mod4

# Font for window titles
font pango:DejaVu Sans Mono 10

# استخدام مزيج ألوان يشبه Hyprland
# class                 border  backgr. text    indicator
client.focused          #7aa2f7 #7aa2f7 #1a1b26 #7aa2f7
client.focused_inactive #292e42 #292e42 #a9b1d6 #292e42
client.unfocused        #1a1b26 #1a1b26 #565f89 #1a1b26
client.urgent           #f7768e #f7768e #1a1b26 #f7768e

# بدء التطبيقات عند التشغيل
exec_always --no-startup-id ~/.config/i3/autostart.sh

# خلفية الشاشة
exec_always --no-startup-id feh --bg-fill ~/Pictures/wallpapers/hyprland-wallpaper.jpg

# إعدادات الماوس
bindsym button2 kill

# إخفاء حواف النوافذ
hide_edge_borders both

# التركيز يتبع الماوس
focus_follows_mouse yes

# Keybindings أساسية
bindsym $mod+Return exec alacritty
bindsym $mod+d exec rofi -show drun
bindsym $mod+Shift+q kill
bindsym $mod+f fullscreen toggle

# تغيير التركيز
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# نقل النوافذ
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# تغيير تخطيط العمل
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# تكبير/تصغير النوافذ
bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show

# إعادة تحميل i3
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart

# الخروج من i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"

# بدء التطبيقات
bindsym $mod+Shift+Return exec alacritty
bindsym $mod+p exec rofi -show run

# التحكم في الصوت
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle

# السطوع
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +10%
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 10%-

# وضع النوافذ العائمة
bindsym $mod+Shift+space floating toggle

# تغيير حجم النوافذ
bindsym $mod+r mode "resize"
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
}

# مساحة العمل
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"

bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5

bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5

# gaps (إذا كان مثبتاً)
for_window [class="^.*"] border pixel 2
I3_CONFIG

# كتابة سكريبت التشغيل التلقائي
print_status "كتابة سكريبت التشغيل التلقائي..."
cat > ~/.config/i3/autostart.sh << 'AUTOSTART_SCRIPT'
#!/bin/bash

# قتل العمليات إذا كانت تعمل مسبقاً
killall -q polybar
killall -q picom
killall -q dunst

# انتظر حتى يتم إغلاق العمليات
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
while pgrep -u $UID -x dunst >/dev/null; do sleep 1; done

# تشغيل polybar
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar main 2>&1 | tee -a /tmp/polybar1.log & disown

# تشغيل picom بتأثيرات
picom --config ~/.config/picom/picom.conf &

# تشغيل إشعارات dunst
dunst -config ~/.config/dunst/dunstrc &

# تعيين خلفية الشاشة
feh --bg-fill ~/Pictures/wallpapers/hyprland-wallpaper.jpg

echo "تم تشغيل i3 بنجاح..."
AUTOSTART_SCRIPT

chmod +x ~/.config/i3/autostart.sh

# كتابة تكوين Picom
print_status "كتابة تكوين Picom..."
cat > ~/.config/picom/picom.conf << 'PICOM_CONFIG'
# الشفافية
inactive-opacity = 0.95
active-opacity = 1.0
frame-opacity = 0.9
inactive-opacity-override = false

# الزوايا المستديرة
corner-radius = 12
round-borders = 1
rounded-corners-exclude = [
  "class_g = 'Polybar'",
  "class_g = 'i3-frame'",
  "class_g = 'Dunst'",
  "window_type = 'dropdown_menu'",
  "window_type = 'popup_menu'",
  "window_type = 'menu'",
  "window_type = 'tooltip'"
]

# الظلال
shadow = true;
shadow-radius = 25
shadow-opacity = 0.6
shadow-offset-x = -15
shadow-offset-y = -15
shadow-exclude = [
  "class_g = 'Polybar'",
  "class_g = 'Dunst'",
  "name = 'Notification'",
  "class_g *= 'i3-frame'"
]

# التمويه (Blur)
blur: {
  method = "dual_kawase"
  strength = 5
  background = true
  background-frame = true
  background-fixed = true
}

blur-background-exclude = [
  "class_g = 'Polybar'",
  "class_g = 'Dunst'",
  "window_type = 'dock'",
  "window_type = 'desktop'"
]

# الخلفية الشفافة
backend = "glx"
glx-no-stencil = true
glx-copy-from-front = false

# الأداء
vsync = true
dithered-present = false
mark-wmwin-focused = true
mark-ovredir-focused = true
detect-rounded-corners = true
detect-client-opacity = true
unredir-if-possible = false
PICOM_CONFIG

# كتابة تكوين Polybar
print_status "كتابة تكوين Polybar..."
cat > ~/.config/polybar/config.ini << 'POLYBAR_CONFIG'
; ملف تكوين polybar
[colors]
background = #1a1b26
background-alt = #292e42
foreground = #c0caf5
foreground-alt = #a9b1d6
primary = #7aa2f7
secondary = #bb9af7
alert = #f7768e

[bar/main]
monitor = ${env:MONITOR:}
width = 100%
height = 35
offset-x = 0
offset-y = 0
radius = 12.0
fixed-center = true
background = ${colors.background}
foreground = ${colors.foreground}

line-size = 3
line-color = #f00

border-size = 0
border-color = #00000000

padding-left = 2
padding-right = 2

module-margin-left = 1
module-margin-right = 1

font-0 = "DejaVu Sans Mono:size=10;3"
font-1 = "Font Awesome 6 Free:style=Solid:size=10;3"
font-2 = "Font Awesome 6 Brands:size=10;3"

modules-left = i3
modules-center = date
modules-right = cpu memory pulseaudio battery

[module/i3]
type = internal/i3
format = <label-state> <label-mode>
index-sort = true
wrapping-scroll = false

label-mode-padding = 2
label-mode-foreground = #000
label-mode-background = ${colors.primary}

label-focused = %index%
label-focused-background = ${colors.primary}
label-focused-foreground = ${colors.background}
label-focused-padding = 2

label-unfocused = %index%
label-unfocused-padding = 2

label-visible = %index%
label-visible-background = ${colors.secondary}
label-visible-padding = 2

label-urgent = %index%
label-urgent-background = ${colors.alert}
label-urgent-padding = 2

[module/date]
type = internal/date
interval = 1.0

date = %Y-%m-%d%
time = %H:%M

label = %date% %time%
label-foreground = ${colors.foreground-alt}

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.secondary}
label = %percentage_used:2%%

[module/pulseaudio]
type = internal/pulseaudio

format-volume = <label-volume> <bar-volume>
label-volume = 墳
label-volume-foreground = ${colors.foreground}

label-muted = 🔇
label-muted-foreground = #666

bar-volume-width = 10
bar-volume-foreground-0 = #55aa55
bar-volume-foreground-1 = #55aa55
bar-volume-foreground-2 = #55aa55
bar-volume-foreground-3 = #55aa55
bar-volume-foreground-4 = #55aa55
bar-volume-foreground-5 = #f5a70a
bar-volume-foreground-6 = #ff5555
bar-volume-gradient = false
bar-volume-indicator = |
bar-volume-fill = ─
bar-volume-empty = ─
bar-volume-empty-foreground = ${colors.foreground-alt}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 98

format-charging = <animation-charging> <label-charging>
format-discharging = <animation-discharging> <label-discharging>
format-full = <ramp-capacity> <label-full>

label-charging = %percentage%%
label-discharging = %percentage%%
label-full = %percentage%%

ramp-capacity-0 = 
ramp-capacity-1 = 
ramp-capacity-2 = 
ramp-capacity-3 = 
ramp-capacity-4 = 

animation-charging-0 = 
animation-charging-1 = 
animation-charging-2 = 
animation-charging-3 = 
animation-charging-4 = 
animation-charging-framerate = 750

[settings]
screenchange-reload = true
; compositing
wm-restack = i3

[global/wm]
margin-top = 5
margin-bottom = 5
POLYBAR_CONFIG

# كتابة تكوين Dunst
print_status "كتابة تكوين Dunst..."
cat > ~/.config/dunst/dunstrc << 'DUNST_CONFIG'
[global]
    monitor = 0
    follow = mouse
    geometry = "300x5-30+50"
    indicate_hidden = yes
    shrink = no
    transparency = 20
    notification_height = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    frame_width = 3
    frame_color = "#bb9af7"
    sort = yes
    idle_threshold = 120
    font = Monospace 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    browser = /usr/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    timeout = 3

[urgency_normal]
    background = "#1a1b26"
    foreground = "#c0caf5"
    timeout = 6

[urgency_critical]
    background = "#1a1b26"
    foreground = "#f7768e"
    timeout = 0
DUNST_CONFIG

# تنزيل خلفية الشاشة
print_status "تنزيل خلفية الشاشة..."
cd ~/Pictures/wallpapers
if command -v wget &> /dev/null; then
    wget -O hyprland-wallpaper.jpg "https://images.unsplash.com/photo-1550745165-9bc0b252726f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80" || {
        print_warning "فشل تنزيل الخلفية، سيتم استخدام خلفية افتراضية..."
        # إنشاء خلفية بسيطة بديلة
        convert -size 1920x1080 gradient:#1a1b26-#7aa2f7 hyprland-wallpaper.jpg 2>/dev/null || touch hyprland-wallpaper.jpg
    }
else
    print_warning "wget غير مثبت، سيتم إنشاء خلفية افتراضية..."
    touch hyprland-wallpaper.jpg
fi

# إنشاء سكريبت لإعادة التشغيل
print_status "إنشاء سكريبت لإعادة التشغيل..."
cat > ~/.local/bin/restart-i3.sh << 'RESTART_SCRIPT'
#!/bin/bash
i3-msg restart
RESTART_SCRIPT
chmod +x ~/.local/bin/restart-i3.sh

# إضافة PATH إذا لم يكن مضافاً
if ! grep -q "\.local/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

print_success "تم الانتهاء من التثبيت والتخصيص!"

# عرض التعليمات النهائية
echo
print_status "تعليمات الاستخدام:"
echo "1. أعد تشغيل i3 بالضغط على: Win+Shift+R"
echo "2. أو أعد تسجيل الدخول"
echo "3. لأي مشاكل، تحقق من السجلات في: /tmp/polybar1.log"
echo
print_status "الاختصارات الرئيسية:"
echo "Win + Enter: فتح terminal"
echo "Win + D: فتح menu التطبيقات"
echo "Win + R: وضع resize"
echo "Win + 1-5: التبديل بين workspaces"
echo
print_warning "ملفات النسخ الاحتياطي موجودة في: $BACKUP_DIR"

# سؤال المستخدم إذا كان يريد إعادة التشغيل الآن
read -p "هل تريد إعادة تشغيل i3 الآن؟ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "جاري إعادة تشغيل i3..."
    i3-msg restart
fi
