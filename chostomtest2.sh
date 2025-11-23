#!/bin/bash

# ألوان لل output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# دالة للطباعة الملونة
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1"; }

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

print_status "بدء تثبيت وتخصيص i3wm متطور على غرار Hyprland..."

# إنشاء المجلدات المطلوبة
print_status "إنشاء مجلدات التكوين..."
mkdir -p ~/.config/i3
mkdir -p ~/.config/polybar
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi
mkdir -p ~/.config/dunst
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/.config/rofi/themes

# تثبيت الحزم المطلوبة
print_status "تثبيت الحزم المطلوبة..."

if command -v apt &> /dev/null; then
    # ديبيان/أوبونتو
    sudo apt update
    sudo apt install -y feh rofi picom polybar dunst alacritty curl wget xdotool wmctrl \
        fonts-font-awesome fonts-dejavu fonts-jetbrains-mono jq imagemagick \
        playerctl brightnessctl arc-theme
        
elif command -v pacman &> /dev/null; then
    # أرش لينكس
    sudo pacman -Sy --noconfirm feh rofi picom polybar dunst alacritty curl wget \
        xdotool wmctrl ttf-font-awesome ttf-dejavu ttf-jetbrains-mono jq \
        imagemagick playerctl brightnessctl arc-gtk-theme
        
elif command -v dnf &> /dev/null; then
    # فيدورا
    sudo dnf install -y feh rofi picom polybar dunst alacritty curl wget \
        xdotool wmctrl fontawesome-fonts dejavu-fonts jetbrains-mono-fonts \
        jq ImageMagick playerctl brightnessctl arc-theme
        
else
    print_warning "لم يتم التعرف على مدير الحزم، سيتم المتابعة بدون تثبيت الحزم..."
fi

# نسخ ملفات التكوين الحالية احتياطياً
print_status "إنشاء نسخة احتياطية من ملفات التكوين الحالية..."
BACKUP_DIR="$HOME/i3-hypr-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

[ -f ~/.config/i3/config ] && cp ~/.config/i3/config "$BACKUP_DIR/"
[ -f ~/.config/polybar/config.ini ] && cp ~/.config/polybar/config.ini "$BACKUP_DIR/"
[ -f ~/.config/picom/picom.conf ] && cp ~/.config/picom/picom.conf "$BACKUP_DIR/"
[ -f ~/.config/dunst/dunstrc ] && cp ~/.config/dunst/dunstrc "$BACKUP_DIR/"
[ -f ~/.config/rofi/config.rasi ] && cp ~/.config/rofi/config.rasi "$BACKUP_DIR/"

print_success "تم إنشاء نسخة احتياطية في: $BACKUP_DIR"

# تنزيل خلفية عالية الجودة
print_status "تنزيل خلفية Hyprland مميزة..."
cd ~/Pictures/wallpapers

if command -v wget &> /dev/null; then
    wget -O hyprland-wallpaper.jpg "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2074&q=80" || \
    wget -O hyprland-wallpaper.jpg "https://images.unsplash.com/photo-1550745165-9bc0b252726f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80" || {
        print_warning "فشل تنزيل الخلفية، سيتم إنشاء خلفية متدرجة..."
        convert -size 3840x2160 gradient:#1a1b26-#7aa2f7 -blur 0x50 hyprland-wallpaper.jpg 2>/dev/null || \
        convert -size 1920x1080 gradient:#1a1b26-#7aa2f7 hyprland-wallpaper.jpg 2>/dev/null || \
        touch hyprland-wallpaper.jpg
    }
else
    print_warning "wget غير مثبت، سيتم إنشاء خلفية افتراضية..."
    convert -size 1920x1080 gradient:#1a1b26-#7aa2f7 hyprland-wallpaper.jpg 2>/dev/null || \
    touch hyprland-wallpaper.jpg
fi

# كتابة ملف تكوين i3 مع gaps متقدمة
print_status "كتابة تكوين i3 مع gaps متقدمة..."
cat > ~/.config/i3/config << 'I3_CONFIG'
# i3 config file - Hyprland Style
# === إعدادات أساسية ===
set $mod Mod4
font pango:JetBrains Mono 10

