#!/bin/bash
# ~/.alias_wizard/handler.sh - Manages modules

MODULE_DIR="$HOME/.alias_wizard/modules"
ENABLED_DIR="$HOME/.alias_wizard/enabled_modules"

# Create directories if they don't exist
mkdir -p "$MODULE_DIR" "$ENABLED_DIR"

usage() {
    echo "Alias Wizard Handler"
    echo "Usage: $0 [command] [module]"
    echo ""
    echo "Commands:"
    echo "  list                 - List all available modules"
    echo "  enable [module]      - Enable a module"
    echo "  disable [module]     - Disable a module"
    echo "  status [module]      - Check if a module is enabled"
    echo "  show [module]        - Show the contents of a module"
    echo "  create [module]      - Create a new module template"
    echo ""
    echo "Available modules:"
    list_modules
}

list_modules() {
    echo "Available modules:"
    for module in "$MODULE_DIR"/*.module; do
        if [ -f "$module" ]; then
            module_name=$(basename "$module" .module)
            if [ -L "$ENABLED_DIR/$(basename "$module")" ]; then
                echo "  $module_name [enabled]"
            else
                echo "  $module_name"
            fi
        fi
    done
}

enable_module() {
    local module="$1"
    
    if [ ! -f "$MODULE_DIR/$module.module" ]; then
        echo "Error: Module '$module' not found"
        return 1
    fi
    
    if [ -L "$ENABLED_DIR/$module.module" ]; then
        echo "Module '$module' is already enabled"
        return 0
    fi
    
    ln -s "$MODULE_DIR/$module.module" "$ENABLED_DIR/$module.module"
    echo "Module '$module' has been enabled"
    echo "Run 'source ~/.bashrc' to apply changes"
}

disable_module() {
    local module="$1"
    
    if [ ! -L "$ENABLED_DIR/$module.module" ]; then
        echo "Error: Module '$module' is not enabled"
        return 1
    fi
    
    rm "$ENABLED_DIR/$module.module"
    echo "Module '$module' has been disabled"
    echo "Run 'source ~/.bashrc' to apply changes"
}

module_status() {
    local module="$1"
    
    if [ ! -f "$MODULE_DIR/$module.module" ]; then
        echo "Error: Module '$module' not found"
        return 1
    fi
    
    if [ -L "$ENABLED_DIR/$module.module" ]; then
        echo "Module '$module' is enabled"
    else
        echo "Module '$module' is disabled"
    fi
}

show_module() {
    local module="$1"
    
    if [ ! -f "$MODULE_DIR/$module.module" ]; then
        echo "Error: Module '$module' not found"
        return 1
    fi
    
    echo "Contents of module '$module':"
    echo "--------------------------------------"
    cat "$MODULE_DIR/$module.module"
    echo "--------------------------------------"
}

create_module() {
    local module="$1"
    
    if [ -f "$MODULE_DIR/$module.module" ]; then
        echo "Error: Module '$module' already exists"
        return 1
    fi
    
    cat > "$MODULE_DIR/$module.module" << EOF
#!/bin/bash
# $module module for Alias Wizard

# Handle $module commands
${module}_handle() {
    local action="\$1"
    local type="\$2"
    local any="\$3"
    
    case "\$action" in
        # Define your actions here
        example)
            if [ -z "\$type" ]; then
                echo "Example command for $module"
            else
                echo "Example command for $module with type \$type"
                [ -n "\$any" ] && echo "With parameter: \$any"
            fi
            ;;
        *)
            echo "Unknown action: \$action for service: $module"
            echo "Available actions:"
            echo "  - example"
            return 1
            ;;
    esac
}

# Completion function for $module
${module}_complete() {
    local prev="\$1"
    local cur="\$2"
    
    # Parse the command to determine what completions to offer
    if [[ "\$prev" == "$module" ]]; then
        # Complete actions
        echo "example"
    elif [[ "\$prev" == "$module-example" ]]; then
        # Complete types
        echo "type1 type2"
    fi
}
EOF

    echo "Module '$module' has been created"
    echo "Edit the module file at $MODULE_DIR/$module.module to add your commands"
}

# Main script
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

command="$1"
module="$2"

case "$command" in
    list)
        list_modules
        ;;
    enable)
        if [ -z "$module" ]; then
            echo "Error: Please specify a module to enable"
            usage
            exit 1
        fi
        enable_module "$module"
        ;;
    disable)
        if [ -z "$module" ]; then
            echo "Error: Please specify a module to disable"
            usage
            exit 1
        fi
        disable_module "$module"
        ;;
    status)
        if [ -z "$module" ]; then
            echo "Error: Please specify a module to check"
            usage
            exit 1
        fi
        module_status "$module"
        ;;
    show)
        if [ -z "$module" ]; then
            echo "Error: Please specify a module to show"
            usage
            exit 1
        fi
        show_module "$module"
        ;;
    create)
        if [ -z "$module" ]; then
            echo "Error: Please specify a module name to create"
            usage
            exit 1
        fi
        create_module "$module"
        ;;
    *)
        echo "Error: Unknown command '$command'"
        usage
        exit 1
        ;;
esac

exit 0