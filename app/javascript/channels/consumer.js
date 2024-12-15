// app/javascript/channels/consumer.js
import { createConsumer } from "@rails/actioncable";

const consumer = createConsumer();

document.addEventListener('turbo:load', () => {
    const cableTokenMeta = document.querySelector('meta[name="cable-token"]');
    if (cableTokenMeta && cableTokenMeta.content) {
        const cableToken = cableTokenMeta.content;
        const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
        let url = `${protocol}://${window.location.hostname}`;
        if (window.location.port && window.location.port !== "") {
            url += `:${window.location.port}`;
        }
        url += `/cable?cable_token=${cableToken}`;
        consumer.connection.url = url;
        console.log("Updated ActionCable URL:", consumer.connection.url);
    } else {
        console.error("[consumer.js] No cable token found.");
    }
});

export default consumer;
