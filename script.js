// Check for WebXR and AR support
async function checkXRSupport() {
    if ('xr' in navigator) {
        try {
            const isSupported = await navigator.xr.isSessionSupported('immersive-ar');
            return isSupported;
        } catch (e) {
            console.error('Error checking AR support:', e);
            return false;
        }
    }
    return false;
}

// Initialize AR session and start camera feed
async function startARSession(modelPath) {
    if (!await checkXRSupport()) {
        alert('WebXR AR is not supported on your device. Please try using an AR-capable browser.');
        return;
    }

    try {
        // Request AR session
        const session = await navigator.xr.requestSession('immersive-ar', {
            requiredFeatures: ['hit-test', 'dom-overlay'],
            domOverlay: { root: document.createElement('div') }
        });

        // Set up WebGL context
        const canvas = document.createElement('canvas');
        const gl = canvas.getContext('webgl', { xrCompatible: true });
        
        // Initialize WebXR GL layer
        const glLayer = new XRWebGLLayer(session, gl);
        session.updateRenderState({ baseLayer: glLayer });

        // Load USDZ model
        const modelUrl = modelPath;
        
        // Set up scene and render loop
        const onXRFrame = (time, frame) => {
            session.requestAnimationFrame(onXRFrame);
            const pose = frame.getViewerPose(referenceSpace);
            
            if (pose) {
                // Render model in AR space
                const view = pose.views[0];
                const viewport = glLayer.getViewport(view);
                gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);
                
                // Render AR content here
                // This is where the 3D model would be rendered
            }
        };

        session.requestAnimationFrame(onXRFrame);

    } catch (error) {
        console.error('Error starting AR session:', error);
        alert('Failed to start AR session. Please make sure you have given camera permissions.');
    }
}

// Function to check if the device supports AR Quick Look (iOS)
function isARQuickLookSupported() {
    const a = document.createElement('a');
    return a.relList && a.relList.supports && a.relList.supports('ar');
}

// Initialize AR visualization
async function initializeARVisualization() {
    const webXRSupported = await checkXRSupport();
    const quickLookSupported = isARQuickLookSupported();

    document.querySelectorAll('.visualize-btn').forEach(button => {
        button.addEventListener('click', async function() {
            const modelPath = this.dataset.model;
            
            if (quickLookSupported) {
                // Use AR Quick Look for iOS
                const arButton = this.nextElementSibling;
                arButton.click();
            } else if (webXRSupported) {
                // Use WebXR for other AR-capable devices
                startARSession(modelPath);
            } else {
                alert('AR visualization is not supported on your device. Please try using an AR-capable browser or iOS device.');
            }
        });
    });

    // Show/hide appropriate buttons based on device capabilities
    if (quickLookSupported) {
        document.querySelectorAll('.ar-button').forEach(button => {
            button.style.display = 'inline-block';
        });
    } else if (webXRSupported) {
        document.querySelectorAll('.visualize-btn').forEach(button => {
            button.style.display = 'inline-block';
        });
    }
}

// Initialize when the DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeARVisualization();
}); 