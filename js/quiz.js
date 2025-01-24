document.addEventListener('DOMContentLoaded', () => {
    const quizForm = document.getElementById('quiz-form');
    const steps = document.querySelectorAll('.quiz-step');
    const progressSteps = document.querySelectorAll('.progress-steps .step');
    const progress = document.querySelector('.progress');
    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');
    const submitBtn = document.querySelector('.submit-btn');
    const budgetRange = document.getElementById('budget-range');
    const budgetValue = document.getElementById('budget-value');

    // Unit toggle handling
    const roomSizeInput = document.getElementById('room-size');
    const unitToggle = document.getElementById('room-unit-toggle');

    if (unitToggle && roomSizeInput) {
        unitToggle.addEventListener('click', () => {
            const currentUnit = unitToggle.dataset.unit;
            const currentValue = parseFloat(roomSizeInput.value) || 0;
            
            if (currentUnit === 'sqft') {
                // Convert to square meters
                unitToggle.dataset.unit = 'm2';
                unitToggle.textContent = 'm²';
                unitToggle.classList.add('metric');
                if (currentValue) {
                    roomSizeInput.value = Math.round(currentValue * 0.092903);
                }
                roomSizeInput.placeholder = '37';
            } else {
                // Convert to square feet
                unitToggle.dataset.unit = 'sqft';
                unitToggle.textContent = 'sq ft';
                unitToggle.classList.remove('metric');
                if (currentValue) {
                    roomSizeInput.value = Math.round(currentValue * 10.7639);
                }
                roomSizeInput.placeholder = '400';
            }
        });
    }

    // Image upload handling
    const spaceImage = document.getElementById('space-image');
    const imagePreview = document.getElementById('image-preview').querySelector('img');
    const previewText = document.getElementById('image-preview').querySelector('.preview-text');
    const dimensionsResult = document.querySelector('.dimensions-result');
    const maxLengthInput = document.getElementById('max-length');
    const maxDepthInput = document.getElementById('max-depth');
    const sofaOutline = document.getElementById('sofa-outline');

    // Initialize sofa visualization with default values
    updateSofaVisualization(50, 30);

    spaceImage.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const imagePreview = document.getElementById('image-preview');
                const previewImg = imagePreview.querySelector('img');
                const previewText = imagePreview.querySelector('.preview-text');
                
                previewImg.src = e.target.result;
                previewImg.style.display = 'block';
                previewText.style.display = 'none';

                // Store the image data in the form data
                window.roomImages = [e.target.result];
            };
            reader.readAsDataURL(file);
        }
    });

    // Update visualization when inputs change
    [maxLengthInput, maxDepthInput].forEach(input => {
        input.addEventListener('input', () => {
            updateSofaVisualization(maxLengthInput.value, maxDepthInput.value);
        });
    });

    function updateSofaVisualization(length, depth) {
        // Scale dimensions for visualization (1 inch = 2 pixels)
        const scale = 2;
        const scaledLength = length * scale;
        const scaledDepth = depth * scale;

        sofaOutline.style.width = `${scaledLength}px`;
        sofaOutline.style.height = `${scaledDepth}px`;
    }

    let currentStep = 1;
    const totalSteps = steps.length;

    // Update progress bar
    const updateProgress = () => {
        const progressWidth = ((currentStep - 1) / (totalSteps - 1)) * 100;
        progress.style.width = `${progressWidth}%`;
        
        // Update step indicators
        progressSteps.forEach((step, index) => {
            if (index + 1 <= currentStep) {
                step.classList.add('active');
            } else {
                step.classList.remove('active');
            }
        });
    };

    // Add this after the other const declarations at the top
    const progressStepButtons = document.querySelectorAll('.progress-steps .step');

    // Add click handlers for progress steps
    progressStepButtons.forEach(button => {
        button.addEventListener('click', () => {
            const stepNumber = parseInt(button.dataset.step);
            // Only allow clicking on steps that are accessible (have active class)
            if (button.classList.contains('active')) {
                currentStep = stepNumber;
                showStep(currentStep);
                window.scrollTo(0, 0);
            }
        });
    });

    // Update the CSS classes in showStep function
    const showStep = (stepNumber) => {
        steps.forEach(step => {
            step.classList.remove('active');
            if (parseInt(step.dataset.step) === stepNumber) {
                step.classList.add('active');
            }
        });

        // Update buttons
        prevBtn.disabled = stepNumber === 1;
        nextBtn.style.display = stepNumber === totalSteps ? 'none' : 'block';
        submitBtn.style.display = stepNumber === totalSteps ? 'block' : 'none';

        // Update progress steps to show all accessible steps
        progressStepButtons.forEach((step, index) => {
            if (index + 1 <= Math.max(currentStep, stepNumber)) {
                step.classList.add('active');
            } else {
                step.classList.remove('active');
            }
        });

        // Update progress bar
        updateProgress();
    };

    // Navigation event listeners
    prevBtn.addEventListener('click', () => {
        if (currentStep > 1) {
            currentStep--;
            showStep(currentStep);
        }
    });

    nextBtn.addEventListener('click', () => {
        if (validateStep(currentStep)) {
            if (currentStep < totalSteps) {
                currentStep++;
                showStep(currentStep);
                window.scrollTo(0, 0);
            }
        }
    });

    // Budget range input handler
    if (budgetRange && budgetValue) {
        budgetRange.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            budgetValue.textContent = `$${value.toLocaleString()}`;
        });
    }

    // Form validation
    const validateStep = (step) => {
        const currentStepElement = document.querySelector(`.quiz-step[data-step="${step}"]`);
        const requiredFields = currentStepElement.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
            if (!field.value) {
                isValid = false;
                field.classList.add('error');
                
                // Remove error class when user starts typing
                field.addEventListener('input', () => {
                    field.classList.remove('error');
                }, { once: true });
            }
        });

        // Style preference validation (now in step 2)
        if (step === 2) {
            const styleChart = document.querySelector('.style-chart');
            const styleBars = styleChart.querySelectorAll('.chart-bar .bar-fill');
            let hasSelectedStyle = false;
            
            styleBars.forEach(bar => {
                if (parseFloat(bar.style.width) > 0) {
                    hasSelectedStyle = true;
                }
            });
            
            if (!hasSelectedStyle) {
                isValid = false;
                alert('Please select at least one style preference');
            }
        }

        return isValid;
    };

    // Form submission
    quizForm.addEventListener('submit', (e) => {
        e.preventDefault();
        if (validateStep(currentStep)) {
            const formData = new FormData(quizForm);
            const data = Object.fromEntries(formData);
            
            const preferences = {
                space: {
                    roomSize: data['room-size'],
                    dimensions: {
                        width: data.width || null,
                        depth: data.depth || null
                    }
                },
                style: getStylePreferences(),
                colors: Array.from(document.querySelectorAll('input[name="color-preference"]:checked')).map(input => input.value),
                comfort: Array.from(document.querySelectorAll('input[name="comfort-preference"]:checked')).map(input => input.value),
                features: Array.from(document.querySelectorAll('input[name="features-preference"]:checked')).map(input => input.value),
                budget: parseInt(data.budget),
                timestamp: new Date().toISOString(),
                roomImages: window.roomImages || []
            };
            
            localStorage.setItem('quizPreferences', JSON.stringify(preferences));
            
            // Show loading state
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Finding Your Matches...';
            submitBtn.disabled = true;
            
            // Check if we're in the maisonAI subdirectory (GitHub Pages)
            const redirectPath = window.location.pathname.includes('/maisonAI/') 
                ? '/maisonAI/results.html' 
                : 'results.html';
            
            setTimeout(() => {
                window.location.href = redirectPath;
            }, 1500);
        }
    });

    // Helper function to get style preferences from the chart
    function getStylePreferences() {
        const styles = [];
        const styleBars = document.querySelectorAll('.chart-bar .bar-fill');
        styleBars.forEach(bar => {
            const style = bar.closest('.chart-bar').dataset.style;
            const percentage = parseFloat(bar.style.width);
            if (percentage > 0) {
                styles.push({
                    style: style,
                    preference: percentage
                });
            }
        });
        return styles;
    }

    // Initialize first step
    showStep(currentStep);

    // Add this after your other initialization code
    const styleGrid = document.querySelector('.style-grid');
    const styleImages = {
        'Bohemian': ['boho1', 'boho2', 'boho3'],
        'Modern': ['modern1', 'modern2', 'modern3'],
        'Midcentury': ['midcen1', 'midcen2', 'midcen3'],
        'Scandinavian': ['scandi1', 'scandi2', 'scandi3'],
        'Traditional': ['trad1', 'trad2', 'trad3']
    };

    // Update the populate style grid function to use S3 bucket URL
    Object.entries(styleImages).forEach(([style, images]) => {
        images.forEach(img => {
            const div = document.createElement('div');
            div.className = 'style-image';
            div.dataset.style = style;
            
            const image = document.createElement('img');
            image.src = `https://maisonai.s3-us-west-2.amazonaws.com/images/${img}.jpg`;
            image.alt = `${style} style furniture`;
            
            div.appendChild(image);
            styleGrid.appendChild(div);
        });
    });

    // Handle style selection and chart updates
    const styleSelections = new Set();
    const chartBars = document.querySelectorAll('.chart-bar');

    document.querySelectorAll('.style-image').forEach(image => {
        image.addEventListener('click', () => {
            image.classList.toggle('selected');
            const style = image.dataset.style;
            
            if (image.classList.contains('selected')) {
                styleSelections.add(style);
            } else {
                styleSelections.delete(style);
            }
            
            updateStyleChart();
        });
    });

    function updateStyleChart() {
        const totalSelected = document.querySelectorAll('.style-image.selected').length;
        const styleCounts = {};
        
        // Initialize counts
        chartBars.forEach(bar => {
            const style = bar.dataset.style;
            styleCounts[style] = 0;
        });
        
        // Count selections per style
        document.querySelectorAll('.style-image.selected').forEach(selected => {
            const style = selected.dataset.style;
            styleCounts[style]++;
        });
        
        // Update chart
        chartBars.forEach(bar => {
            const style = bar.dataset.style;
            const count = styleCounts[style];
            const percentage = totalSelected ? (count / totalSelected) * 100 : 0;
            
            const fill = bar.querySelector('.bar-fill');
            fill.style.width = `${percentage}%`;
        });
    }
}); 