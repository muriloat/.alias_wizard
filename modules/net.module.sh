#!/bin/bash
# Network (net) module for Alias Wizard

# Handle Network commands
net_handle() {
    local action="$1"
    local type="$2"
    local any="$3"

    case "$action" in
        conf)
            sudo joe /etc/netplan/50-cloud-init.yaml
            ;;
        test)
            sudo netplan try
            ;;
        rest)
            sudo netplan apply
            ;;
        cat)
            sudo cat /etc/netplan/50-cloud-init.yaml
            ;;
        sh)
            if [ -z "$type" ]; then
                route -n
            elif [ "$type" = "t" ]; then
                if [ -z "$any" ]; then
                    echo "Show routes on table <table_name>"
                    echo "Usage: net-sh-t-<table_name>"
                    return 1
                fi
                sudo ip route show table "$any"
            else
                echo "Unknown type for net-sh: $type"
                echo "Available types: t"
                return 1
            fi
            ;;
        ipr)
            ip rule
            ;;
        ipra)
            if [ -z "$type" ] || [ -z "$any" ]; then
                echo "Usage: net-ipra-PREFIX-TABLE"
                return 1
            fi
            sudo ip rule add from "$type" table "$any"
            ;;
        iprd)
            if [ -z "$type" ] || [ -z "$any" ]; then
                echo "Usage: net-iprd-PREFIX-TABLE"
                return 1
            fi
            sudo ip rule del from "$type" table "$any"
            ;;
        if)
            if [ "$type" = "sh" ]; then
                ifconfig -a
            elif [ "$type" = "u" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-if-u-DEV"
                    return 1
                fi
                sudo ip link set dev "$any" up
            elif [ "$type" = "d" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-if-d-DEV"
                    return 1
                fi
                sudo ip link set dev "$any" down
            elif [ "$type" = "r" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-if-r-DEV"
                    return 1
                fi
                sudo ip link delete "$any"
            else
                echo "Unknown type for net-if: $type"
                echo "Available types: sh, u, d, r"
                return 1
            fi
            ;;
        irad)
            if [ -z "$type" ]; then
                echo "Usage: net-irad-IP"
                return 1
            fi
            # Get the primary interface
            local dev=$(ip route | grep default | head -n1 | awk '{print $5}')
            if [ -z "$dev" ]; then
                echo "Could not determine default interface"
                return 1
            fi
            sudo ip route add default via "$type" dev "$dev"
            ;;
        irdd)
            if [ -z "$type" ]; then
                echo "Usage: net-irdd-IP"
                return 1
            fi
            # Get the primary interface
            local dev=$(ip route | grep default | head -n1 | awk '{print $5}')
            if [ -z "$dev" ]; then
                echo "Could not determine default interface"
                return 1
            fi
            sudo ip route del default via "$type" dev "$dev"
            ;;
        tr)
            if [ -z "$type" ]; then
                echo "Usage: net-tr-IP"
                return 1
            fi
            sudo traceroute "$type"
            ;;
        stat)
            if [ -z "$type" ]; then
                sudo netstat -tuanlp
            elif [ "$type" = "e" ]; then
                sudo netstat -tn | grep ESTABLISHED
            elif [ "$type" = "l" ]; then
                sudo netstat -tlnp
            elif [ "$type" = "i" ]; then
                sudo netstat -i
            else
                echo "Unknown type for net-stat: $type"
                echo "Available types: e, l, i"
                return 1
            fi
            ;;
        dp)
            if [ "$type" = "h" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-dp-h-IP"
                    return 1
                fi
                sudo tcpdump host "$any"
            elif [ "$type" = "if" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-dp-if-INTERFACE"
                    return 1
                fi
                sudo tcpdump -i "$any"
            elif [ "$type" = "t" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-dp-t-PORT"
                    return 1
                fi
                sudo tcpdump proto tcp port "$any"
            elif [ "$type" = "u" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-dp-u-PORT"
                    return 1
                fi
                sudo tcpdump proto udp port "$any"
            else
                echo "Unknown type for net-dp: $type"
                echo "Available types: h, if, t, u"
                return 1
            fi
            ;;
        arp)
            if [ -z "$type" ]; then
                sudo ip neigh show
            elif [ "$type" = "del" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: net-arp-del-IP"
                    return 1
                fi
                sudo arp -d "$any"
            else
                # Assume type is a device name
                ip neigh show dev "$type"
            fi
            ;;
        scan)
            if [ -z "$type" ]; then
                echo "Usage: net-scan-PREFIX"
                return 1
            fi
            sudo nmap -sn "$type"
            ;;
        *)
            echo "Unknown action: $action for service: net"
            echo "Available actions:"
            echo "  - conf"
            echo "  - test"
            echo "  - rest"
            echo "  - cat"
            echo "  - sh[-t-TABLE]"
            echo "  - ipr"
            echo "  - ipra-<TABLE>"
            echo "  - iprd-<TABLE>"
            echo "  - if-[sh|u-<DEV>|d-<DEV>|r-<DEV>]"
            echo "  - irad-<IP>"
            echo "  - irdd-<IP>"
            echo "  - tr-<IP>"
            echo "  - stat[-e|-l|-i]"
            echo "  - dp-[h-<IP>|if-<INTERFACE>|t-<PORT>|u-<PORT>]"
            echo "  - arp [-<DEV>|-del-<IP>]"
            echo "  - scan-<PREFIX>"
            return 1
            ;;
    esac
}

# Completion function for Network
net_complete() {
    local prev="$1"
    local cur="$2"

    if [[ "$prev" == "net" ]]; then
        echo "conf test rest cat sh ipr ipra iprd if irad irdd tr stat dp arp scan"
    elif [[ "$prev" == "net-sh" ]]; then
        echo "t"
    elif [[ "$prev" == "net-if" ]]; then
        echo "sh u d r"
    elif [[ "$prev" == "net-stat" ]]; then
        echo "e l i"
    elif [[ "$prev" == "net-dp" ]]; then
        echo "h if t u"
    elif [[ "$prev" == "net-arp" ]]; then
        # List interfaces for completion
        ip -o link show | awk -F': ' '{print $2}'
        echo "del"
    fi
}