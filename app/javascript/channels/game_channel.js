import consumer from "./consumer";
console.log("[game_channel.js] Script loaded");

document.addEventListener("turbo:load", () => {
    console.log("[game_channel.js] turbo:load event fired");
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) {
        console.log("[game_channel.js] No serverElement found, aborting subscription.");
        return;
    }

    const serverId = serverElement.dataset.serverId;
    console.log("[game_channel.js] Subscribing to GameChannel with server_id:", serverId);

    consumer.subscriptions.create({ channel: "GameChannel", server_id: serverId }, {
        received(data) {
            console.log("[game_channel.js] Received data:", data);

            if (data.type === "page_reload") {
                console.log("[game_channel.js] Page reload triggered for reason:", data.reason);
                window.location.reload();
            } else if (data.type === "waiting_for_players") {
                const waitingMessage = document.getElementById("waiting-message");
                if (waitingMessage) {
                    waitingMessage.style.display = "block";
                    waitingMessage.innerHTML = `
                        <h2 class="text-center text-warning">${data.message}</h2>
                        <p class="text-center text-muted">
                          Current players: ${data.current_count}/${data.max_players}
                        </p>
                    `;
                }
            } else if (data.type === "all_players_joined") {
                const waitingMessage = document.getElementById("waiting-message");
                if (waitingMessage) {
                    waitingMessage.style.display = "none";
                }
            } else if (data.type === "game_over") {
                alert(data.message);
                window.location.href = `/servers/${serverId}`;
            } else if (data.type === "update_stats") {
                const gameContainer = document.querySelector("#game-container");
                if (gameContainer) {
                    gameContainer.innerHTML = data.html;
                }
            }
        }
    });
});
