const fullscreenButton = document.getElementById('game-frame');

fullscreenButton.addEventListener('click', () => {
    const docElm = document.documentElement;

    if (docElm.requestFullscreen) {
        docElm.requestFullscreen();
    } else if (docElm.mozRequestFullScreen) { // Firefox
        docElm.mozRequestFullScreen();
    } else if (docElm.webkitRequestFullscreen) { // Chrome, Safari and Opera
        docElm.webkitRequestFullscreen();
    } else if (docElm.msRequestFullscreen) { // IE/Edge
        docElm.msRequestFullscreen();
    }

    if (screen.orientation) {
        screen.orientation.lock('landscape');
    } else if (screen.lockOrientation) { // Older versions of Chrome
        screen.lockOrientation('landscape');
    }
});