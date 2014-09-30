# dice bash completion script

dice=/home/ms/dice/bin/dice

function _dice {
    local cur prev opts
    _get_comp_words_by_ref cur prev

    __dice_commands

    __comp_reply "$commands"  
    return 0
}

#========================================
# comp_reply
#----------------------------------------
function __comp_reply {
    word_list=$@
    COMPREPLY=($(compgen -W "$word_list" -- ${cur}))
}

function __dice_commands {
    commands=$($dice help -c | grep -v _doc)
}

complete -F _dice -o default dice
