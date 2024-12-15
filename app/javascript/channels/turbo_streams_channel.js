import consumer from "./consumer";
import * as Turbo from "@hotwired/turbo";

const subscriptions = {};

document.addEventListener("turbo:load", () => {
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) return;

    const serverId = serverElement.dataset.serverId;

    // Prevent duplicate subscriptions
    if (subscriptions[serverId]) return;

    // Create a subscription for TurboStreamsChannel
    subscriptions[serverId] = consumer.subscriptions.create(
        { channel: "TurboStreamsChannel", server_id: serverId },
        {
            connected() {
                console.log(`[turbo_streams_channel.js] Connected to TurboStreamsChannel for server ${serverId}`);
            },
            disconnected() {
                console.warn(`[turbo_streams_channel.js] Disconnected from TurboStreamsChannel for server ${serverId}`);
                delete subscriptions[serverId];
                reconnectSubscription(serverId);
            },
            received(data) {
                console.log(`[turbo_streams_channel.js] Data received for server ${serverId}:`, data);

                try {
                    if (data.turbo_stream) {
                        console.log("Turbo Stream message:", data.turbo_stream);
                        Turbo.renderStreamMessage(data.turbo_stream);
                    } else {
                        console.warn(`[turbo_streams_channel.js] Unknown data format received:`, data);
                    }
                } catch (error) {
                    console.error("[turbo_streams_channel.js] Error processing data:", error);
                }
            }
        }
    );

    // Handle WebSocket reconnections
    handleWebSocketReconnection();
});

document.addEventListener("turbo:before-cache", () => {
    // Unsubscribe all channels before navigating away
    for (const serverId in subscriptions) {
        if (subscriptions.hasOwnProperty(serverId)) {
            consumer.subscriptions.remove(subscriptions[serverId]);
            delete subscriptions[serverId];
        }
    }
});

/**
 * Graceful handling of WebSocket reconnections.
 */
function handleWebSocketReconnection() {
    setInterval(() => {
        if (!consumer.connection.isOpen()) {
            console.warn("WebSocket disconnected. Attempting to reconnect...");
            consumer.connection.open();
        }
    }, 5000);
}

/**
 * Example: Custom event listener for action buttons.
 * Update or extend this if required for your specific setup.
 */
document.querySelectorAll(".btn-game-action, .btn-game-movement").forEach(button => {
    button.addEventListener("click", (event) => {
        console.log("Game action button clicked:", event.target.dataset);
        // Add any custom logic here if needed
    });
});
function reconnectSubscription(serverId) {
    setTimeout(() => {
        console.log(`[turbo_streams_channel.js] Attempting to reconnect to server ${serverId}`);
        const serverElement = document.querySelector(`[data-server-id="${serverId}"]`);
        if (serverElement) {
            subscriptions[serverId] = consumer.subscriptions.create(
                { channel: "TurboStreamsChannel", server_id: serverId },
                {
                    connected() {
                        console.log(`[turbo_streams_channel.js] Reconnected to TurboStreamsChannel for server ${serverId}`);
                    },
                    disconnected() {
                        console.warn(`[turbo_streams_channel.js] Disconnected again from TurboStreamsChannel for server ${serverId}`);
                        delete subscriptions[serverId];
                        reconnectSubscription(serverId);
                    },
                    received(data) {
                        console.log(`[turbo_streams_channel.js] Data received after reconnection for server ${serverId}:`, data);
                        try {
                            if (data.turbo_stream) {
                                Turbo.renderStreamMessage(data.turbo_stream);
                            }
                        } catch (error) {
                            console.error("[turbo_streams_channel.js] Error processing data after reconnection:", error);
                        }
                    }
                }
            );
        }
    }, 5000); // Retry after 5 seconds
}