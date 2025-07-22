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
  sudo pacman -S --noconfirm steam kdenlive libreoffice-fresh thunderbird telegram-desktop \
    obsidian audacity htop btop mc ktorrent krita spectacle obs-studio gwenview zsh
}

setup_fonts() {
  echo "[+] Установка шрифта..."
  mkdir -p ~/.fonts
  cp "$SCRIPT_DIR/FiraCodeNerdFontMono-Regular.ttf" ~/.fonts/
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
    setup_zsh_and_konsole
    install_yay_and_aur_packages
    install_amnezia
    ;;
  2)
    echo "[=] Установка набора пакетов..."
    install_base_packages
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

