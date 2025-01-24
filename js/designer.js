document.addEventListener('DOMContentLoaded', () => {
    // Load all client profiles from localStorage
    const profiles = [];
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key.startsWith('quizPreferences')) {
            try {
                const profile = JSON.parse(localStorage.getItem(key));
                profiles.push({
                    id: key,
                    ...profile
                });
            } catch (e) {
                console.error('Error parsing profile:', e);
            }
        }
    }

    // Sort profiles by timestamp, newest first
    profiles.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    // Populate client profiles
    const clientProfilesContainer = document.querySelector('.client-profiles');
    profiles.forEach(profile => {
        const profileCard = createProfileCard(profile);
        clientProfilesContainer.appendChild(profileCard);
    });

    // Handle profile modal
    const modal = document.querySelector('.profile-modal');
    const closeBtn = modal.querySelector('.modal-close');

    closeBtn.addEventListener('click', () => {
        modal.style.display = 'none';
    });

    // Close modal when clicking outside
    window.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });
});

function createProfileCard(profile) {
    const card = document.createElement('div');
    card.className = 'profile-card';
    
    const formattedDate = new Date(profile.timestamp).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });

    const dimensionsDisplay = profile.space.dimensions.width || profile.space.dimensions.depth ? 
        `<p><strong>Dimensions:</strong> ${profile.space.dimensions.width || 'N/A'}" × ${profile.space.dimensions.depth || 'N/A'}"</p>` : '';

    card.innerHTML = `
        <div class="profile-header">
            <div class="profile-timestamp">
                <i class="fas fa-clock"></i>
                ${formattedDate}
            </div>
            <div class="profile-status pending">
                Pending Review
            </div>
        </div>
        <div class="profile-content">
            <div class="profile-section">
                <h3>Style Preferences</h3>
                <div class="style-chart">
                    ${profile.style.map(style => `
                        <div class="style-bar">
                            <span class="style-name">${style.style}</span>
                            <div class="bar-container">
                                <div class="bar-fill" style="width: ${style.preference}%"></div>
                            </div>
                            <span class="style-percentage">${Math.round(style.preference)}%</span>
                        </div>
                    `).join('')}
                </div>
            </div>
            <div class="profile-section">
                <h3>Space Details</h3>
                <div class="space-info">
                    <p><strong>Room Size:</strong> ${profile.space.roomSize}</p>
                    ${dimensionsDisplay}
                </div>
            </div>
            <div class="profile-section">
                <h3>Preferences</h3>
                <div class="preferences-grid">
                    <div class="preference-group">
                        <h4>Colors</h4>
                        <div class="tags">
                            ${profile.colors.map(color => `<span class="tag">${color}</span>`).join('')}
                        </div>
                    </div>
                    <div class="preference-group">
                        <h4>Comfort</h4>
                        <div class="tags">
                            ${profile.comfort.map(comfort => `<span class="tag">${comfort}</span>`).join('')}
                        </div>
                    </div>
                    <div class="preference-group">
                        <h4>Features</h4>
                        <div class="tags">
                            ${profile.features.map(feature => `<span class="tag">${feature}</span>`).join('')}
                        </div>
                    </div>
                </div>
            </div>
            <div class="profile-section">
                <h3>Budget</h3>
                <p class="budget-amount">$${profile.budget.toLocaleString()}</p>
            </div>
            
            <div class="profile-section">
                <h3>Recommended Products</h3>
                <div class="results-carousel">
                    ${[1, 2, 3, 4, 5, 6, 7, 8].map(i => `
                        <div class="carousel-item">
                            <img src="https://maisonai.s3-us-west-2.amazonaws.com/inventory/${i}.jpg" alt="Recommended Product ${i}">
                            <div class="match-percentage">${95 - ((i-1) * 5)}% Match</div>
                        </div>
                    `).join('')}
                </div>
            </div>
            
            ${profile.roomImages ? `
                <div class="profile-section">
                    <h3>Room Photos</h3>
                    <div class="room-photos">
                        ${profile.roomImages.map((img, index) => `
                            <div class="room-photo">
                                <img src="${img}" alt="Room photo ${index + 1}">
                            </div>
                        `).join('')}
                    </div>
                </div>
            ` : ''}
        </div>
        <div class="profile-actions">
            <button class="review-btn" onclick="showProfileDetails(${JSON.stringify(profile).replace(/"/g, '&quot;')})">
                Review Profile
            </button>
        </div>
    `;

    return card;
}

