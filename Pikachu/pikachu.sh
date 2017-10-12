#!/bin/sh

#change carrefully (check remove function before:   'if rm -rf "$INSTALLATION_DIR"; then (...)' )
INSTALLATION_DIR="${HOME}/.pikachu"

PIKACHU_EX="${INSTALLATION_DIR}/pikachu_executor.sh"
PIKACHU="${INSTALLATION_DIR}/pikachu.sh"


add_pikachu_alias() {

    printf "What is the file where the pikachu alias will be append?\ndefault: %s/.bash_profile\n" "$HOME"
    read ALIAS_PATH
    if [ ! "$ALIAS_PATH" ]; then
        PATH="$HOME/.bash_profile"
    else
        PATH="$HOME/$ALIAS_PATH"
    fi
    #echo path: $ALIAS_PATH

    #echo path: $PATH
    #echo pika_ex: $PIKACHU_EX

    echo "alias pikachu=\"bash $PIKACHU_EX\"\n" >> "$PATH"
    echo "alias pikachuAdmin=\"bash $PIKACHU\"\n" >> "$PATH"
    echo "\n" >> "$PATH"
    source "$PATH"

}

copy_pikachu() {
    #echo "dir: $INSTALLATION_DIR"
    cp pikachu_executor.sh "$INSTALLATION_DIR"
    cp pikachu.sh "$INSTALLATION_DIR"
}


install_pikachu() {

    echo "installing pikachu to ${INSTALLATION_DIR} ..."
    for i in {1..20}
        do
            printf "%s" "="
            sleep 0.2
        done
    echo ""
    [ ! -d "$INSTALLATION_DIR" ] && mkdir $INSTALLATION_DIR


    copy_pikachu

    #add pikachu alias to bash profile's file
    add_pikachu_alias



    echo "
         Hello! I'm Pikachu!

            ▕▔╲       ╱▔▏
             ╲╱╲     ╱╲╱
              ╲┈╲▂▂▂╱┈╱   ╱╲
              ╱┈┈┈┈┈┈┈╲  ╱┈┈╲
              ▏▕▆▍▂▕▆▍▕ ╱┈┈┈╱
             ▕╭╮┈┳┻┳┈╭╮▏╲┈┈╱
              ╲╯┈╰━╯┈╰╱ ╱┈┈╲
              ╱┈┈┈┈┈┈┈╲ ╲┈┈┈╲
             ▕╲┈▕┈┈┈▏┈╱▏ ╱┈╱
             ▕┈▔▔┈┈┈▔▔┈▏╱┈╱
             ▕┈┈┈┈┈┈┈┈▕▔┈╱
              ╲┈┈┈┈┈┈┈╱▔▔
              ▕▂╱▔▔▔╲▂▏

    For more info type 'pikachu pleasehelpme'
    "

}

remove_pikachu_info() {
    #clear

    echo "
     Oh! Are You sure?
     Do You really want to kill Pikachu?

        ▕▔╲       ╱▔▏
         ╲╱╲     ╱╲╱
          ╲┈╲▂▂▂╱┈╱   ╱╲
          ╱┈┈┈┈┈┈┈╲  ╱┈┈╲
          ▏▕▆▍▂▕▆▍▕ ╱┈┈┈╱
         ▕╭╮┈┳┻┳┈╭╮▏╲┈┈╱
          ╲╯┈╰━╯┈╰╱ ╱┈┈╲
          ╱┈┈┈┈┈┈┈╲ ╲┈┈┈╲
         ▕╲┈▕┈┈┈▏┈╱▏ ╱┈╱
         ▕┈▔▔┈┈┈▔▔┈▏╱┈╱
         ▕┈┈┈┈┈┈┈┈▕▔┈╱
          ╲┈┈┈┈┈┈┈╱▔▔
          ▕▂╱▔▔▔╲▂▏

            [y|n]
    "
    t=true
    while $t;
    do
        read REPLY
        if [ "$REPLY" == 'y' ]
        then
            #echo "y"
            t=false
            remove_pikachu
        elif [ "$REPLY" == 'n' ]
        then
            #echo "n"
            t=false
        else
            echo "What's that? Type 'y' or 'n'."
        fi
    done
}


remove_pikachu() {

    echo removing...
    for i in {1..20}
        do
            printf "%s" "="
            sleep 0.2
        done
    echo ""
    if rm -rf "$INSTALLATION_DIR"; then
        echo "Pikachu removed."
        echo "Remove the pikachu alias to finish."
    else
        echo "There was an error with the removal of $INSTALLATION_DIR"
        exit 1
    fi


}


print_menu() {
    echo "
        Usage:

            - pikachu open <url>
                    Open url in Chrome. [TODO]

            - pikachu find in google <what would You like?>
                    Look for <what would You like?> in google. [TODO]

            - pikachu open chrome

            - pikachu find in my computer <what would You like?>
                    Look for <what would You like?> in your computer. [TODO]

            - pikachu hello
                    Pikachu says sth to You.

            - pikachu remove
                    Remove Pikachu :(

    "
}


print_info() {

    if [ ! -d "$INSTALLATION_DIR" ]; then
        echo "
            Pikachu doesn't seem to be installed yet.
            To install Pikachu run: ./pikachu.sh installpikachu
        "
    else
        print_menu

        echo "
            Pikachu seems to be installed.

            If something is wrong, run ./pikachu.sh installpikachu
        "
    fi

}

#echo "$1"


case "$1" in

    "installpikachu") install_pikachu ;;

    "removepikachu") remove_pikachu_info;;

    *) print_info;;

esac
