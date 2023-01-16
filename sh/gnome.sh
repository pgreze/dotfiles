###
### Gnome configuration
###

gnome_how_to="
List installed schemas:
> gsettings list-schemas

Explore gsettings paths:
> dconf list /org/gnome/terminal/legacy/
"

# https://unix.stackexchange.com/a/297660
# We need to define both a schema and a path:
# ```
# GSETTINGS_SCHEMA=org.gnome.Terminal.Legacy.Keybindings
# GSETTINGS_PATH=/org/gnome/terminal/legacy/keybindings/
# SCHEMA_PATH=$GSETTINGS_SCHEMA:$GSETTINGS_PATH
# ```
# gsettings list-recursively org.gnome.Terminal.Legacy.Settings
alias gsettings_set_terminal_keybinding="gsettings set 'org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/'"
# Alternative: dconf write /org/gnome/terminal/legacy/keybindings/$key $value

# Profile https://askubuntu.com/a/733202
gsettings_terminal_profile() {
    local profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
    echo ${profile:1:-1} # remove leading and trailing single quotes
}
gsettings_terminal_profile_list() {
    local profile=$(gsettings_terminal_profile)
    echo ">> Available keys:"
    gsettings list-keys "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/"
    printf "\n>> Overwriten keys for /org/gnome/terminal/legacy/profiles:/:$profile/:\n"
    dconf list "/org/gnome/terminal/legacy/profiles:/:$profile/" | while read key; do
        printf "- $key: "
        dconf read "/org/gnome/terminal/legacy/profiles:/:$profile/$key"
    done
}
alias gsettings_terminal_profile_set='gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings_terminal_profile)/"'

##
## Custom config
##

gsettings_my_terminal() {
    gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
    gsettings set org.gnome.Terminal.Legacy.Settings new-tab-position 'last'
    gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode 'tab'
    gsettings_set_terminal_keybinding new-tab '<Super>t'
    gsettings_set_terminal_keybinding close-tab '<Super>w'

    gsettings_set_terminal_keybinding find '<Super>F'
    gsettings_set_terminal_keybinding copy '<Super>c'
    gsettings_set_terminal_keybinding paste '<Super>v'

    gsettings_set_terminal_keybinding zoom-in '<Super>plus'
    gsettings_set_terminal_keybinding zoom-normal '<Super>0'
    gsettings_set_terminal_keybinding zoom-out '<Super>minus'

    gsettings_set_terminal_keybinding move-tab-left '<Super>braceleft'
    gsettings_set_terminal_keybinding move-tab-right '<Super>braceright'
    gsettings_set_terminal_keybinding prev-tab '<Super>bracketleft'
    gsettings_set_terminal_keybinding next-tab '<Super>bracketright'
    for i in $(seq 1 8); do
        gsettings_set_terminal_keybinding "switch-to-tab-$i" "<Super>$i"
    done
    gsettings_set_terminal_keybinding switch-to-tab-last '<Super>9'

    gsettings_terminal_profile_set use-theme-transparency true
    gsettings_terminal_profile_set use-transparent-background true
    gsettings_terminal_profile_set background-transparency-percent 10
}
