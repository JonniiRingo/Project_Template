#!/bin/bash

# Description:
# This script sets up a development environment on macOS for Node.js developers or computer science students.
# It installs Homebrew, Git, GitHub CLI, Node.js, and optionally, Visual Studio Code, Yarn, Docker, Postman, and MongoDB.
# After running this script, you will have a basic development setup ready for various programming tasks.

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install Homebrew if it's not installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Git
echo "Installing Git..."
brew install git
echo "Git is a version control system used for tracking changes in source code during software development."

# Install GitHub CLI
echo "Installing GitHub CLI..."
brew install gh
echo "GitHub CLI allows you to manage GitHub repositories and perform various GitHub tasks directly from the terminal."
echo "After installation, you need to authenticate by running 'gh auth login' and following the prompts."
echo "You can generate a personal access token on GitHub to authenticate."

# Install Node.js and npm
echo "Installing Node.js and npm..."
brew install node
echo "Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. npm is its package manager."
echo "You can manage Node.js versions with tools like nvm (Node Version Manager) if needed."

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
brew install --cask visual-studio-code
echo "Visual Studio Code is a popular code editor with support for a wide range of programming languages and extensions."

# Install Yarn (Optional)
echo "Installing Yarn..."
brew install yarn
echo "Yarn is an alternative package manager to npm for managing JavaScript project dependencies."

# Install Docker (Optional)
echo "Installing Docker..."
brew install --cask docker
echo "Docker is a platform for developing, shipping, and running applications in containers. You can use Docker for creating isolated development environments."

# Install Postman (Optional)
echo "Installing Postman..."
brew install --cask postman
echo "Postman is a tool for testing APIs. It allows you to send requests and view responses to ensure your APIs work as expected."

# Install MongoDB (Optional)
echo "Installing MongoDB..."
brew tap mongodb/brew
brew install mongodb-community
echo "MongoDB is a NoSQL database designed for modern applications. It's useful for storing and querying large amounts of unstructured data."

echo "Setup complete!"
echo "You may need to configure some tools further. For example:"
echo "1. GitHub CLI: Run 'gh auth login' to authenticate."
echo "2. Docker: Launch Docker from the Applications folder and follow the setup instructions."
echo "3. MongoDB: Start MongoDB using 'brew services start mongodb-community'."

echo "Feel free to customize this script according to your specific development needs and projects."