function showProfileDetails(profile) {
    const modal = document.querySelector('.profile-modal');
    
    // Create a more comprehensive modal content structure
    const modalContent = `
        <div class="profile-details">
            <h2>Client Profile Review</h2>
            <div class="profile-info">
                <div class="info-section">
                    <h3>Style Preferences</h3>
                    <div id="style-details"></div>
                </div>
                <div class="info-section">
                    <h3>Space Information</h3>
                    <div id="space-details"></div>
                    ${profile.roomImages && profile.roomImages.length > 0 ? `
                        <div class="room-photos-section">
                            <h4>Room Photos</h4>
                            <div class="room-photos">
                                ${profile.roomImages.map((img, index) => `
                                    <div class="room-photo">
                                        <img src="${img}" alt="Room photo ${index + 1}">
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}
                </div>
                <div class="info-section">
                    <h3>Preferences</h3>
                    <div id="usage-details"></div>
                </div>
                <div class="info-section">
                    <h3>Budget</h3>
                    <div id="budget-details"></div>
                </div>
            </div>

            <div class="recommendations-section">
                <h3>Recommended Products</h3>
                <div class="recommendations-grid">
                    ${[1, 2, 3, 4, 5, 6, 7, 8].map(i => `
                        <div class="recommendation-card" data-product-id="${i}">
                            <img src="https://maisonai.s3-us-west-2.amazonaws.com/inventory/${i}.jpg" alt="Product ${i}">
                            <div class="recommendation-details">
                                <span class="match-score">${95 - ((i-1) * 5)}% Match</span>
                                <button class="add-to-feedback-btn" type="button">Add to Feedback</button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>

            <div class="feedback-section">
                <h3>Designer Feedback</h3>
                <div class="selected-recommendations">
                    <h4>Selected Products</h4>
                    <div id="selected-products" class="selected-products-grid"></div>
                </div>
                <textarea id="feedback-input" placeholder="Enter your professional feedback and recommendations..."></textarea>
                <button class="submit-feedback">Submit Feedback</button>
            </div>
        </div>
    `;

    modal.querySelector('.modal-content').innerHTML = modalContent;

    // Populate the sections
    document.getElementById('style-details').innerHTML = createStyleDetailsHTML(profile.style);
    document.getElementById('space-details').innerHTML = createSpaceDetailsHTML(profile.space);
    document.getElementById('usage-details').innerHTML = createUsageDetailsHTML(profile);
    document.getElementById('budget-details').innerHTML = createBudgetDetailsHTML(profile.budget);

    // Add lightbox functionality to room photos
    const lightbox = document.createElement('div');
    lightbox.className = 'lightbox';
    lightbox.innerHTML = `
        <button class="lightbox-close">&times;</button>
        <img src="" alt="Room photo enlarged">
    `;
    document.body.appendChild(lightbox);

    const roomPhotos = document.querySelectorAll('.room-photo img');
    const lightboxImg = lightbox.querySelector('img');
    const lightboxClose = lightbox.querySelector('.lightbox-close');

    roomPhotos.forEach(photo => {
        photo.addEventListener('click', () => {
            lightboxImg.src = photo.src;
            lightbox.classList.add('active');
        });
    });

    lightboxClose.addEventListener('click', () => {
        lightbox.classList.remove('active');
    });

    lightbox.addEventListener('click', (e) => {
        if (e.target === lightbox) {
            lightbox.classList.remove('active');
        }
    });

    // Handle recommendation selection
    const recommendationCards = document.querySelectorAll('.recommendation-card');
    recommendationCards.forEach(card => {
        const addButton = card.querySelector('.add-to-feedback-btn');
        addButton.addEventListener('click', (e) => {
            e.stopPropagation(); // Prevent event bubbling
            const productId = card.dataset.productId;
            const matchPercentage = card.querySelector('.match-score').textContent;
            addProductToFeedback(productId, matchPercentage);
        });
    });

    modal.style.display = 'block';
}

function createStyleDetailsHTML(styles) {
    return `
        <div class="style-chart-detailed">
            ${styles.map(style => `
                <div class="style-bar">
                    <span class="style-name">${style.style}</span>
                    <div class="bar-container">
                        <div class="bar-fill" style="width: ${style.preference}%"></div>
                    </div>
                    <span class="style-percentage">${Math.round(style.preference)}%</span>
                </div>
            `).join('')}
        </div>
    `;
}

function createSpaceDetailsHTML(space) {
    const dimensionsDisplay = space.dimensions.width || space.dimensions.depth ? 
        `<p><strong>Dimensions:</strong></p>
        <ul>
            ${space.dimensions.width ? `<li>Width: ${space.dimensions.width}"</li>` : ''}
            ${space.dimensions.depth ? `<li>Depth: ${space.dimensions.depth}"</li>` : ''}
        </ul>` : '';

    return `
        <div class="space-details">
            <p><strong>Room Size:</strong> ${space.roomSize}</p>
            ${dimensionsDisplay}
        </div>
    `;
}

function createUsageDetailsHTML(profile) {
    return `
        <div class="usage-details">
            <div class="preference-section">
                <h4>Comfort Preferences</h4>
                <div class="tags">
                    ${profile.comfort.map(c => `<span class="tag">${c}</span>`).join('')}
                </div>
            </div>
            <div class="preference-section">
                <h4>Desired Features</h4>
                <div class="tags">
                    ${profile.features.map(f => `<span class="tag">${f}</span>`).join('')}
                </div>
            </div>
            <div class="preference-section">
                <h4>Color Preferences</h4>
                <div class="tags">
                    ${profile.colors.map(c => `<span class="tag">${c}</span>`).join('')}
                </div>
            </div>
        </div>
    `;
}

function createBudgetDetailsHTML(budget) {
    return `
        <div class="budget-details">
            <h4>Maximum Budget</h4>
            <p class="budget-amount">$${budget.toLocaleString()}</p>
        </div>
    `;
}

function addProductToFeedback(productId, matchPercentage) {
    const selectedProducts = document.getElementById('selected-products');
    const existingProduct = selectedProducts.querySelector(`[data-product-id="${productId}"]`);
    
    if (!existingProduct) {
        const productElement = document.createElement('div');
        productElement.className = 'selected-product';
        productElement.dataset.productId = productId;
        productElement.innerHTML = `
            <img src="https://maisonai.s3-us-west-2.amazonaws.com/inventory/${productId}.jpg" alt="Selected Product ${productId}">
            <div class="product-details">
                <span class="match-score">${matchPercentage}</span>
                <button class="remove-product" onclick="removeProductFromFeedback('${productId}')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;
        selectedProducts.appendChild(productElement);
        
        // Add to feedback textarea
        const feedback = document.getElementById('feedback-input');
        feedback.value += `\nRecommended Product ${productId} (${matchPercentage})\n`;
    }
}

function removeProductFromFeedback(productId) {
    const selectedProducts = document.getElementById('selected-products');
    const product = selectedProducts.querySelector(`[data-product-id="${productId}"]`);
    if (product) {
        product.remove();
        
        // Remove from feedback textarea
        const feedback = document.getElementById('feedback-input');
        const regex = new RegExp(`\\nRecommended Product ${productId}.*\\n`, 'g');
        feedback.value = feedback.value.replace(regex, '\n');
    }
} 