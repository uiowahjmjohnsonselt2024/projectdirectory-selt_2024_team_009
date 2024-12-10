import consumer from "./cable";

const createChatChannel = (gameId) => {
    return consumer.subscriptions.create(
        { channel: "ChatChannel", game_id: gameId },
        {
            connected() {
                console.log("Connected to chat channel for game", gameId);
            },
            disconnected() {
                console.log("Disconnected from chat channel");
            },
            received(data) {
                const messagesContainer = document.getElementById("messages");
                messagesContainer.insertAdjacentHTML("beforeend", data.message);
            },
            speak(message) {
                this.perform("speak", { message: message });
            },
        }
    );
};

export default createChatChannel;
