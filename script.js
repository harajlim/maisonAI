document.addEventListener('DOMContentLoaded', () => {
    // Handle visualization button clicks - route to viewer
    document.querySelectorAll('.visualize-btn').forEach(button => {
        button.addEventListener('click', () => {
            window.location.href = './viewer.html';
        });
    });
}); 