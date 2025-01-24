document.addEventListener('DOMContentLoaded', () => {
    // Load preferences from localStorage
    const preferences = JSON.parse(localStorage.getItem('quizPreferences'));
    
    if (!preferences) {
        // If no preferences found, redirect back to quiz
        window.location.href = 'quiz.html';
        return;
    }

    // Update preference tags
    updatePreferenceTags(preferences);

    // TODO: Use preferences to fetch and display matching furniture
    // For now, we'll just show the static examples

    // Animate score bars on page load
    const scoreElements = document.querySelectorAll('.score-fill');
    scoreElements.forEach(score => {
        const width = score.style.width;
        score.style.width = '0';
        setTimeout(() => {
            score.style.width = width;
        }, 300);
    });

    // Handle save for later functionality
    const saveButtons = document.querySelectorAll('.secondary-btn');
    saveButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            button.innerHTML = '<i class="fas fa-check"></i> Saved';
            button.style.backgroundColor = '#4CAF50';
            button.style.color = 'white';
        });
    });

    // Handle email results
    const emailButton = document.querySelector('.save-btn');
    if (emailButton) {
        emailButton.addEventListener('click', () => {
            const email = prompt('Enter your email to receive your matches:');
            if (email) {
                alert('Your matches have been sent to ' + email);
            }
        });
    }

    // Handle print results
    const printButton = document.querySelector('.print-btn');
    if (printButton) {
        printButton.addEventListener('click', () => {
            window.print();
        });
    }

    // Handle chat with expert
    const chatButton = document.querySelector('.contact-btn');
    if (chatButton) {
        chatButton.addEventListener('click', () => {
            // Here you would typically open a chat widget
            alert('Our experts will be with you shortly!');
        });
    }

    // Add hover effect to result cards
    const resultCards = document.querySelectorAll('.result-card');
    resultCards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.transform = 'translateY(-10px)';
        });
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'translateY(0)';
        });
    });

    // Visualization Modal
    const modal = document.querySelector('.visualization-modal');
    const modalClose = document.querySelector('.modal-close');
    const uploadBtn = document.querySelector('.upload-room-btn');
    const roomUpload = document.getElementById('room-upload');
    const roomImage = document.querySelector('.room-image');
    const furnitureImage = document.querySelector('.furniture-image');
    const sizeControl = document.getElementById('size-control');
    const rotationControl = document.getElementById('rotation-control');

    // Handle visualization button clicks
    const visualizeButtons = document.querySelectorAll('.visualize-btn');
    visualizeButtons.forEach(button => {
        button.addEventListener('click', () => {
            const furnitureImg = button.closest('.result-card').querySelector('.result-image img').src;
            furnitureImage.src = furnitureImg;
            modal.classList.add('active');
            
            // Reset controls
            sizeControl.value = 100;
            rotationControl.value = 0;
            updateFurnitureTransform();
        });
    });

    // Close modal
    modalClose.addEventListener('click', () => {
        modal.classList.remove('active');
    });

    // Handle room photo upload
    uploadBtn.addEventListener('click', () => {
        roomUpload.click();
    });

    roomUpload.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                roomImage.src = e.target.result;
                roomImage.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    });

    // Furniture drag functionality
    let isDragging = false;
    let currentX;
    let currentY;
    let initialX;
    let initialY;
    let xOffset = 0;
    let yOffset = 0;

    furnitureImage.addEventListener('mousedown', dragStart);
    furnitureImage.addEventListener('touchstart', dragStart);
    document.addEventListener('mousemove', drag);
    document.addEventListener('touchmove', drag);
    document.addEventListener('mouseup', dragEnd);
    document.addEventListener('touchend', dragEnd);

    function dragStart(e) {
        if (e.type === 'mousedown') {
            initialX = e.clientX - xOffset;
            initialY = e.clientY - yOffset;
        } else {
            initialX = e.touches[0].clientX - xOffset;
            initialY = e.touches[0].clientY - yOffset;
        }

        if (e.target === furnitureImage) {
            isDragging = true;
        }
    }

    function drag(e) {
        if (isDragging) {
            e.preventDefault();

            if (e.type === 'mousemove') {
                currentX = e.clientX - initialX;
                currentY = e.clientY - initialY;
            } else {
                currentX = e.touches[0].clientX - initialX;
                currentY = e.touches[0].clientY - initialY;
            }

            xOffset = currentX;
            yOffset = currentY;

            updateFurnitureTransform();
        }
    }

    function dragEnd() {
        isDragging = false;
    }

    // Handle size and rotation controls
    sizeControl.addEventListener('input', updateFurnitureTransform);
    rotationControl.addEventListener('input', updateFurnitureTransform);

    function updateFurnitureTransform() {
        const size = sizeControl.value;
        const rotation = rotationControl.value;
        const scale = size / 100;

        furnitureImage.style.transform = `translate(${xOffset}px, ${yOffset}px) rotate(${rotation}deg) scale(${scale})`;
    }

    // Close modal when clicking outside
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.classList.remove('active');
        }
    });

    // Prevent modal close when clicking inside
    modal.querySelector('.modal-content').addEventListener('click', (e) => {
        e.stopPropagation();
    });

    // Generate additional matches
    const additionalMatches = document.getElementById('additional-matches');
    for (let i = 2; i <= 8; i++) {
        const matchCard = document.createElement('div');
        matchCard.className = 'result-card';
        matchCard.innerHTML = `
            <div class="result-image">
                <img src="https://maisonai.s3-us-west-2.amazonaws.com/inventory/${i}.jpg" alt="Match ${i}">
            </div>
            <div class="result-details">
                <h3>Stylish Comfort Sofa ${i}</h3>
                <div class="match-score">
                    <div class="score-bar">
                        <div class="score-fill" style="width: ${95 - ((i-1) * 5)}%"></div>
                    </div>
                    <span>${95 - ((i-1) * 5)}% Match</span>
                </div>
                <div class="features">
                    <span><i class="fas fa-ruler"></i> 80" × 36" × 32"</span>
                    <span><i class="fas fa-tag"></i> $${(1500 + (i * 100)).toLocaleString()}</span>
                </div>
                <div class="action-buttons">
                    <a href="#" class="view-details-btn">View Details</a>
                    <button class="visualize-btn">
                        <i class="fas fa-camera"></i>
                        View in Your Room
                    </button>
                </div>
            </div>
        `;
        additionalMatches.appendChild(matchCard);
    }
});

function updatePreferenceTags(preferences) {
    const tagsContainer = document.querySelector('.preference-tags');
    tagsContainer.innerHTML = ''; // Clear existing tags

    // Add style tags
    preferences.style.forEach(style => {
        const tag = document.createElement('span');
        tag.className = 'tag style-tag';
        tag.textContent = style.style;
        tagsContainer.appendChild(tag);
    });

    // Add budget tag
    const budgetTag = document.createElement('span');
    budgetTag.className = 'tag budget-tag';
    budgetTag.textContent = `Budget: $${preferences.budget.toLocaleString()}`;
    tagsContainer.appendChild(budgetTag);

    // Add room size tag
    const sizeTag = document.createElement('span');
    sizeTag.className = 'tag size-tag';
    sizeTag.textContent = `Room: ${preferences.space.roomSize}`;
    tagsContainer.appendChild(sizeTag);
} 