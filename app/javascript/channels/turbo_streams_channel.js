import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const serverId = document.querySelector('[data-server-id]').dataset.serverId;

  consumer.subscriptions.create({ channel: "TurboStreamsChannel", server_id: serverId }, {
    received(data) {
      // Handle the received data
      const element = document.getElementById(data.target);
      if (element) {
        element.outerHTML = data.html;
      }
    }
  });
});