// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.
import { createConsumer } from "@rails/actioncable";
// Read the cable_token from the meta tag
const cableTokenMeta = document.querySelector('meta[name="cable-token"]')
const cableToken = cableTokenMeta ? cableTokenMeta.getAttribute('content') : null

if (!cableToken) {
    console.error("[consumer.js] No cable token found. WebSocket connection will not be authenticated.")
}
else {
    console.log("[consumer.js] Cable token found:", cableToken)
}// Dynamically determine the WebSocket URL based on the environment
const cableURL = window.location.hostname === 'shards-of-the-grid-team-09.herokuapp.com'
    ? `wss://shards-of-the-grid-team-09.herokuapp.com/cable?cable_token=${cableToken}`
    : `ws://localhost:3000/cable?cable_token=${cableToken}`;

// Create the consumer with the generated URL
export default createConsumer(cableURL);
