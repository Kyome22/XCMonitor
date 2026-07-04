# XCMonitor

A simple tool to monitor Xcode events (building and testing).

<img height="100" alt="Image" src="https://github.com/user-attachments/assets/4e84bc68-ea73-4a06-a0ae-46e2696b6928" />

## Logging event history

This app can collect Xcode event types and elapsed time.

<img height="275" alt="Image" src="https://github.com/user-attachments/assets/3fe18c58-5e3c-42a7-b9e6-759b420a8fea" />

## Architecture

XCMonitor adopts the [LUCA](https://github.com/Kyome22/LUCA) architecture.
The app shell lives in `XCMonitor.xcodeproj` and all source code lives in the local Swift Package `LocalPackage/`, split into three layers: `DataSource`, `Model`, and `UserInterface`.
Target: macOS 15+.

## Installation

Go to [Releases](https://github.com/Kyome22/XCMonitor/releases) and download the latest `dmg` file.

## How to activate

Open Preferences of XCMonitor and enable XCHook.

<img height="159" alt="Image" src="https://github.com/user-attachments/assets/1e41914c-f3a1-4c57-a561-3c60e133328d" />

## XCHook

A library to hack the events (building and testing) of Xcode.app.<br>
This library supports macOS (15+).<br>
XCMonitor is a demonstration for XCHook.

https://github.com/Kyome22/XCHook
