#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message "Error: $1 is not installed" "$RED"
        exit 1
    fi
}

# Function to check system requirements
check_system_requirements() {
    print_message "Checking system requirements..." "$YELLOW"
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        print_message "Error: Python 3 is not installed" "$RED"
        exit 1
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        print_message "Error: pip3 is not installed" "$RED"
        exit 1
    fi
    
    # Check system packages
    required_packages=("libgl1-mesa-glx" "libglib2.0-0" "python3-dev" "gcc")
    for package in "${required_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_message "Installing $package..." "$YELLOW"
            sudo apt-get install -y $package
        fi
    done
    
    print_message "System requirements check completed" "$GREEN"
}

# Function to create virtual environment
create_virtual_env() {
    print_message "Creating virtual environment..." "$YELLOW"
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        source venv/bin/activate
    else
        source venv/bin/activate
    fi
    
    print_message "Virtual environment created and activated" "$GREEN"
}

# Function to install Python dependencies
install_python_dependencies() {
    print_message "Installing Python dependencies..." "$YELLOW"
    
    pip install --upgrade pip
    pip install fastapi uvicorn detoxify transformers torch opencv-python-headless
    
    print_message "Python dependencies installed" "$GREEN"
}

# Function to create necessary directories
create_directories() {
    print_message "Creating necessary directories..." "$YELLOW"
    
    mkdir -p data/pipelines
    mkdir -p data/cache
    
    print_message "Directories created" "$GREEN"
}

# Function to create configuration file
create_config() {
    print_message "Creating configuration file..." "$YELLOW"
    
    cat > config.py << EOL
import os

# Base paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

# Pipeline settings
PIPELINES_DIR = os.path.join(DATA_DIR, "pipelines")
CACHE_DIR = os.path.join(DATA_DIR, "cache")

# Server settings
HOST = "0.0.0.0"
PORT = 9099

# Model settings
MODEL_CACHE_DIR = os.path.join(CACHE_DIR, "models")
EOL
    
    print_message "Configuration file created" "$GREEN"
}

# Function to create main application file
create_main_app() {
    print_message "Creating main application file..." "$YELLOW"
    
    cat > main.py << EOL
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Pipeline service is running"}

@app.get("/health")
async def health_check():
    return {"status": True}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9099)
EOL
    
    print_message "Main application file created" "$GREEN"
}

# Function to create startup script
create_startup_script() {
    print_message "Creating startup script..." "$YELLOW"
    
    cat > start.sh << EOL
#!/bin/bash
source venv/bin/activate
python main.py
EOL
    
    chmod +x start.sh
    print_message "Startup script created" "$GREEN"
}

# Main installation process
main() {
    print_message "Starting installation process..." "$YELLOW"
    
    check_system_requirements
    create_virtual_env
    install_python_dependencies
    create_directories
    create_config
    create_main_app
    create_startup_script
    
    print_message "Installation completed successfully!" "$GREEN"
    print_message "To start the service, run: ./start.sh" "$YELLOW"
}

# Run main function
main 