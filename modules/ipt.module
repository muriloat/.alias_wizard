#!/bin/bash
# iptables (ipt) module for Alias Wizard

# Handle iptables commands
ipt_handle() {
    local action="$1"
    local type="$2"
    local any="$3"
    
    case "$action" in
        conf)
            sudo joe /etc/iptables/rules.v4
            ;;
        rest)
            sudo iptables-restore < /etc/iptables/rules.v4
            ;;
        test)
            sudo iptables-restore -t /etc/iptables/rules.v4
            ;;
        cat)
            if [ "$type" = "4" ] || [ -z "$type" ]; then
                sudo cat /etc/iptables/rules.v4
            elif [ "$type" = "6" ]; then
                sudo cat /etc/iptables/rules.v6
            else
                echo "Unknown type for ipt-cat: $type"
                echo "Available types: 4, 6"
                return 1
            fi
            ;;
        list)
            if [ -z "$type" ]; then
                sudo iptables -nvL
            elif [ "$type" = "nat" ]; then
                sudo iptables -t nat -nvL
            elif [ "$type" = "s" ]; then
                sudo iptables -S
            else
                echo "Unknown type for ipt-list: $type"
                echo "Available types: nat, s"
                return 1
            fi
            ;;
        save)
            sudo iptables-save > /etc/iptables/rules.v4
            ;;
        *)
            echo "Unknown action: $action for service: ipt"
            echo "Available actions:"
            echo "  - conf"
            echo "  - rest"
            echo "  - test"
            echo "  - cat [-4|-6]"
            echo "  - list [-nat|-s]"
            echo "  - save"
            return 1
            ;;
    esac
}

# Completion function for iptables
ipt_complete() {
    local prev="$1"
    local cur="$2"
    
    if [[ "$prev" == "ipt" ]]; then
        echo "conf rest test cat list save"
    elif [[ "$prev" == "ipt-cat" ]]; then
        echo "4 6"
    elif [[ "$prev" == "ipt-list" ]]; then
        echo "nat s"
    fi
}