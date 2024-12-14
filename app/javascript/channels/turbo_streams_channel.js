import consumer from "./consumer";
import * as Turbo from "@hotwired/turbo";

const subscriptions = {};

document.addEventListener("turbo:load", () => {
    const serverElement = document.querySelector("[data-server-id]");
    if (!serverElement) return;

    const serverId = serverElement.dataset.serverId;

    if (subscriptions[serverId]) return;

    subscriptions[serverId] = consumer.subscriptions.create(
        { channel: "TurboStreamsChannel", server_id: serverId },
        {
            connected() {
                console.log(`[turbo_streams_channel.js] Connected to TurboStreamsChannel for server ${serverId}`);
            },
            disconnected() {
                console.log(`[turbo_streams_channel.js] Disconnected from TurboStreamsChannel for server ${serverId}`);
                delete subscriptions[serverId];
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
            },
        }
    );
});

document.addEventListener("turbo:before-cache", () => {
    for (const serverId in subscriptions) {
        if (subscriptions.hasOwnProperty(serverId)) {
            consumer.subscriptions.remove(subscriptions[serverId]);
            delete subscriptions[serverId];
        }
    }
});

document.querySelectorAll('.movement-button').forEach(button => {
    button.addEventListener('click', (event) => {
        console.log('Movement button clicked:', event.target.dataset.direction);
        // Existing logic to handle movement
    });
});