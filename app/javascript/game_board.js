document.addEventListener('DOMContentLoaded', function() {
    const gameBoard = document.querySelector('.dynamic-background');
    if (gameBoard) {
        const backgroundUrl = 'https://t.ly/oJnOx'; // Example URL
        console.log(`Setting background to: ${backgroundUrl}`);
        gameBoard.style.backgroundImage = `url(${backgroundUrl})`;
        gameBoard.style.backgroundSize = 'cover';
        gameBoard.style.backgroundPosition = 'center';
        gameBoard.style.backgroundRepeat = 'no-repeat';
    } else {
        console.error('Game board not found in DOM.');
    }
});

