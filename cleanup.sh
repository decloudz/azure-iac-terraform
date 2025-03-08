#!/bin/bash

# Cleanup script for removing old .tf files that have been modularized

# Files to keep in root directory
KEEP_FILES=(
  "main.tf"
  "variables.tf"
  "outputs.tf"
  "locals.tf"
  "provider.tf"
  "backend.tf"
  "azure-pipelines.yml"
)

# Create backup directory
BACKUP_DIR="old_tf_files_backup"
mkdir -p $BACKUP_DIR

echo "Creating backup of old .tf files in $BACKUP_DIR directory..."

# Move old .tf files to backup directory
for file in *.tf; do
  if [[ ! " ${KEEP_FILES[@]} " =~ " ${file} " ]]; then
    echo "Moving $file to backup directory"
    mv "$file" "$BACKUP_DIR/"
  fi
done

# Move plan files if they exist
if [ -f "dev-plan" ]; then
  echo "Moving dev-plan to backup directory"
  mv "dev-plan" "$BACKUP_DIR/"
fi

# Special non-module files
if [ -f "argo-bastion" ]; then
  echo "Moving argo-bastion to backup directory"
  mv "argo-bastion" "$BACKUP_DIR/"
fi

echo "Cleanup completed!"
echo "Old files are safely stored in the $BACKUP_DIR directory."
echo "If you need any of these files, you can find them there." 