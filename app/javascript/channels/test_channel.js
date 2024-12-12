import consumer from "./consumer";

consumer.subscriptions.create("TestChannel", {
    connected() {
        console.log("Connected to TestChannel!");
    },
    received(data) {
        console.log("Received:", data);
    }
});