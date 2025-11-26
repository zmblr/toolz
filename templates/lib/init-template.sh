#!/usr/bin/env bash
# Template initialization script
# Replaces PROJ_NAME placeholder with actual project name
#
# Usage: init-template <project-name> [directory]
#
# The script handles different naming conventions:
# - PROJ_NAME -> my-project (kebab-case, as provided)
# - PROJ_NAME_SNAKE -> my_project (snake_case for Python modules)
# - PROJ_NAME_PASCAL -> MyProject (PascalCase for classes)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
  echo "Usage: $(basename "$0") <project-name> [directory]"
  echo ""
  echo "Arguments:"
  echo "  project-name  Name for your project (kebab-case recommended, e.g., 'my-project')"
  echo "  directory     Target directory (default: current directory)"
  echo ""
  echo "Placeholders replaced:"
  echo "  PROJ_NAME        -> project-name (as provided)"
  echo "  PROJ_NAME_SNAKE  -> project_name (underscores)"
  echo "  PROJ_NAME_PASCAL -> ProjectName (PascalCase)"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") my-awesome-tool"
  echo "  $(basename "$0") data-processor ./my-project"
  exit 1
}

# Convert kebab-case to snake_case
to_snake_case() {
  echo "${1//-/_}"
}

# Convert kebab-case to PascalCase
to_pascal_case() {
  local input="$1"
  local result=""
  local capitalize=true

  for ((i = 0; i < ${#input}; i++)); do
    char="${input:i:1}"
    if [[ $char == "-" ]]; then
      capitalize=true
    elif $capitalize; then
      result+="${char^^}"
      capitalize=false
    else
      result+="$char"
    fi
  done
  echo "$result"
}

# Check arguments
if [[ $# -lt 1 ]]; then
  usage
fi

PROJECT_NAME="$1"
TARGET_DIR="${2:-.}"

# Validate project name
if [[ ! $PROJECT_NAME =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo -e "${RED}Error: Project name must start with a letter and contain only lowercase letters, numbers, and hyphens${NC}"
  echo "Example: my-project, data-tool-2"
  exit 1
fi

# Generate variants
PROJECT_NAME_SNAKE=$(to_snake_case "$PROJECT_NAME")
PROJECT_NAME_PASCAL=$(to_pascal_case "$PROJECT_NAME")

echo -e "${BLUE}Initializing template...${NC}"
echo -e "  Project name: ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Snake case:   ${GREEN}$PROJECT_NAME_SNAKE${NC}"
echo -e "  Pascal case:  ${GREEN}$PROJECT_NAME_PASCAL${NC}"
echo -e "  Directory:    ${GREEN}$TARGET_DIR${NC}"
echo ""

# Check if directory exists and has files
if [[ ! -d $TARGET_DIR ]]; then
  echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
  exit 1
fi

# Find files to process (excluding .git, result, and binary files)
# Also handle directory renames for PROJ_NAME_SNAKE
process_files() {
  local dir="$1"

  # First, rename directories containing PROJ_NAME_SNAKE (bottom-up to avoid conflicts)
  find "$dir" -depth -type d -name '*PROJ_NAME_SNAKE*' 2>/dev/null | while read -r old_dir; do
    new_dir="${old_dir//PROJ_NAME_SNAKE/$PROJECT_NAME_SNAKE}"
    if [[ $old_dir != "$new_dir" ]]; then
      echo -e "  ${YELLOW}Renaming directory:${NC} $(basename "$old_dir") -> $(basename "$new_dir")"
      mv "$old_dir" "$new_dir"
    fi
  done

  # Then, rename directories containing PROJ_NAME (bottom-up)
  find "$dir" -depth -type d -name '*PROJ_NAME*' 2>/dev/null | while read -r old_dir; do
    new_dir="${old_dir//PROJ_NAME/$PROJECT_NAME}"
    if [[ $old_dir != "$new_dir" ]]; then
      echo -e "  ${YELLOW}Renaming directory:${NC} $(basename "$old_dir") -> $(basename "$new_dir")"
      mv "$old_dir" "$new_dir"
    fi
  done

  # Process file contents and rename files
  find "$dir" -type f \
    ! -path '*/.git/*' \
    ! -path '*/result/*' \
    ! -path '*/result-*/*' \
    ! -path '*/.direnv/*' \
    ! -path '*/__pycache__/*' \
    ! -path '*/.ruff_cache/*' \
    ! -name '*.lock' \
    2>/dev/null | while read -r file; do

    # Skip binary files (but not text executables like scripts)
    file_type=$(file "$file")
    if echo "$file_type" | grep -q 'text'; then
      : # It's a text file, process it
    elif echo "$file_type" | grep -qE 'binary|data|executable'; then
      continue
    fi

    # Check if file contains any placeholder
    if grep -q 'PROJ_NAME' "$file" 2>/dev/null; then
      echo -e "  ${GREEN}Processing:${NC} $file"

      # Create temp file and replace placeholders
      # Order matters: replace more specific patterns first
      sed -i.bak \
        -e "s/PROJ_NAME_SNAKE/$PROJECT_NAME_SNAKE/g" \
        -e "s/PROJ_NAME_PASCAL/$PROJECT_NAME_PASCAL/g" \
        -e "s/PROJ_NAME/$PROJECT_NAME/g" \
        "$file"
      rm -f "${file}.bak"
    fi

    # Rename files containing PROJ_NAME_SNAKE
    filename=$(basename "$file")
    if [[ $filename == *PROJ_NAME_SNAKE* ]]; then
      new_filename="${filename//PROJ_NAME_SNAKE/$PROJECT_NAME_SNAKE}"
      new_file="$(dirname "$file")/$new_filename"
      echo -e "  ${YELLOW}Renaming file:${NC} $filename -> $new_filename"
      mv "$file" "$new_file"
    # Rename files containing PROJ_NAME
    elif [[ $filename == *PROJ_NAME* ]]; then
      new_filename="${filename//PROJ_NAME/$PROJECT_NAME}"
      new_file="$(dirname "$file")/$new_filename"
      echo -e "  ${YELLOW}Renaming file:${NC} $filename -> $new_filename"
      mv "$file" "$new_file"
    fi
  done
}

echo -e "${BLUE}Processing files...${NC}"
process_files "$TARGET_DIR"

echo ""
echo -e "${GREEN}Template initialized successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the changes in your project"
echo "  2. Run 'nix develop' to enter the development environment"
echo "  3. Start coding!"