# === ألوان Hyprland ===
# class                 border  backgr. text    indicator
client.focused          #7aa2f7 #7aa2f7 #1a1b26 #7aa2f7
client.focused_inactive #292e42 #292e42 #a9b1d6 #292e42
client.unfocused        #1a1b26 #1a1b26 #565f89 #1a1b26
client.urgent           #f7768e #f7768e #1a1b26 #f7768e

# === Gaps متقدمة ===
# مسافات بين النوافذ
gaps inner 15
gaps outer 5

# إعدادات الماوس والتركيز
focus_follows_mouse yes
mouse_warping output
hide_edge_borders both

# === بدء التطبيقات ===
exec_always --no-startup-id ~/.config/i3/autostart.sh
exec_always --no-startup-id feh --bg-fill ~/Pictures/wallpapers/hyprland-wallpaper.jpg

# === Keybindings أساسية ===
bindsym $mod+Return exec alacritty --config-file ~/.config/alacritty/alacritty.yml
bindsym $mod+d exec rofi -show drun -theme ~/.config/rofi/themes/hyprland.rasi
bindsym $mod+Shift+q kill
bindsym $mod+f fullscreen toggle
bindsym $mod+space floating toggle

# === التنقل بين النوافذ ===
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# === إدارة المسافات (Gaps) ===
bindsym $mod+Shift+plus gaps inner current plus 5
bindsym $mod+Shift+minus gaps inner current minus 5
bindsym $mod+Shift+0 gaps inner current set 15

# === التخطيطات ===
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# === Scratchpad ===
bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show

# === إعادة التشغيل والتحميل ===
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# === مشغل التطبيقات ===
bindsym $mod+p exec rofi -show run -theme ~/.config/rofi/themes/hyprland.rasi

# === التحكم في الوسائط ===
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioPause exec playerctl pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

# === الصوت ===
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle

# === السطوع ===
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +10%
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 10%-

# === تغيير حجم النوافذ ===
bindsym $mod+r mode "resize"
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
    bindsym $mod+r mode "default"
}

# === مساحات العمل ===
set $ws1 ""
set $ws2 ""
set $ws3 ""
set $ws4 ""
set $ws5 ""
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# === أوامر سريعة ===
bindsym $mod+Shift+f exec thunar
bindsym $mod+Shift+b exec firefox
bindsym $mod+Shift+g exec gimp

# === إعدادات النوافذ ===
for_window [class="^.*"] border pixel 2
for_window [class="Polybar"] border none
I3_CONFIG

# كتابة سكريبت التشغيل التلقائي المتقدم
print_status "كتابة سكريبت التشغيل التلقائي المتقدم..."
cat > ~/.config/i3/autostart.sh << 'AUTOSTART_SCRIPT'
#!/bin/bash

# انتظار حتى يكون النظام جاهز
sleep 1

# قتل العمليات إذا كانت تعمل مسبقاً
killall -q polybar picom dunst

# انتظر حتى يتم إغلاق العمليات
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done
while pgrep -u $UID -x picom >/dev/null; do sleep 0.5; done
while pgrep -u $UID -x dunst >/dev/null; do sleep 0.5; done

# تشغيل polybar
echo "--- Starting Polybar ---" | tee -a /tmp/polybar.log
polybar main 2>&1 | tee -a /tmp/polybar.log & disown

# تشغيل picom بتأثيرات متقدمة
picom --config ~/.config/picom/picom.conf --daemon 2>&1 | tee -a /tmp/picom.log &

# تشغيل إشعارات dunst
dunst -config ~/.config/dunst/dunstrc 2>&1 | tee -a /tmp/dunst.log &

# تعيين خلفية الشاشة
feh --bg-fill ~/Pictures/wallpapers/hyprland-wallpaper.jpg &

# إعدادات إضافية
xsetroot -cursor_name left_ptr &
setxkbmap -layout us -variant intl &

# تشغيل خدمات إضافية
systemctl --user restart polybar 2>/dev/null || true

notify-send "i3 Hyprland" "تم تحميل التكوين بنجاح! 🚀" -i "dialog-information"

echo "✅ تم تشغيل i3-Hyprland بنجاح..."
AUTOSTART_SCRIPT
chmod +x ~/.config/i3/autostart.sh

# كتابة تكوين Picom متقدم
print_status "كتابة تكوين Picom متقدم..."
cat > ~/.config/picom/picom.conf << 'PICOM_CONFIG'
# Picom Configuration - Hyprland Style
# ==============================

