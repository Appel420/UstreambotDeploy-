#!/bin/bash

# DevAssist4-2-0 iOS Project Setup Script
echo "🚀 Setting up DevAssist4-2-0 iOS Project..."

# Create project directory
PROJECT_NAME="DevAssist4-2-0-iOS"
rm -rf "$PROJECT_NAME" 2>/dev/null
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "📁 Created project directory: $PROJECT_NAME"

# Create Xcode project structure
mkdir -p "$PROJECT_NAME"
mkdir -p "$PROJECT_NAME.xcodeproj"

echo "📱 Created Xcode project structure"

# Set up Git repository
git init
echo "# DevAssist4-2-0 iOS App

Professional iOS application with video streaming and AI chat capabilities.

## Features
- Video streaming with AVKit
- AI-powered chat interface
- Professional SwiftUI design
- Backend API integration

## Setup
1. Open $PROJECT_NAME.xcodeproj in Xcode
2. Update the backend URL in APIClient.swift
3. Build and run on iOS Simulator or device

## Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
" > README.md

echo "📝 Created README.md"

# Create .gitignore
echo "# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/*.xcworkspace/
!*.xcodeproj/*.xcworkspace/contents.xcworkspacedata
/*.gcno
**/xcshareddata/WorkspaceSettings.xcsettings

# Build generated
build/
DerivedData/

# Various settings
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/

# Other
*.moved-aside
*.xccheckout
*.xcscmblueprint
*.xcuserstate
" > .gitignore

echo "🔒 Created .gitignore"

echo "✅ DevAssist4-2-0 iOS project setup complete!"
echo "📍 Project location: $(pwd)"
echo "🔧 Next steps:"
echo "   1. Open the project in Xcode"
echo "   2. Configure your backend URL"
echo "   3. Build and test the app"
