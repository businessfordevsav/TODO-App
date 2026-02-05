#!/bin/bash

# Script to run different flavors of the TODO app using --dart-define

echo "==================================="
echo "TODO App - Flavor Runner"
echo "==================================="
echo ""
echo "Select flavor to run:"
echo "1) Development (default)"
echo "2) Staging"
echo "3) QA"
echo "4) Production"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
  1)
    echo "Running Development flavor..."
    flutter run --dart-define=FLAVOR=dev
    ;;
  2)
    echo "Running Staging flavor..."
    flutter run --dart-define=FLAVOR=staging
    ;;
  3)
    echo "Running QA flavor..."
    flutter run --dart-define=FLAVOR=qa
    ;;
  4)
    echo "Running Production flavor..."
    flutter run --dart-define=FLAVOR=production
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac
