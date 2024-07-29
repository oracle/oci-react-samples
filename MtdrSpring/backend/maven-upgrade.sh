#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Treat unset variables as an error
set -u

# Variables
MAVEN_VERSION="3.9.8"
DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
INSTALL_DIR="$HOME/mvn-upgrade"
ARCHIVE_NAME="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# Functions
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

create_directory() {
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
        log "Created directory: $INSTALL_DIR"
    else
        log "Directory already exists: $INSTALL_DIR"
    fi
}

download_maven() {
    if wget -q --spider "$DOWNLOAD_URL"; then
        wget -O "${INSTALL_DIR}/${ARCHIVE_NAME}" "$DOWNLOAD_URL"
        log "Downloaded Maven: $DOWNLOAD_URL"
    else
        log "Maven download URL does not exist: $DOWNLOAD_URL"
        exit 1
    fi
}

extract_and_cleanup() {
    tar -xvzf "${INSTALL_DIR}/${ARCHIVE_NAME}" -C "$INSTALL_DIR"
    log "Extracted Maven archive"
    
    rm -f "${INSTALL_DIR}/${ARCHIVE_NAME}"
    log "Removed Maven archive: ${INSTALL_DIR}/${ARCHIVE_NAME}"
}

# Main Script
log "Starting Maven upgrade script"

log "Changing directory to home"
cd ~

log "Printing current directory"
pwd

log "Creating installation directory"
create_directory

log "Changing directory to installation directory"
cd "$INSTALL_DIR"

log "Downloading Maven"
download_maven

log "Extracting and cleaning up Maven archive"
extract_and_cleanup

log "Maven upgrade script completed successfully"
