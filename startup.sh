#!/bin/bash

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Prompt for package manager
echo "Choose a package manager:"
options=("npm" "yarn" "bun" "pnpm")
select package_manager in "${options[@]}"; do
    if [[ " ${options[*]} " == *" $package_manager "* ]]; then
        echo "You chose $package_manager"
        break
    else
        echo "Invalid option. Please choose a valid package manager."
    fi
done

# Validate package manager choice
if [[ "$package_manager" != "npm" && "$package_manager" != "yarn" && "$package_manager" != "bun" && "$package_manager" != "pnpm" ]]; then
    echo "Invalid package manager. Please choose npm, yarn, bun, or pnpm."
    exit 1
fi

# Create VS Code settings file
echo "Creating VS Code settings file..."
{
mkdir -p .vscode
cat <<EOF > .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "always",
    "source.organizeImports": "always"
  },
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "typescript.tsdk": "node_modules/typescript/lib"
}
EOF
} & spinner
echo "VS Code settings file created!"

# Update EsLint configuration
echo "Updating EsLint configuration..."
{
cat <<EOF > .eslintrc.json
{
  "extends": ["next/core-web-vitals", "next/typescript", "prettier"],
  "plugins": ["check-file"],
  "rules": {
    "prefer-arrow-callback": ["error"],
    "prefer-template": ["error"],
    "semi": ["error"],
    "quotes": ["error", "double"],
    "check-file/filename-naming-convention": [
      "error",
      {
        "**/*.{ts,tsx}": "KEBAB_CASE"
      },
      {
        "ignoreMiddleExtensions": true
      }
    ],
    "check-file/folder-naming-convention": [
      "error",
      {
        "src/**": "KEBAB_CASE"
      }
    ]
  }
}
EOF
} & spinner
echo "EsLint configuration updated!"

# Create Prettier configuration file
echo "Creating Prettier configuration file..."
{
cat <<EOF > .prettierrc.json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "importOrder": [
    "^(react|next?/?([a-zA-Z/]*))$",
    "<THIRD_PARTY_MODULES>",
    "^@/(.*)$",
    "^[./]"
  ],
  "importOrderSeparation": true,
  "importOrderSortSpecifiers": true,
  "plugins": [
    "@trivago/prettier-plugin-sort-imports",
    "prettier-plugin-tailwindcss"
  ]
}
EOF
} & spinner
echo "Prettier configuration file created!"

# Create a Dockerfile for PostgreSQL
echo "Creating a Dockerfile for PostgreSQL..."
{
cat <<EOF > Dockerfile
# Use the official PostgreSQL image from the Docker Hub
FROM postgres:latest

# Set environment variables
ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=mypassword
ENV POSTGRES_DB=mydatabase

# Expose the PostgreSQL port
EXPOSE 5432
EOF
} & spinner
echo "Dockerfile created!"

# Step 3: Create a Docker Compose file
echo "Creating a Docker Compose file..."
{
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  db:
    build: .
    container_name: postgres_db
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: mypassword
      POSTGRES_DB: mydatabase
EOF
} & spinner
echo "Docker Compose file created!"

# Install Prettier and the Tailwind CSS plugin for Prettier
echo "Installing Prettier and the Tailwind CSS plugin for Prettier..."
{
    if [ "$package_manager" == "npm" ]; then
        npm install --save-dev prettier prettier-plugin-tailwindcss
        npm install --save-dev @trivago/prettier-plugin-sort-imports
        npm install --save-dev @next/eslint-plugin-next
        npm install --save-dev eslint-plugin-check-file
    elif [ "$package_manager" == "yarn" ]; then
        yarn add --dev prettier prettier-plugin-tailwindcss
        yarn add --dev @trivago/prettier-plugin-sort-imports
        yarn add --dev @next/eslint-plugin-next
        yarn add --dev eslint-plugin-check-file
    elif [ "$package_manager" == "bun" ]; then
        bun add --save-dev prettier prettier-plugin-tailwindcss
        bun add --save-dev @trivago/prettier-plugin-sort-imports
        bun add --save-dev @next/eslint-plugin-next
        bun add --save-dev eslint-plugin-check-file
    elif [ "$package_manager" == "pnpm" ]; then
        pnpm add --save-dev prettier prettier-plugin-tailwindcss
        pnpm add --save-dev @trivago/prettier-plugin-sort-imports
        pnpm add --save-dev @next/eslint-plugin-next
        pnpm add --save-dev eslint-plugin-check-file
    fi
} & spinner
echo "Prettier and the Tailwind CSS plugin for Prettier installed!"

echo "Setup complete!"
