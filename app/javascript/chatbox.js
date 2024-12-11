import createChatChannel from "../channels/chat_channel";

document.addEventListener("DOMContentLoaded", () => {
    const chatboxElement = document.getElementById("chatbox");
    if (chatboxElement) {
        const gameId = chatboxElement.dataset.gameId;
        const chatChannel = createChatChannel(gameId);

        const chatForm = document.getElementById("chat-form");
        chatForm.addEventListener("submit", (e) => {
            e.preventDefault();
            const chatInput = document.getElementById("chat-input");
            const message = chatInput.value.trim();
            if (message) {
                chatChannel.speak(message);
                chatInput.value = "";
            }
        });
    }
});
