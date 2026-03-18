# Awesome Stickies

Awesome Stickies is a modern macOS sticky notes app for reminders, quick notes, and ideas. It uses lightweight floating note windows and local persistence to keep important information visible and easy to manage throughout the day.

## Features

- Create and manage multiple sticky notes in separate floating windows
- Edit note titles and content directly in each note
- Change note colors for simple visual organization
- Autosave notes while you type
- Restore notes, window positions, and window sizes on relaunch
- Adjust global window opacity from Settings

## Requirements

- macOS 26.2 or later
- Xcode with SwiftUI support for macOS development

## Tech Stack

- Swift
- SwiftUI
- AppKit for native window management
- JSON-based local persistence

## Project Structure

- `Awesome_Stickies/App`: app lifecycle, dependency setup, and commands
- `Awesome_Stickies/ViewModels`: state management and note actions
- `Awesome_Stickies/Views`: sticky note UI and settings UI
- `Awesome_Stickies/Windowing`: custom macOS window creation and synchronization
- `Awesome_Stickies/Persistence`: local storage and state restoration
- `Awesome_Stickies/Models`: note, color, frame, and preferences models

## Running the App

1. Open `Awesome_Stickies.xcodeproj` in Xcode.
2. Select the `Awesome_Stickies` target.
3. Build and run the app on macOS.

## Current Status

This repository contains the current native macOS implementation with custom floating note windows, local persistence, and state restoration. The project is focused on a clean desktop experience and will continue to evolve with additional features.
