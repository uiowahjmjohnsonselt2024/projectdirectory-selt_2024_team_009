// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable";

// Set the WebSocket URL based on the environment
const cableURL = process.env.NODE_ENV === 'production'
    ? 'wss://shards-of-the-grid-team-09.herokuapp.com/cable' // Production WebSocket URL
    : 'ws://localhost:3000/cable'; // Development WebSocket URL

export default createConsumer(cableURL);
