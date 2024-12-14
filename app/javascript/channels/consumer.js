// consumer.js
import { createConsumer } from "@rails/actioncable";

const consumer = createConsumer();

document.addEventListener('turbo:load', () => {
    const cableTokenMeta = document.querySelector('meta[name="cable-token"]');
    if (cableTokenMeta && cableTokenMeta.content) {
        const cableToken = cableTokenMeta.content;
        const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
        consumer.connection.url = `${protocol}://${window.location.hostname}:${window.location.port}/cable?cable_token=${cableToken}`;
        console.log("Updated ActionCable URL:", consumer.connection.url);
    } else {
        console.error("[consumer.js] No cable token found.");
    }
});


export default consumer;