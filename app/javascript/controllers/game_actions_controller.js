import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        console.log("GameActionsController connected");
    }

    move(event) {
        const direction = event.currentTarget.dataset.direction;
        console.log(`Move triggered in direction: ${direction}`);
        this.sendAction("move", { direction });
    }

    occupy() {
        console.log("Occupy action triggered");
        this.sendAction("occupy");
    }

    capture() {
        const direction = prompt("Enter direction to capture (Up, Down, Left, Right):");
        if (direction) {
            console.log(`Capture action triggered in direction: ${direction}`);
            this.sendAction("capture", { direction });
        }
    }

    useItem() {
        const itemId = prompt("Enter Item ID to use:");
        if (itemId) {
            console.log(`Use Item action triggered. Item ID: ${itemId}`);
            this.sendAction("use_item", { item_id: itemId });
        }
    }

    purchaseItem() {
        const itemId = prompt("Enter Item ID to purchase:");
        if (itemId) {
            console.log(`Purchase Item action triggered. Item ID: ${itemId}`);
            this.sendAction("purchase_item", { item_id: itemId });
        }
    }

    sendAction(actionType, extraParams = {}) {
        const gameId = this.gameId;
        const csrfToken = document.querySelector("meta[name='csrf-token']").content;

        fetch(`/games/${gameId}/perform_action`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({ action_type: actionType, ...extraParams }),
        })
            .then((response) => response.json())
            .then((data) => {
                if (data.success) {
                    console.log("Action successful:", data.message);
                    window.location.reload();
                } else {
                    console.error("Action failed:", data.message);
                    alert(data.message || "Action failed.");
                }
            })
            .catch((error) => {
                console.error("Error occurred:", error);
                alert("An error occurred. Please try again.");
            });
    }

    get gameId() {
        return window.location.pathname.split("/")[2];
    }
}
