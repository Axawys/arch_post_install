#!/bin/bash
set -e

# === Переменные ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Функции ===

show_banner() {
  clear
  echo "==============================="
  echo "     Arch Linux Post Setup     "
  echo "==============================="
  echo "Автор: Axawys"
  echo "GitHub: https://github.com/Axawys"
  echo
  echo "Выберите действие:"
  echo "1) Полная настройка системы (по умолчанию)"
  echo "2) Установить набор пакетов"
  echo "3) Настроить ZSH и Konsole"
  echo "4) Установить AmneziaVPN"
  echo
  read -rp "Ваш выбор [1/2/3/4]: " choice
  choice=${choice:-1}
}

install_base_packages() {
  echo "[+] Установка пакетов через pacman..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm libreoffice-fresh thunderbird telegram-desktop obsidian audacity htop btop mc ktorrent krita obs-studio gwenview zsh papirus-icon-theme kde-cli-tools
}

setup_fonts() {
  echo "[+] Установка шрифта..."
  mkdir -p ~/.fonts
  cp "$SCRIPT_DIR/FiraCodeNerdFontMono-Regular.ttf" ~/.fonts/
}

set_icon_theme() {
  echo "[+] Применение темы иконок Papirus-Dark..."

  if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
  fi

  if command -v kwriteconfig5 &> /dev/null; then
    kwriteconfig5 --file kdeglobals --group Icons --key Theme Papirus-Dark
    lookandfeeltool -a org.kde.breezedark.desktop 2>/dev/null || true
  fi
}

apply_kde_panel_config() {
  echo "[+] Настройка панели KDE (профиль plasma)..."

  mkdir -p "$HOME/.config"

  SRC="$SCRIPT_DIR/arch_post_install_appletsrc"
  DEST="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
  BACKUP="$DEST.backup.$(date +%s)"

  if [[ -f "$DEST" ]]; then
    echo " - Создаю резервную копию: $BACKUP"
    cp "$DEST" "$BACKUP"
  fi

  echo " - Копирую новый конфиг панели..."
  cp -f "$SRC" "$DEST"

  echo " - Перезапускаю Plasma Shell..."
  kquitapp5 plasmashell && kstart5 plasmashell &
}


setup_zsh_and_konsole() {
  echo "[+] Настройка ZSH и Konsole..."

  echo " - Копируем .zshrc и .p10k.zsh"
  cp "$SCRIPT_DIR/zshrc" ~/.zshrc
  cp "$SCRIPT_DIR/p10k.zsh" ~/.p10k.zsh

  echo " - Установка Zinit (менеджер плагинов для ZSH)..."
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

  echo " - Изменение оболочки по умолчанию на ZSH..."
  chsh -s /bin/zsh

  echo " - Копируем профиль Konsole..."
  mkdir -p ~/.local/share/konsole
  cp "$SCRIPT_DIR/Main.profile" ~/.local/share/konsole/
}

install_yay_and_aur_packages() {
  echo "[+] Установка yay и AUR-пакетов..."

  sudo pacman -S --needed --noconfirm git base-devel

  rm -rf yay
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay

  yay -S --noconfirm visual-studio-code-bin yandex-browser-corporate arduino-ide-bin google-earth-pro localsend-bin
}

install_amnezia() {
  echo "[+] Установка Amnezia VPN..."
  chmod +x "$SCRIPT_DIR/AmneziaVPN_Linux_Installer.bin"
  "$SCRIPT_DIR/AmneziaVPN_Linux_Installer.bin"
}

# === Главная логика ===
show_banner

case $choice in
  1)
    echo "[=] Полная настройка системы..."
    install_base_packages
    setup_fonts
    set_icon_theme
    setup_zsh_and_konsole
    install_yay_and_aur_packages
    install_amnezia
    apply_kde_panel_config
    ;;
  2)
    echo "[=] Установка набора пакетов..."
    install_base_packages
    set_icon_theme
    setup_fonts
    install_yay_and_aur_packages
    ;;
  3)
    echo "[=] Настройка ZSH и Konsole..."
    setup_zsh_and_konsole
    ;;
  4)
    echo "[=] Установка только Amnezia VPN..."
    install_amnezia
    ;;
  *)
    echo "[-] Неверный выбор. Завершение."
    exit 1
    ;;
esac

echo
echo "✅ Готово! Приятного использования :)"
[[ $choice == "1" || $choice == "3" ]] && exec zsh

