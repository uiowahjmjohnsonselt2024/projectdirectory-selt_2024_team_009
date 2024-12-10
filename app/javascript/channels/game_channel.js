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
            if (data.type === "waiting_for_players") {
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
            } else if (data.type === "player_joined") {
                console.log("[game_channel.js] player_joined event received. Updating opponents.");
                const opponentDetails = document.querySelector("#opponent-details");
                if (opponentDetails && data.html) {
                    opponentDetails.innerHTML = data.html;
                }
            } else if (data.type === "opponent_stats_updated") {
                const opponentDetails = document.querySelector("#opponent-details");
                if (opponentDetails && data.html) {
                    opponentDetails.innerHTML = data.html;
                }
            } else if (data.type === "player_stats_updated") {
                const playerStats = document.querySelector("#player-stats");
                if (playerStats && data.html) {
                    playerStats.innerHTML = data.html;
                }
            } else if (data.type === "game_started") {
                // If needed, you can handle game_started differently,
                // but currently, we rely on 'all_players_joined' to enable gameplay.
                const waitingMessage = document.getElementById("waiting-message");
                if (waitingMessage) {
                    waitingMessage.style.display = "none";
                }
            } else if (data.type === "game_over") {
                alert(data.message);
                window.location.href = `/servers/${serverId}`;
            } else if (data.type === "update_stats") {
                if (data.opponents_html) {
                    const opponentDetails = document.querySelector("#opponent-details");
                    if (opponentDetails) opponentDetails.innerHTML = data.opponents_html;
                }
                if (data.player_stats_html) {
                    const playerStats = document.querySelector("#player-stats");
                    if (playerStats) playerStats.innerHTML = data.player_stats_html;
                }
            }
        }
    });
});
