// Function to check if the device supports AR Quick Look
function isARQuickLookSupported() {
    const a = document.createElement('a');
    return a.relList && a.relList.supports && a.relList.supports('ar');
}

// Function to initialize AR buttons
function initializeARButtons() {
    if (isARQuickLookSupported()) {
        // Show AR Quick Look buttons and hide regular visualize buttons
        document.querySelectorAll('.ar-button').forEach(button => {
            button.style.display = 'inline-block';
        });
        document.querySelectorAll('.visualize-btn').forEach(button => {
            button.style.display = 'none';
        });
    } else {
        // Show regular visualize buttons for non-iOS devices
        document.querySelectorAll('.visualize-btn').forEach(button => {
            button.addEventListener('click', function() {
                alert('3D visualization is currently only available on iOS devices. We\'re working on supporting more platforms soon!');
            });
        });
    }
}

// Initialize when the DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeARButtons();
}); 