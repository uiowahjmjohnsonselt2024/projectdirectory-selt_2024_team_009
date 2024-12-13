import consumer from "./consumer";
import * as Turbo from "@hotwired/turbo";

const subscriptions = {};

document.addEventListener("turbo:load", () => {
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) return;

    const serverId = serverElement.dataset.serverId;

    if (subscriptions[serverId]) return;

    subscriptions[serverId] = consumer.subscriptions.create(
        { channel: "GameChannel", server_id: serverId },
        {
            connected() {
                console.log(`[game_channel.js] Connected to GameChannel for server ${serverId}`);
            },
            disconnected() {
                console.log(`[game_channel.js] Disconnected from GameChannel for server ${serverId}`);
                delete subscriptions[serverId];
            },
            received(data) {
                console.log(`[game_channel.js] Data received for server ${serverId}:`, data);

                try {
                    if (data.turbo_stream) {
                        const container = document.querySelector("#game-container");
                        if (container) {
                            container.innerHTML = ""; // Clear outdated content
                        }
                        Turbo.renderStreamMessage(data.message);
                    } else {
                        handleCustomMessage(data);
                    }
                } catch (error) {
                    console.error("[game_channel.js] Error processing data:", error);
                }
            },
        }
    );
});

function handleCustomMessage(data) {
    switch (data.type) {
        case "waiting_for_players":
            updateWaitingMessage(data.message, data.current_count, data.max_players);
            break;

        case "all_players_joined":
            hideWaitingMessage();
            Turbo.visit(window.location.href);
            break;

        case "action_performed":
            Turbo.visit(window.location.href);
            break;

        case "turn_ended":
            fetchUpdatedPartial(`/games/${data.server_id}/current_turn`, "current-turn");
            break;

        case "game_over":
            displayGameOverModal(data.winner);
            break;

        default:
            console.warn(`[game_channel.js] Unknown message type: ${data.type}`);
    }
}

function updateWaitingMessage(message, currentCount, maxPlayers) {
    const waitingMessageElement = document.getElementById("waiting-message");
    if (waitingMessageElement) {
        waitingMessageElement.innerHTML = `
      <h2>${message}</h2>
      <p>Current players: ${currentCount}/${maxPlayers}.</p>
    `;
    }
}

function hideWaitingMessage() {
    const waitingMessageElement = document.getElementById("waiting-message");
    if (waitingMessageElement) {
        waitingMessageElement.style.display = "none";
    }
}

function fetchUpdatedPartial(url, targetId) {
    fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
        .then((response) => response.text())
        .then((html) => {
            document.getElementById(targetId).innerHTML = html;
        })
        .catch((error) => console.error(`[game_channel.js] Error fetching partial for ${targetId}:`, error));
}

function displayGameOverModal(winner) {
    const modalElement = document.getElementById("gameOverModal");
    if (modalElement) {
        const winnerElement = modalElement.querySelector("#winner-name");
        if (winnerElement) winnerElement.textContent = winner;

        const modal = new bootstrap.Modal(modalElement);
        modal.show();
    }
}

document.addEventListener("turbo:before-cache", () => {
    for (const serverId in subscriptions) {
        if (subscriptions.hasOwnProperty(serverId)) {
            consumer.subscriptions.remove(subscriptions[serverId]);
            delete subscriptions[serverId];
        }
    }
});