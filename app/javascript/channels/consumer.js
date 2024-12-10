// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable";

const cableURL = process.env.RAILS_ENV === 'production'
    ? 'wss://shards-of-the-grid-team-09.herokuapp.com/cable'
    : 'ws://localhost:3000/cable';

export default createConsumer(cableURL);