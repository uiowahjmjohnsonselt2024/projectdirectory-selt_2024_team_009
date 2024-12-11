import consumer from "./consumer";

console.log("[game_channel.js] Script loaded");

document.addEventListener("turbo:load", () => {
    console.log("[game_channel.js] turbo:load event fired");

    // Locate the server ID from the HTML element
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) {
        console.log("[game_channel.js] No serverElement found, aborting subscription.");
        return;
    }

    const serverId = serverElement.dataset.serverId;
    console.log("[game_channel.js] Subscribing to GameChannel with server_id:", serverId);

    // Create the subscription
    consumer.subscriptions.create(
        { channel: "GameChannel", server_id: serverId },
        {
            connected() {
                console.log("[game_channel.js] Successfully connected to GameChannel");
            },
            disconnected() {
                console.log("[game_channel.js] Disconnected from GameChannel");
            },
            rejected() {
                console.error("[game_channel.js] Subscription rejected!");
            },
            received(data) {
                console.log("[game_channel.js] Received data:", data);

                // Handle incoming data types
                switch (data.type) {
                    case "page_reload":
                        console.log("[game_channel.js] Page reload triggered for reason:", data.reason);
                        window.location.reload();
                        break;

                    case "waiting_for_players":
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
                        break;

                    case "all_players_joined":
                        const waitingMsg = document.getElementById("waiting-message");
                        if (waitingMsg) {
                            waitingMsg.style.display = "none";
                        }
                        break;

                    case "game_over":
                        alert(data.message);
                        window.location.href = `/servers/${serverId}`;
                        break;

                    case "update_stats":
                        const gameContainer = document.querySelector("#game-container");
                        if (gameContainer) {
                            gameContainer.innerHTML = data.html;
                        }
                        break;

                    default:
                        console.warn("[game_channel.js] Unknown data type received:", data.type);
                        break;
                }
            }
        }
    );
});
