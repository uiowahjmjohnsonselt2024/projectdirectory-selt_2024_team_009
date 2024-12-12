// game_channel.js
import consumer from "./consumer";
import * as Turbo from "@hotwired/turbo";

const subscriptions = {};

const handleTurboLoad = () => {
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) {
        console.log("[game_channel.js] No serverElement found, skipping subscription.");
        return;
    }

    const serverId = serverElement.dataset.serverId;

    if (subscriptions[serverId]) {
        console.log(`[game_channel.js] Subscription for server ${serverId} already exists.`);
        return;
    }

    const connectToChannel = () => {
        const cableTokenMeta = document.querySelector('meta[name="cable-token"]');
        if (cableTokenMeta && cableTokenMeta.content) {
            const cableToken = cableTokenMeta.content;
            const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
            consumer.connection.url = `${protocol}://${window.location.hostname}:${window.location.port}/cable?cable_token=${cableToken}`;
            console.log(`[game_channel.js] Connecting to GameChannel for server ${serverId} with URL:`, consumer.connection.url);

            subscriptions[serverId] = consumer.subscriptions.create(
                { channel: "GameChannel", server_id: serverId },
                {
                    connected() {
                        console.log(`[game_channel.js] Successfully connected to GameChannel for server ${serverId}`);
                    },
                    disconnected() {
                        console.log(`[game_channel.js] Disconnected from GameChannel for server ${serverId}.`);
                        delete subscriptions[serverId];
                    },
                    rejected() {
                        console.error(`[game_channel.js] Subscription rejected for server ${serverId}!`);
                        delete subscriptions[serverId];
                    },
                    received(data) {
                        console.log(`[game_channel.js] Received data for server ${serverId}:`, data);
                        try {
                            switch (data.type) {
                                case "turbo_stream":
                                    Turbo.renderStreamMessage(data.message);
                                    break;
                                case "turn_ended":
                                    // Fetch the updated current_turn partial using Turbo Stream
                                    fetch(`/games/${serverId}/current_turn`, { headers: { 'Accept': 'text/vnd.turbo-stream.html' } })
                                        .then(response => response.text())
                                        .then(html => Turbo.renderStreamMessage(html));
                                    break;
                                case "game_started":
                                    // Handle game start (e.g., redirect to the game page)
                                    window.location.href = `/games/${serverId}`;
                                    break;
                                case "page_reload":
                                    // Trigger a full page reload
                                    window.location.reload();
                                    break;
                                case "game_over":
                                    // Handle game over (show modal)
                                    const gameOverModal = new bootstrap.Modal(document.getElementById('gameOverModal'));
                                    if (gameOverModal) { // Check if the modal element exists
                                        if (document.getElementById('winningPlayer')) {
                                            document.getElementById('winningPlayer').innerText = data.winner;
                                        }
                                        if (document.getElementById('cellsOwned')) {
                                            document.getElementById('cellsOwned').innerText = data.stats.cells_owned;
                                        }
                                        if (document.getElementById('finalShards')) {
                                            document.getElementById('finalShards').innerText = data.stats.shards;
                                        }
                                        gameOverModal.show();
                                    }
                                    break;
                                case "waiting_for_players":
                                    const waitingMessageElement = document.getElementById("waiting-message");
                                    if (waitingMessageElement) {
                                        waitingMessageElement.innerHTML = `
                      <h2>${data.message}</h2>
                      <p>Current players: ${data.current_count}/${data.max_players}.</p>
                    `;
                                    }
                                    break;
                                case "all_players_joined":
                                    const waitingMessageElement2 = document.getElementById("waiting-message");
                                    if (waitingMessageElement2) {
                                        waitingMessageElement2.style.display = "none";
                                    }
                                    break;
                                default:
                                    console.log(`[game_channel.js] Unknown data type received: ${data.type}`);
                            }
                        } catch (error) {
                            console.error("Error handling received data:", error);
                        }
                    }
                }
            );
        } else {
            console.error("[game_channel.js] No cable token found. Connection attempt aborted.");
        }
    };

    connectToChannel();
};

document.addEventListener("turbo:load", handleTurboLoad);

document.addEventListener("turbo:before-cache", () => {
    for (const serverId in subscriptions) {
        if (subscriptions.hasOwnProperty(serverId)) {
            console.log(`[game_channel.js] Removing subscription for server ${serverId} before caching.`);
            consumer.subscriptions.remove(subscriptions[serverId]);
            delete subscriptions[serverId];
        }
    }
});

window.addEventListener('beforeunload', () => {
    for (const serverId in subscriptions) {
        if (subscriptions.hasOwnProperty(serverId)) {
            console.log(`[game_channel.js] Removing subscription for server ${serverId} before unload.`);
            consumer.subscriptions.remove(subscriptions[serverId]);
            delete subscriptions[serverId];
        }
    }
});