# الظلال والشفافية
shadow = true;
shadow-radius = 25
shadow-opacity = 0.6
shadow-offset-x = -20
shadow-offset-y = -20
shadow-exclude = [
    "class_g = 'Polybar'",
    "class_g = 'Dunst'",
    "class_g = 'i3-frame'",
    "name = 'Notification'",
    "window_type = 'dropdown_menu'",
    "window_type = 'popup_menu'",
    "window_type = 'menu'",
    "window_type = 'tooltip'"
];

# الشفافية
inactive-opacity = 0.92
active-opacity = 1.0
frame-opacity = 0.95
inactive-opacity-override = false
opacity-rule = [
    "90:class_g = 'Alacritty'",
    "95:class_g = 'Code'",
    "85:class_g = 'Thunar'"
];

# الزوايا المستديرة
corner-radius = 15
rounded-corners-exclude = [
    "class_g = 'Polybar'",
    "class_g = 'Dunst'",
    "window_type = 'dock'",
    "window_type = 'desktop'"
];
round-borders = 1
round-borders-exclude = []

# التمويه المتقدم
blur: {
    method = "dual_kawase"
    strength = 8
    background = true
    background-frame = true
    background-fixed = true
    kernel = "5x5box"
}

blur-background-exclude = [
    "class_g = 'Polybar'",
    "class_g = 'Dunst'",
    "class_g = 'i3-frame'",
    "window_type = 'dock'",
    "window_type = 'desktop'",
    "_GTK_FRAME_EXTENTS@:c"
]

# الخلفية الشفافية
backend = "glx"
glx-no-stencil = true
glx-copy-from-front = false
use-damage = true

# الأداء
vsync = true
dithered-present = false
mark-wmwin-focused = true
mark-ovredir-focused = true
detect-rounded-corners = true
detect-client-opacity = true
unredir-if-possible = false
detect-transient = true
detect-client-leader = true

# التركيز
focus-exclude = [
    "class_g = 'Dunst'",
    "class_g = 'rofi'"
]

# النوافذ
wintypes: {
    tooltip = { fade = true; shadow = true; opacity = 0.9; focus = true; };
    dock = { shadow = false; };
    dnd = { shadow = false; };
    popup_menu = { opacity = 0.95; };
    dropdown_menu = { opacity = 0.95; };
};
PICOM_CONFIG

# كتابة تكوين Polybar عائم وشفاف
print_status "كتابة تكوين Polybar عائم وشفاف..."
cat > ~/.config/polybar/config.ini << 'POLYBAR_CONFIG'
; === Polybar Configuration - Hyprland Style ===
; https://github.com/polybar/polybar

[colors]
; ألوان Hyprland
background = #881a1b26
background-alt = #88292e42
foreground = #c0caf5
foreground-alt = #a9b1d6
primary = #7aa2f7
secondary = #bb9af7
accent = #f7768e
success = #9ece6a
warning = #e0af68

[bar/main]
; الإعدادات العامة
monitor = ${env:MONITOR:}
width = 95%
height = 40
offset-x = 2.5%
offset-y = 10px
radius = 20
fixed-center = true

; الخلفية الشفافة
background = ${colors.background}
foreground = ${colors.foreground}

; الحدود
border-size = 0
border-color = #00000000

; الهوامش
padding-left = 0
padding-right = 2
module-margin-left = 1
module-margin-right = 2

; الخطوط
font-0 = "JetBrains Mono:size=10;3"
font-1 = "Font Awesome 6 Free:style=Solid:size=11;4"
font-2 = "Font Awesome 6 Brands:size=11;4"
font-3 = "Iosevka Nerd Font:size=11;4"

; الوحدات
modules-left = i3 hypr-menu
modules-center = date
modules-right = cpu memory pulseaudio battery powermenu

[module/hypr-menu]
type = custom/text
content = "   "
content-foreground = ${colors.primary}
content-background = ${colors.background-alt}
click-left = rofi -show drun -theme ~/.config/rofi/themes/hyprland.rasi

[module/i3]
type = internal/i3
format = <label-state> <label-mode>
index-sort = true
wrapping-scroll = false
pin-workspaces = true

label-mode-padding = 2
label-mode-foreground = #000000
label-mode-background = ${colors.primary}

; Workspace Labels
label-focused = %index%
label-focused-background = ${colors.primary}
label-focused-foreground = ${colors.background}
label-focused-padding = 3

