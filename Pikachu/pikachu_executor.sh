#!/bin/sh

print_menu() {
    echo "
        Usage:

            - pikachu open <url>
                    Open url in Chrome. [TODO]

            - pikachu find in google <what would You like?>
                    Look for <what would You like?> in google. [TODO]

            - pikachu openchrome

            - pikachu find in my computer <what would You like?>
                    Look for <what would You like?> in your computer. [TODO]

            - pikachu hello
                    Pikachu says sth to You.

            - pikachu remove
                    Remove Pikachu :(

    "
}

open_chrome() {
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome &
}

say_hello() {
    echo "
                          Hello!


                     ***                  ***
                    *****                *****
                    *****                *****
                     ***                  ***
          ***                                        ***
           ***                                      ***
            ***                                    ***
             ***                                  ***
               ***                              ***
                 ***                          ***
                   ***                      ***
                      **********************
                         ****************


        "
}

print_remove() {
    echo "
    Are You sure? Do You really want to remove pikachu?
    If so, run: 'pikachu_administrator removepikachu'
    a tak serio, to ''./pikachu.sh removepikachu', bo nie działa chwilowo tamto
    "
}


case "$1" in
    "openchrome") open_chrome ;;

    "pleasehelpme") print_menu ;;

    "hello") say_hello ;;

    "remove") print_remove;;

    *) print_menu

esac
