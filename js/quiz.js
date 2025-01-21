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
    const spaceImageInput = document.getElementById('space-image');
    const imagePreview = document.querySelector('.image-preview img');
    const previewText = document.querySelector('.preview-text');

    if (spaceImageInput) {
        spaceImageInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    imagePreview.style.display = 'block';
                    imagePreview.src = e.target.result;
                    previewText.style.display = 'none';
                };
                reader.readAsDataURL(file);
            } else {
                imagePreview.style.display = 'none';
                imagePreview.src = '';
                previewText.style.display = 'block';
            }
        });
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

    // Show current step
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

        // Update progress
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

        // Style preference validation
        if (step === 1) {
            const styleSelected = document.querySelector('input[name="style"]:checked');
            if (!styleSelected) {
                isValid = false;
                alert('Please select a style preference');
            }
        }

        // Usage validation
        if (step === 3) {
            const usageChecked = document.querySelectorAll('input[name="usage"]:checked');
            if (usageChecked.length === 0) {
                isValid = false;
                alert('Please select at least one primary use');
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
            
            // Store the form data in localStorage for the results page
            localStorage.setItem('quizResults', JSON.stringify(data));
            
            // Show loading state
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Finding Your Matches...';
            submitBtn.disabled = true;
            
            // Redirect to results page
            window.location.href = './results.html';
        }
    });

    // Initialize first step
    showStep(currentStep);
}); 