label-unfocused = %index%
label-unfocused-padding = 3
label-unfocused-foreground = ${colors.foreground-alt}

label-visible = %index%
label-visible-background = ${colors.secondary}
label-visible-foreground = ${colors.background}
label-visible-padding = 3

label-urgent = %index%
label-urgent-background = ${colors.accent}
label-urgent-foreground = ${colors.background}
label-urgent-padding = 3

[module/date]
type = internal/date
interval = 1.0
date = "%a, %d %b"
time = "%I:%M %p"
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %date% %time%
label-foreground = ${colors.foreground-alt}

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %percentage:2%%
label-foreground = ${colors.foreground-alt}

[module/memory]
type = internal/memory
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.secondary}
label = %percentage_used:2%%
label-foreground = ${colors.foreground-alt}

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <label-volume> <bar-volume>
label-volume = " %percentage%%"
label-volume-foreground = ${colors.foreground}
label-muted = " Muted"
label-muted-foreground = ${colors.accent}

bar-volume-width = 8
bar-volume-foreground-0 = #9ece6a
bar-volume-foreground-1 = #9ece6a
bar-volume-foreground-2 = #9ece6a
bar-volume-foreground-3 = #e0af68
bar-volume-foreground-4 = #e0af68
bar-volume-foreground-5 = #f7768e
bar-volume-gradient = false
bar-volume-indicator = █
bar-volume-fill = █
bar-volume-empty = █
bar-volume-empty-foreground = ${colors.background-alt}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC0
full-at = 98

format-charging = <animation-charging> <label-charging>
format-discharging = <animation-discharging> <label-discharging>
format-full = <ramp-capacity> <label-full>

label-charging = "%percentage%% "
label-discharging = "%percentage%%"
label-full = "%percentage%% "

ramp-capacity-0 = ""
ramp-capacity-1 = ""
ramp-capacity-2 = ""
ramp-capacity-3 = ""
ramp-capacity-4 = ""

animation-charging-0 = ""
animation-charging-1 = ""
animation-charging-2 = ""
animation-charging-3 = ""
animation-charging-4 = ""
animation-charging-framerate = 750

[module/powermenu]
type = custom/menu
expand-right = true

format-spacing = 1
label-open = "  "
label-open-foreground = ${colors.accent}
label-close = "  "
label-close-foreground = ${colors.accent}
label-separator = "|"
label-separator-foreground = ${colors.foreground-alt}

menu-0-0 = " Poweroff"
menu-0-0-exec = systemctl poweroff
menu-0-1 = " Reboot"
menu-0-1-exec = systemctl reboot
menu-0-2 = " Suspend"
menu-0-2-exec = systemctl suspend
menu-0-3 = " Lock"
menu-0-3-exec = i3lock -c 1a1b26
menu-0-4 = " Logout"
menu-0-4-exec = i3-msg exit

[settings]
screenchange-reload = true
pseudo-transparency = true
wm-restack = i3

[global/wm]
margin-top = 0
margin-bottom = 0
POLYBAR_CONFIG

# إنشاء ثيمة Rofi مخصصة
print_status "إنشاء ثيمة Rofi مخصصة..."
cat > ~/.config/rofi/config.rasi << 'ROFI_CONFIG'
/* Rofi Configuration - Hyprland Theme */

configuration {
    modi: "drun,run,window";
    show-icons: true;
    terminal: "alacritty";
    window-format: "{w}  {i}  {c}  {t}";
}

@theme "hyprland"

/* Theme for hyprland */
* {
    bg0: #1a1b26;
    bg1: #292e42;
    bg2: #343b58;
    fg0: #c0caf5;
    fg1: #a9b1d6;
    fg2: #565f89;
    
    ac0: #7aa2f7;
    ac1: #bb9af7;
    ac2: #f7768e;
    ac3: #9ece6a;
    
    border: 2;
    margin: 0;
    padding: 8;
    spacing: 4;
}
ROFI_CONFIG

# ثيمة Rofi مفصلة
cat > ~/.config/rofi/themes/hyprland.rasi << 'ROFI_THEME'
/**
 * Rofi Theme - Hyprland Style
 */

* {
    bg-col: #1a1b26;
    bg-col-light: #292e42;
    border-col: #7aa2f7;
    selected-col: #7aa2f7;
    blue: #7aa2f7;
    fg-col: #c0caf5;
    fg-col2: #f7768e;
    grey: #565f89;
    
    width: 600;
    font: "JetBrains Mono 12";
    
    background-color: transparent;
    text-color: @fg-col;
    
    margin: 0;
    padding: 8;
    spacing: 4;
}

