#!/bin/bash

# Get the name of the current directory
PROJECT_DIR="$PWD"
REPO_NAME=$(basename "$PROJECT_DIR")

# Step 1: Navigate into the project directory (optional if running in the project directory)
echo "Navigating into project directory..."
cd "$PROJECT_DIR" || exit

# Step 2: Remove old node modules
echo "Cleaning up old node modules..."
rm -rf node_modules

# Step 3: Create or update .gitignore file with specific entries
echo "Creating or updating .gitignore file..."
cat <<EOL > .gitignore
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Diagnostic reports
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Dependency directories
node_modules/
jspm_packages/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variable files
.env*
.next
.cache/
dist
EOL

# Step 4: Initialize Git repository if not initialized
echo "Initializing Git repository..."
if [ ! -d .git ]; then
    git init
    echo "Git repository initialized."
fi

# Step 5: Check if the repository exists on GitHub
echo "Checking if the repository exists on GitHub..."
if ! gh repo view "$REPO_NAME" > /dev/null 2>&1; then
    echo "Repository does not exist on GitHub. Creating..."
    gh repo create "$REPO_NAME" --public
    if [ $? -eq 0 ]; then
        echo "Remote repository created successfully."
        git remote add origin git@github.com:JonniiRingo/"$REPO_NAME".git
        echo "Remote repository added successfully."
    else
        echo "Failed to create remote repository."
        exit 1
    fi
else
    echo "Repository already exists on GitHub."
    git remote set-url origin git@github.com:JonniiRingo/"$REPO_NAME".git
fi

# Step 6: Install or update dependencies
echo "Installing or updating dependencies..."

# Install the latest versions of React and React-DOM explicitly
npm install react@latest react-dom@latest

npm install

# Step 7: Add and commit changes to Git
echo "Adding and committing changes to Git..."
git add .
git commit -m "Initial commit with updated dependencies and setup"

# Step 8: Push changes to remote repository
echo "Pushing changes to remote repository..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo "Changes pushed successfully."
else
    echo "Failed to push changes."
    exit 1
fi

# Step 9: Start the development server
echo "Starting React development server..."
npm run dev || npm start

echo "Project setup complete. Your project is running!"


# Create an alias for short command.
alias reactsetup="bash /Users/jonathansamuels/Web\ Development\ Projects/Projects-Setup/react-setups/react-setup.sh"