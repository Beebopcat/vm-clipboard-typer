; VM Clipboard Typer (AutoHotkey v2)
;
; Types the clipboard into the focused window one keystroke at a time, for VM
; consoles (such as VMware) that do not accept host clipboard paste.
;
; Usage:
;   F13            Type the clipboard into the focused window.
;   Esc            Stop typing (Esc still passes through to the VM).
;   Ctrl+Alt+Esc   Exit this script.
;
; Assumes a US keyboard layout in the VM. To use a different hotkey, change
; "F13::" below (for example "F9::" or "^!v::").

#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode "Event"
SetKeyDelay 0, 100

stopTyping := false

; Press Escape to stop typing.
; The ~ allows Escape to continue passing through to VMware.
~Esc::{
    global stopTyping
    stopTyping := true
}

; Emergency stop option.
^!Esc::ExitApp

F13::{
    global stopTyping
    stopTyping := false
    TypeFromClipboard()
}

TypeFromClipboard() {
    global stopTyping

    if (A_Clipboard = "") {
        ToolTip "Clipboard is empty. Press Ctrl+C manually first."
        Sleep 3000
        ToolTip
        return
    }

    for char in StrSplit(A_Clipboard) {
        ; Stop before sending another character.
        if (stopTyping) {
            ToolTip "Typing stopped."
            Sleep 1000
            ToolTip
            return
        }

        ; Ignore Windows carriage returns.
        if (char = "`r")
            continue

        ; Convert line feeds to Enter.
        if (char = "`n") {
            SendEvent "{Enter}"
        } else {
            SendCharacter(NormalizeChar(char))
        }

        ; Pause between characters (milliseconds). Lower = faster.
        Sleep 250
    }

    ToolTip "Typing complete."
    Sleep 1000
    ToolTip
}

; Map Unicode "smart" punctuation to US-keyboard ASCII equivalents.
NormalizeChar(char) {
    switch char {
        case Chr(0x2013), Chr(0x2014), Chr(0x2212):  ; en dash, em dash, minus sign
            return "-"
        case Chr(0x2018), Chr(0x2019):               ; curly single quotes
            return "'"
        case Chr(0x201C), Chr(0x201D):               ; curly double quotes
            return '"'
        case Chr(0x00A0):                            ; non-breaking space
            return " "
        case Chr(0x2010), Chr(0x2011):               ; hyphen, non-breaking hyphen
            return "-"
        default:
            return char
    }
}

; Send shifted symbols explicitly as Shift + base key (US layout).
SendCharacter(char) {
    switch char {
        case " ":
            SendEvent "{Space}"

        case "!":
            SendEvent "+1"
        case "@":
            SendEvent "+2"
        case "#":
            SendEvent "+3"
        case "$":
            SendEvent "+4"
        case "%":
            SendEvent "+5"
        case "^":
            SendEvent "+6"
        case "&":
            SendEvent "+7"
        case "*":
            SendEvent "+8"
        case "(":
            SendEvent "+9"
        case ")":
            SendEvent "+0"

        case "-":
            SendEvent "-"
        case "_":
            SendEvent "+-"
        case "+":
            SendEvent "+="
        case "{":
            SendEvent "+["
        case "}":
            SendEvent "+]"
        case "|":
            SendEvent "+\"
        case ":":
            SendEvent "+;"
        case "<":
            SendEvent "+,"
        case ">":
            SendEvent "+."
        case "?":
            SendEvent "+/"
        case "~":
            SendEvent "+``"

        case Chr(34):
            SendEvent "+'"
        case "'":
            SendEvent "'"

        default:
            SendEvent char
    }
}
