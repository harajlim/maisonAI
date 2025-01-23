document.addEventListener('DOMContentLoaded', () => {
    const clientProfiles = document.querySelector('.client-profiles');
    const profileModal = document.querySelector('.profile-modal');
    const modalClose = document.querySelector('.modal-close');
    const statusFilter = document.getElementById('status-filter');
    const searchInput = document.getElementById('search-input');
    const feedbackInput = document.getElementById('feedback-input');
    const submitFeedbackBtn = document.querySelector('.submit-feedback');

    let currentProfileId = null;
    let profiles = [];

    // Load profiles from localStorage (in a real app, this would be from a server)
    function loadProfiles() {
        const quizResults = localStorage.getItem('quizResults');
        if (quizResults) {
            profiles = [JSON.parse(quizResults)];
            renderProfiles(profiles);
        }
    }

    // Render profile cards
    function renderProfiles(profilesToRender) {
        clientProfiles.innerHTML = profilesToRender.map(profile => `
            <div class="profile-card" data-id="${profile.id}">
                <div class="profile-header">
                    <span class="profile-id">Client #${profile.id}</span>
                    <span class="status-badge ${profile.designerFeedback.status === 'pending' ? 'status-pending' : 'status-reviewed'}">
                        ${profile.designerFeedback.status === 'pending' ? 'Pending Review' : 'Reviewed'}
                    </span>
                </div>
                <div class="profile-summary">
                    <div class="summary-item">
                        <span class="summary-label">Style:</span>
                        <span>${profile.preferences.style}</span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Room Size:</span>
                        <span>${profile.preferences.roomSize.value} ${profile.preferences.roomSize.unit}</span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Budget:</span>
                        <span>$${profile.budget.amount}</span>
                    </div>
                </div>
                <button class="view-profile-btn" onclick="viewProfile(${profile.id})">View Full Profile</button>
            </div>
        `).join('');
    }

    // View full profile
    window.viewProfile = (profileId) => {
        currentProfileId = profileId;
        const profile = profiles.find(p => p.id === profileId);
        if (!profile) return;

        // Populate modal with profile details
        document.getElementById('style-details').innerHTML = `
            <p><strong>Style Preference:</strong> ${profile.preferences.style}</p>
        `;

        document.getElementById('space-details').innerHTML = `
            <p><strong>Room Size:</strong> ${profile.preferences.roomSize.value} ${profile.preferences.roomSize.unit}</p>
            <p><strong>Placement:</strong> ${profile.preferences.placement}</p>
            <p><strong>Dimensions:</strong> ${profile.preferences.dimensions.width}" × ${profile.preferences.dimensions.depth}" × ${profile.preferences.dimensions.height}"</p>
        `;

        document.getElementById('usage-details').innerHTML = `
            <p><strong>Primary Uses:</strong> ${profile.usage.primaryUses.join(', ')}</p>
            <p><strong>Seating Capacity:</strong> ${profile.usage.seatingCapacity}</p>
            <p><strong>Has Pets:</strong> ${profile.usage.hasPets}</p>
        `;

        document.getElementById('budget-details').innerHTML = `
            <p><strong>Budget:</strong> $${profile.budget.amount}</p>
            <p><strong>Payment Method:</strong> ${profile.budget.paymentMethod}</p>
        `;

        feedbackInput.value = profile.designerFeedback.feedback || '';
        profileModal.classList.add('active');
    };

    // Filter profiles
    function filterProfiles() {
        const statusValue = statusFilter.value;
        const searchValue = searchInput.value.toLowerCase();

        const filtered = profiles.filter(profile => {
            const matchesStatus = statusValue === 'all' || profile.designerFeedback.status === statusValue;
            const matchesSearch = profile.id.toString().includes(searchValue) ||
                                profile.preferences.style.toLowerCase().includes(searchValue);
            return matchesStatus && matchesSearch;
        });

        renderProfiles(filtered);
    }

    // Submit feedback
    submitFeedbackBtn.addEventListener('click', () => {
        const profile = profiles.find(p => p.id === currentProfileId);
        if (!profile) return;

        profile.designerFeedback = {
            status: 'reviewed',
            feedback: feedbackInput.value,
            timestamp: new Date().toISOString()
        };

        // Update localStorage
        localStorage.setItem('quizResults', JSON.stringify(profile));
        
        // Close modal and refresh profiles
        profileModal.classList.remove('active');
        loadProfiles();
    });

    // Event listeners
    modalClose.addEventListener('click', () => {
        profileModal.classList.remove('active');
    });

    statusFilter.addEventListener('change', filterProfiles);
    searchInput.addEventListener('input', filterProfiles);

    // Close modal when clicking outside
    profileModal.addEventListener('click', (e) => {
        if (e.target === profileModal) {
            profileModal.classList.remove('active');
        }
    });

    // Initial load
    loadProfiles();
}); 