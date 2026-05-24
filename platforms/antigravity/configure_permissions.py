#!/usr/bin/env python3
import sys
import os
import json
import re

def main():
    if len(sys.argv) < 3:
        print("Usage: configure_permissions.py <config_json_path> <permissions_md_path>", file=sys.stderr)
        sys.exit(1)

    config_path = sys.argv[1]
    permissions_path = sys.argv[2]

    # Ensure the config directory exists
    os.makedirs(os.path.dirname(config_path), exist_ok=True)

    # Load existing config or initialize
    config = {}
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
        except Exception as e:
            print(f"Warning: Failed to parse existing config: {e}. Reinitializing.")

    # Initialize nested dictionaries
    if 'userSettings' not in config:
        config['userSettings'] = {}
    if 'globalPermissionGrants' not in config['userSettings']:
        config['userSettings']['globalPermissionGrants'] = {}
    if 'allow' not in config['userSettings']['globalPermissionGrants']:
        config['userSettings']['globalPermissionGrants']['allow'] = []

    existing_allow = config['userSettings']['globalPermissionGrants']['allow']

    # Read new permissions from PERMISSIONS.md
    new_permissions = []
    if os.path.exists(permissions_path):
        try:
            with open(permissions_path, 'r', encoding='utf-8') as f:
                content = f.read()
            match = re.search(r'```permissions:auto-allow\n(.*?)\n```', content, re.DOTALL)
            if match:
                lines = match.group(1).strip().split('\n')
                raw_perms = [line.strip() for line in lines if line.strip() and not line.strip().startswith('#')]
                # Format each raw permission string into Antigravity's 'command(...)' representation
                new_permissions = [f"command({p})" for p in raw_perms]
        except Exception as e:
            print(f"Error reading PERMISSIONS.md: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print(f"Error: PERMISSIONS.md not found at {permissions_path}", file=sys.stderr)
        sys.exit(1)

    # Merge and preserve order while removing duplicates
    merged_allow = list(existing_allow)
    for perm in new_permissions:
        if perm not in merged_allow:
            merged_allow.append(perm)

    config['userSettings']['globalPermissionGrants']['allow'] = merged_allow

    # Write back to config.json
    try:
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2)
        print("✅ Global permissions updated successfully.")
    except Exception as e:
        print(f"Error writing to config.json: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
