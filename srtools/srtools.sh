#!/bin/bash

srtools_scripts_path="$HOME/.scripts/srtools"

gen_menu() {

# If arguments passed is less than 7, let em know
  if [ $# -lt 6 ]
    then
      echo "Not enough arguments passed!"
      echo "Arguments required are as follows:"
      echo "height, width, choice_height, title, menu_question, option_array"
    else

      # $1 = height, $2 = width, $3 = choice height, $4 = title, $5 = menu question
      CHOICE=$(dialog --clear \
                      --backtitle "$app_title" \
                      --title "$4" \
                      --menu "$5" \
                      $1 $2 $3 \
                      "${OPTIONS[@]}" \
                      2>&1 >/dev/tty)
  fi

}

gen_confirm() {

  # (dialog --common-options --yesno text height width)
  dialog --title "Are you sure you would like to proceed with this action?" --backtitle "$app_title" --yesno "$1" 5 80

  # Get exit status
  # 0 means user hit [yes] button.
  # 1 means user hit [no] button.
  # 255 means user hit [Esc] key.
  response=$?
  case $response in
     0) $2 && $3 ;;
     1) $3 ;;
     255) echo "[ESC] key pressed.";;
  esac

}

main_menu() {

  OPTIONS=(1 "Server Management"
  	   2 "Configuration"
	   3 "Updates")

  # height, width, choice height, title, menu question, options array
  gen_menu "15" "40" "8" "SRtools Menu" "What would you like to manage?" "${OPTIONS[@]}"

  case $CHOICE in
    1)
      manage_menu
      ;;
    2)
      config_menu
      ;;
    3)
      updates_menu
      ;;
  esac

}

manage_menu() {

  OPTIONS=(1 "Start Game Server"
           2 "Main Menu")

  # height, width, choice height, title, menu question, options array
  gen_menu "20" "40" "15" "Server Management Menu" "What would you like to manage?" "${OPTIONS[@]}"

  case $CHOICE in
    1)
      gen_confirm "Start Game Server" "$srtools_scripts_path/inc/start_game_server.sh" manage_menu
      ;;
    2)
      main_menu
      ;;
  esac

}


config_menu() {

  OPTIONS=(1 "Configure Git Credentials"
           2 "Back to previous menu")

  # height, width, choice height, title, menu question, options array
  gen_menu "15" "40" "2" "Configuration Menu" "What would you like to configure?" "${OPTIONS[@]}"

  case $CHOICE in
    1)
      configure_git_input
      ;;
    2)
      main_menu
      ;;
  esac

}

updates_menu() {

  OPTIONS=(1 "Update SRtools"
           2 "Update Galaxy IP Address"
	   3 "Back to previous menu")

  # height, width, choice height, title, menu question, options array
  gen_menu "15" "40" "5" "Wartools Menu" "What would you like to update?" "${OPTIONS[@]}"

  case $CHOICE in
    1)
      gen_confirm "Update SRtools?" "$srtools_scripts_path/inc/update_srtools.sh" "exit 0"
      ;;
    2)
      gen_confirm "Update Galaxy IP?" "$srtools_scripts_path/inc/update_galaxy.sh" "exit 0"
      ;;
    3)
      main_menu
      ;;
  esac

}

configure_git_input() {

  t=$(mktemp -t inputbox.XXXXXXXXXXXXX) || exit
  trap 'rm -f "$t"' EXIT         # remove temp file when done
  trap 'exit 127' HUP STOP TERM  # remove if interrupted, too

  dialog --inputbox "What is your Github username?" 0 0 2>"$t"
  response=$?

  case $response in
    0) user=$(cat "$t") ;;
    1) exit 0 ;;
    255) echo "[ESC] key pressed." ;;
  esac

  dialog --inputbox "What is your Github password?" 0 0 2>"$t"
  response=$?

  case $response in
    0) password=$(cat "$t") ;;
    1) exit 0 ;;
    255) echo "[ESC] key pressed." ;;
  esac

  dialog --inputbox "What is your Github email?" 0 0 2>"$t"
  response=$?

  case $response in
    0) email=$(cat "$t") ;;
    1) exit 0 ;;
    255) echo "[ESC] key pressed." ;;
  esac

# Save credentials to git-credentials file
echo "https://$user:$password@github.com" > $HOME/.git-credentials

echo "[user]
    email = $email
    name = $user
[credential]
    helper = store
[cola]
    spellcheck = false
" > $HOME/.gitconfig

}

main_menu
