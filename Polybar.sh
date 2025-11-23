#!/bin/bash

echo "🔵 تطبيق Polybar مع حدود زرقاء سماوية..."

# إنشاء مجلد polybar إذا لم يكن موجوداً
mkdir -p ~/.config/polybar

# نسخ احتياطي للتكوين الحالي
if [ -f ~/.config/polybar/config.ini ]; then
    cp ~/.config/polybar/config.ini ~/.config/polybar/config.ini.backup.$(date +%Y%m%d-%H%M%S)
    echo "📦 تم إنشاء نسخة احتياطية"
fi

# كتابة التكوين الجديد
cat > ~/.config/polybar/config.ini << 'POLYBAR_CONFIG'
[colors]
background = #881a1b26
background-alt = #88292e42
foreground = #c0caf5
foreground-alt = #a9b1d6
primary = #7aa2f7
secondary = #bb9af7
accent = #f7768e
success = #9ece6a
warning = #e0af68
border-blue = #7dcfff

[bar/main]
monitor = ${env:MONITOR:}
width = 92%
height = 42
offset-x = 4%
offset-y = 15px
radius = 12
fixed-center = true
background = ${colors.background}
foreground = ${colors.foreground}
border-size = 3
border-color = ${colors.border-blue}
padding-left = 2
padding-right = 2
module-margin-left = 1
module-margin-right = 1
font-0 = "JetBrains Mono:size=9;3"
font-1 = "Font Awesome 6 Free:style=Solid:size=10;4"
font-2 = "Font Awesome 6 Brands:size=10;4"
font-3 = "Iosevka Nerd Font:size=10;4"
modules-left = hypr-menu i3
modules-center = date
modules-right = cpu memory pulseaudio battery powermenu

[module/hypr-menu]
type = custom/text
content = "  HYPR "
content-foreground = ${colors.border-blue}
content-background = ${colors.background-alt}
content-padding = 2
click-left = rofi -show drun

[module/i3]
type = internal/i3
format = <label-state> <label-mode>
index-sort = true
wrapping-scroll = false
pin-workspaces = true
label-mode-padding = 2
label-mode-foreground = #000000
label-mode-background = ${colors.primary}
label-focused = " %index% "
label-focused-background = ${colors.border-blue}
label-focused-foreground = #1a1b26
label-focused-padding = 4
label-focused-radius = 6
label-unfocused = " %index% "
label-unfocused-padding = 4
label-unfocused-foreground = ${colors.foreground-alt}
label-unfocused-radius = 6
label-visible = " %index% "
label-visible-background = ${colors.secondary}
label-visible-foreground = ${colors.background}
label-visible-padding = 4
label-visible-radius = 6
label-urgent = " %index% "
label-urgent-background = ${colors.accent}
label-urgent-foreground = ${colors.background}
label-urgent-padding = 4
label-urgent-radius = 6

[module/date]
type = internal/date
interval = 1.0
date = "%a, %d %b"
time = "%I:%M %p"
format-prefix = "󰥔 "
format-prefix-foreground = ${colors.border-blue}
label = %date% %time%
label-foreground = ${colors.foreground}
label-padding = 2

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.border-blue}
label = %percentage:2%%
label-foreground = ${colors.foreground-alt}
label-padding = 2

[module/memory]
type = internal/memory
interval = 2
format-prefix = "󰍛 "
format-prefix-foreground = ${colors.border-blue}
label = %percentage_used:2%%
label-foreground = ${colors.foreground-alt}
label-padding = 2

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <label-volume> <bar-volume>
label-volume = " %percentage%%"
label-volume-foreground = ${colors.foreground}
label-muted = "󰖁 Muted"
label-muted-foreground = ${colors.accent}
bar-volume-width = 6
bar-volume-foreground-0 = ${colors.border-blue}
bar-volume-foreground-1 = ${colors.border-blue}
bar-volume-foreground-2 = ${colors.border-blue}
bar-volume-foreground-3 = #7aa2f7
bar-volume-foreground-4 = #7aa2f7
bar-volume-foreground-5 = #f7768e
bar-volume-gradient = false
bar-volume-indicator = |
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
label-charging = "%percentage%% 󰂄"
label-charging-foreground = ${colors.success}
label-discharging = "%percentage%%"
label-discharging-foreground = ${colors.foreground-alt}
label-full = "%percentage%% 󰂅"
label-full-foreground = ${colors.success}
ramp-capacity-0 = "󰂎"
ramp-capacity-1 = "󰁺"
ramp-capacity-2 = "󰁻"
ramp-capacity-3 = "󰁽"
ramp-capacity-4 = "󰁿"
ramp-capacity-foreground = ${colors.border-blue}
animation-charging-0 = "󰢜"
animation-charging-1 = "󰂆"
animation-charging-2 = "󰂇"
animation-charging-3 = "󰂈"
animation-charging-4 = "󰢝"
animation-charging-framerate = 700
animation-charging-foreground = ${colors.border-blue}

[module/powermenu]
type = custom/menu
expand-right = true
format-spacing = 1
label-open = "  "
label-open-foreground = ${colors.border-blue}
label-open-background = ${colors.background-alt}
label-open-padding = 4
label-open-radius = 6
label-close = " 󰜺 "
label-close-foreground = ${colors.accent}
label-close-padding = 4
label-close-radius = 6
label-separator = "|"
label-separator-foreground = ${colors.foreground-alt}
menu-0-0 = "󰐥 Poweroff"
menu-0-0-exec = systemctl poweroff
menu-0-1 = "󰜉 Reboot"
menu-0-1-exec = systemctl reboot
menu-0-2 = "󰤄 Suspend"
menu-0-2-exec = systemctl suspend
menu-0-3 = "󰍛 Lock"
menu-0-3-exec = i3lock -c 1a1b26
menu-0-4 = "󰗼 Logout"
menu-0-4-exec = i3-msg exit

[settings]
screenchange-reload = true
pseudo-transparency = false
wm-restack = i3
POLYBAR_CONFIG

# إعادة تشغيل polybar
echo "🔄 إعادة تشغيل Polybar..."
killall -q polybar
sleep 1
polybar main &

echo "✅ تم تطبيق Polybar مع الحدود الزرقاء السماوية بنجاح!"
