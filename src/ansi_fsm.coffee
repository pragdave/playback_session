(exports ? window).AnsiFSM =
class AnsiFSM
    states:
        plain:
            "\u001b": [ "esc_seen" ]
            "\r":     [ "plain", "cr" ]
            "\n":     [ "plain", "nl" ]
            "\u0008": [ "plain", "bs" ]
            "\t":      [ "plain", "ht" ]
            default:  [ "plain", "echo_char" ]

        esc_seen:
            "A":     [ "skip_emacs_term_mode_sequence" ]
            "[":     [ "csi_seen", null, "reset_args" ]
            default: [ "plain" ]

        skip_emacs_term_mode_sequence:
            "\n":    [ "plain" ]
            default: [ "skip_emacs_term_mode_sequence" ]
            
        csi_seen:
            "?":     [ "private_seen" ]
            ">":     [ "private_seen" ]
            "0":     [ "csi_seen", null, "collect_args" ]
            "1":     [ "csi_seen", null, "collect_args" ]
            "2":     [ "csi_seen", null, "collect_args" ]
            "3":     [ "csi_seen", null, "collect_args" ]
            "4":     [ "csi_seen", null, "collect_args" ]
            "5":     [ "csi_seen", null, "collect_args" ]
            "6":     [ "csi_seen", null, "collect_args" ]
            "7":     [ "csi_seen", null, "collect_args" ]
            "8":     [ "csi_seen", null, "collect_args" ]
            "9":     [ "csi_seen", null, "collect_args" ]
            ";":     [ "csi_seen", null, "collect_args" ]

            "@":     [ "plain", "ich" ]
            "A":     [ "plain", "cuu" ]
            "B":     [ "plain", "cud" ]
            "C":     [ "plain", "cuf" ]
            "D":     [ "plain", "cub" ]
            "E":     [ "plain", "cnl" ]
            "F":     [ "plain", "cpl" ]
            "G":     [ "plain", "cha" ]
            "H":     [ "plain", "cup" ]
            "J":     [ "plain", "ed"  ]
            "K":     [ "plain", "el"  ]
            "L":     [ "plain", "il"  ]
            "S":     [ "plain", "su"  ]
            "T":     [ "plain", "sd"  ]
            "d":     [ "plain", "vpa" ]
            "f":     [ "plain", "cup" ]
            "m":     [ "plain", "sgr" ]
            "n":     [ "plain", "dsr" ]
            "r":     [ "plain", "decstbm" ]
            "s":     [ "plain", "scp" ]
            "u":     [ "plain", "rsp" ]

            default: [ "plain", null, "unhandled" ]

        private_seen:
            "0":     [ "private_seen", null, "collect_args" ]
            "1":     [ "private_seen", null, "collect_args" ]
            "2":     [ "private_seen", null, "collect_args" ]
            "3":     [ "private_seen", null, "collect_args" ]
            "4":     [ "private_seen", null, "collect_args" ]
            "5":     [ "private_seen", null, "collect_args" ]
            "6":     [ "private_seen", null, "collect_args" ]
            "7":     [ "private_seen", null, "collect_args" ]
            "8":     [ "private_seen", null, "collect_args" ]
            "9":     [ "private_seen", null, "collect_args" ]
            ";":     [ "private_seen", null, "collect_args" ]

            "c":     [ "plain" ]       # send device attributes
            "h":     [ "plain", "sm" ]
            "l":     [ "plain", "rm" ]

        
            default: [ "plain", null, "punhandled" ]
        

    constructor: (@terminal)->
        @state = @states.plain

    accept_string: (string) ->
        @accept_char(char) for char in string
        @terminal.update()
        
    accept_char: (char) ->
        [ next_state, terminal_action, local_action ] = @transition(char)
        @state = @states[next_state]
        @[local_action](char) if local_action
        @terminal[terminal_action](char, @args) if terminal_action

    transition: (char) ->
        @state[char] || @state["default"]

    reset_args: (char) ->
        @args = [ 0 ]

    collect_args: (char) ->
        if char == ";"
            @args = @args.concat 0
        else
            @args.push(@args.pop() * 10 + (char - "0"))

    unhandled: (char) ->
            console.log "Unhandled CSI #{@args.join(';')} #{char}"

    punhandled: (char) ->
            console.log "Unhandled PRIVATE CSI #{@args.join(';')} #{char}"
