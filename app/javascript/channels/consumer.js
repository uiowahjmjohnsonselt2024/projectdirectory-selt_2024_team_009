// app/javascript/channels/consumer.js
import { createConsumer } from "@rails/actioncable";

let consumer;

document.addEventListener('turbo:load', () => {
    const cableTokenMeta = document.querySelector('meta[name="cable-token"]');
    if (cableTokenMeta && cableTokenMeta.content) {
        const cableToken = cableTokenMeta.content;
        const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
        let url = `${protocol}://${window.location.hostname}`;
        if (window.location.port && window.location.port !== "") {
            url += `:${window.location.port}`;
        }
        url += `/cable?cable_token=${encodeURIComponent(cableToken)}`;

        // ### CHANGED: Create a new consumer with the cable_token in the URL
        consumer = createConsumer(url);
        console.log("Updated ActionCable URL:", url);
    } else {
        console.error("[consumer.js] No cable token found.");
        consumer = createConsumer(); // fallback
    }
});

export default consumer;
