#!/bin/bash
# OpenVPN (ovpn) module for Alias Wizard

# Handle OpenVPN commands
ovpn_handle() {
    local action="$1"
    local type="$2"
    local any="$3"
    
    case "$action" in
        stop)
            if [ "$type" = "s" ]; then
                sudo systemctl stop openvpn-server@server.service
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-stop-c-NUMBER"
                    return 1
                fi
                sudo systemctl stop openvpn-client@client${any}.service
            else
                echo "Unknown type for ovpn-stop: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        star)
            if [ "$type" = "s" ]; then
                sudo systemctl start openvpn-server@server.service
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-star-c-NUMBER"
                    return 1
                fi
                sudo systemctl start openvpn-client@client${any}.service
            else
                echo "Unknown type for ovpn-star: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        stat)
            if [ "$type" = "s" ]; then
                sudo systemctl status openvpn-server@server.service
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-stat-c-NUMBER"
                    return 1
                fi
                sudo systemctl status openvpn-client@client${any}.service
            else
                echo "Unknown type for ovpn-stat: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        rest)
            if [ "$type" = "s" ]; then
                sudo systemctl restart openvpn-server@server.service
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    sudo systemctl restart openvpn-client@client.service
                else
                    sudo systemctl restart openvpn-client@client${any}.service
                fi
            else
                echo "Unknown type for ovpn-rest: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        conf)
            if [ -z "$type" ] || [ "$type" = "s" ]; then
                sudo joe /etc/openvpn/server/server.conf
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-conf-c-NUMBER"
                    return 1
                fi
                sudo joe /etc/openvpn/client/client${any}.conf
            else
                if [[ "$type" =~ ^[0-9]+$ ]]; then
                    # Handle the case of ovpn-conf-NUMBER
                    sudo joe /etc/openvpn/client/client${type}.conf
                else
                    echo "Unknown type for ovpn-conf: $type"
                    echo "Available types: s, c, [NUMBER]"
                    return 1
                fi
            fi
            ;;
        list)
            if [ -z "$type" ]; then
                sudo ls -l /etc/openvpn
            elif [ "$type" = "s" ]; then
                sudo ls -l /etc/openvpn/server
            elif [ "$type" = "c" ]; then
                sudo ls -l /etc/openvpn/client
            else
                echo "Unknown type for ovpn-list: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        cat)
            if [ "$type" = "s" ]; then
                sudo cat /etc/openvpn/server/server.conf
            elif [ "$type" = "c" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-cat-c-NUMBER"
                    return 1
                fi
                sudo cat /etc/openvpn/client/client${any}.conf
            else
                echo "Unknown type for ovpn-cat: $type"
                echo "Available types: s, c"
                return 1
            fi
            ;;
        deb)
            if [ "$type" = "scps" ]; then
                sudo tail -f /var/log/openvpn/scripts.log
            elif [ "$type" = "stat" ]; then
                if [ -z "$any" ]; then
                    echo "Usage: ovpn-deb-stat-NUMBER"
                    return 1
                fi
                sudo tail -f /var/log/openvpn/openvpn-server${any}.log
            else
                echo "Unknown type for ovpn-deb: $type"
                echo "Available types: scps, stat"
                return 1
            fi
            ;;
        *)
            echo "Unknown action: $action for service: ovpn"
            echo "Available actions:"
            echo "  - stop [s|c-NUMBER]"
            echo "  - star [s|c-NUMBER]"
            echo "  - stat [s|c-NUMBER]"
            echo "  - rest [s|c[-NUMBER]]"
            echo "  - conf [s|c-NUMBER|NUMBER]"
            echo "  - list [s|c]"
            echo "  - cat [s|c-NUMBER]"
            echo "  - deb [scps|stat-NUMBER]"
            return 1
            ;;
    esac
}

# Completion function for OpenVPN
ovpn_complete() {
    local prev="$1"
    local cur="$2"
    
    if [[ "$prev" == "ovpn" ]]; then
        echo "stop star stat rest conf list cat deb"
    elif [[ "$prev" =~ ^ovpn-(stop|star|stat|rest|conf|list|cat)$ ]]; then
        echo "s c"
    elif [[ "$prev" == "ovpn-deb" ]]; then
        echo "scps stat"
    fi
}