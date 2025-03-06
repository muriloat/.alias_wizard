#!/bin/bash
# ~/.alias_wizard/loader.sh - Loads all enabled modules

# Initialize alias handler function
alias_wizard() {
    local input="$1"
    local parts=()
    
    # Split input by '-'
    IFS='-' read -ra parts <<< "$input"
    
    if [ ${#parts[@]} -lt 2 ]; then
        echo "Usage: service-action[-type][-any]"
        return 1
    fi
    
    local service="${parts[0]}"
    local action="${parts[1]}"
    local type="${parts[2]:-}"
    local any="${parts[3]:-}"
    
    # Check if the service module exists
    if [ -f "$HOME/.alias_wizard/enabled_modules/$service.module" ]; then
        # Source the module and get the command
        source "$HOME/.alias_wizard/enabled_modules/$service.module"
        
        # Call the module's handler function
        "${service}_handle" "$action" "$type" "$any"
    else
        echo "Unknown service: $service"
        echo "Available services:"
        for module in "$HOME/.alias_wizard/enabled_modules/"*.module; do
            [ -f "$module" ] && basename "$module" .module
        done
        return 1
    fi
}

# Create the command not found handler for alias wizard pattern matching
command_not_found_handle() {
    if [[ "$1" =~ ^([a-z]+)-([a-z]+)(-([a-z0-9]+))?(-([0-9]+))?$ ]]; then
        local service="${BASH_REMATCH[1]}"
        local action="${BASH_REMATCH[2]}"
        local type="${BASH_REMATCH[4]:-}"
        local any="${BASH_REMATCH[6]:-}"
        
        # Reconstruct the full command
        local cmd="$service-$action"
        [ -n "$type" ] && cmd="$cmd-$type"
        [ -n "$any" ] && cmd="$cmd-$any"
        
        # Call the alias_wizard function
        alias_wizard "$cmd"
        return $?
    fi
    return 127  # Command not found
}

# Load enabled modules to define their helper functions
for module in "$HOME/.alias_wizard/enabled_modules/"*.module; do
    if [ -f "$module" ]; then
        source "$module"
    fi
done

# Setup completion for modules
_alias_wizard_complete() {
    local cur prev service action type
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Get the service and action from the command
    if [[ $prev == *-* ]]; then
        service=$(echo "$prev" | cut -d'-' -f1)
        action=$(echo "$prev" | cut -d'-' -f2)
        type=$(echo "$prev" | cut -d'-' -f3)
    else
        service="$prev"
    fi
    
    # Call the module's completion function if it exists
    if [ -f "$HOME/.alias_wizard/enabled_modules/$service.module" ]; then
        source "$HOME/.alias_wizard/enabled_modules/$service.module"
        if declare -F "${service}_complete" > /dev/null; then
            COMPREPLY=( $(${service}_complete "$prev" "$cur") )
            return 0
        fi
    fi
    
    # Default completion - list enabled modules
    for module in "$HOME/.alias_wizard/enabled_modules/"*.module; do
        [ -f "$module" ] && COMPREPLY+=( "$(basename "$module" .module)" )
    done
    
    return 0
}

# Register completion
complete -F _alias_wizard_complete alias_wizard