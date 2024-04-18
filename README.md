# Image Lazy Loading iOS App
This iOS application efficiently loads and displays images in a scrollable grid, adhering to the specifications provided for the assignment.

## Features
* Image Grid: Displays a 3-column square image grid with center-cropped images.
* Image Loading: Asynchronously loads images using the provided URL and constructs the image URL using the specified formula.
* Display: Allows users to scroll through at least 100 images smoothly.
* Caching: Implements caching mechanisms for storing images in both memory and disk caches for efficient retrieval.
* Error Handling: Gracefully handles network errors and image loading failures, providing informative error messages or placeholders for failed image loads.

## Requirements
* Xcode (version 14.1)

## Installation
1. Clone or download the repository from GitHub.
2. Open the project in Xcode.
3. Build and run the project on your iOS device or simulator.

## Usage
1. Upon launching the app, you will be presented with a grid of images.
2. Scroll through the grid to view different images.
3. Images will be loaded lazily as you scroll, ensuring smooth performance.
4. In case of network errors or failed image loading, appropriate error messages or placeholders will be displayed.