window {
    background-color: @bg-col;
    border: 2px;
    border-color: @border-col;
    border-radius: 15px;
    padding: 8px;
}

mainbox {
    border: 0;
    padding: 12px;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col-light;
    border-radius: 10px;
    padding: 8px;
    margin: 0px 0px 8px 0px;
}

prompt {
    background-color: @blue;
    padding: 8px 12px;
    border-radius: 8px;
    text-color: @bg-col;
    margin: 0px 4px 0px 0px;
}

entry {
    padding: 8px;
    text-color: @fg-col;
}

listview {
    background-color: @bg-col-light;
    border-radius: 10px;
    padding: 8px;
    margin: 8px 0px 0px 0px;
    lines: 8;
    scrollbar: true;
}

element {
    padding: 8px 12px;
    border-radius: 8px;
    text-color: @fg-col;
}

element selected {
    background-color: @blue;
    text-color: @bg-col;
}

element-text {
    text-color: inherit;
}

element-icon {
    size: 24;
    text-color: inherit;
}

message {
    background-color: @bg-col-light;
    border-radius: 8px;
    margin: 8px 0px 0px 0px;
    padding: 8px;
}

textbox {
    text-color: @fg-col;
}

error-message {
    background-color: @fg-col2;
    border-radius: 8px;
    padding: 8px;
    text-color: @bg-col;
}

scrollbar {
    width: 4px;
    border-radius: 2px;
    handle-color: @blue;
    handle-width: 8px;
    padding: 0;
}
ROFI_THEME

# تكوين Dunst متقدم
print_status "كتابة تكوين Dunst متقدم..."
cat > ~/.config/dunst/dunstrc << 'DUNST_CONFIG'
[global]
    monitor = 0
    follow = mouse
    geometry = "350x60-40+60"
    indicate_hidden = yes
    shrink = no
    transparency = 15
    notification_height = 0
    separator_height = 2
    padding = 16
    horizontal_padding = 16
    frame_width = 2
    frame_color = "#7aa2f7"
    sort = yes
    idle_threshold = 120
    font = JetBrains Mono 10
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
    max_icon_size = 48
    sticky_history = yes
    history_length = 20
    browser = /usr/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 12

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#565f89"
    timeout = 4

[urgency_normal]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#7aa2f7"
    timeout = 6

[urgency_critical]
    background = "#1a1b26"
    foreground = "#f7768e"
    frame_color = "#f7768e"
    timeout = 0
DUNST_CONFIG

# تكوين Alacritty
print_status "إنشاء تكوين Alacritty..."
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'ALACRITTY_CONFIG'
# Alacritty Configuration - Hyprland Theme

window:
  padding:
    x: 15
    y: 15
  opacity: 0.95
  decorations: none
  startup_mode: Windowed

scrolling:
  history: 10000
  multiplier: 3

font:
  size: 11.0
  normal:
    family: JetBrains Mono Nerd Font
    style: Regular

colors:
  primary:
    background: '0x1a1b26'
    foreground: '0xc0caf5'
  cursor:
    text: '0x1a1b26'
    cursor: '0xc0caf5'
  normal:
    black:   '0x15161E'
    red:     '0xf7768e'
    green:   '0x9ece6a'
    yellow:  '0xe0af68'
    blue:    '0x7aa2f7'
    magenta: '0xbb9af7'
    cyan:    '0x7dcfff'
    white:   '0xa9b1d6'
  bright:
    black:   '0x414868'
    red:     '0xf7768e'
    green:   '0x9ece6a'
    yellow:  '0xe0af68'
    blue:    '0x7aa2f7'
    magenta: '0xbb9af7'
    cyan:    '0x7dcfff'
    white:   '0xc0caf5'

key_bindings:
  - { key: V, mods: Control|Shift, action: Paste }
  - { key: C, mods: Control|Shift, action: Copy }
  - { key: Key0, mods: Control, action: ResetFontSize }
  - { key: Equals, mods: Control, action: IncreaseFontSize }
  - { key: Minus, mods: Control, action: DecreaseFontSize }
ALACRITTY_CONFIG

# إنشاء سكريبتات مساعدة
