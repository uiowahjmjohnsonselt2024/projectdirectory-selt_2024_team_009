import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
    static targets = ["error"];

    connect() {
        console.log("GameActionsController connected");

        this.element.addEventListener("click", (event) => {
            if (event.target.matches("[data-action='move']")) {
                this.move(event);
            } else if (event.target.matches("[data-action='occupy']")) {
                this.occupy();
            } else if (event.target.matches("[data-action='capture']")) {
                this.capture();
            } else if (event.target.matches("[data-action='use_item']")) {
                this.useItem();
            } else if (event.target.matches("[data-action='use_treasure']")) {
                this.useTreasure();
            } else if (event.target.matches("[data-action='purchase_item']")) {
                this.purchaseItem();
            }
        });
    }

    move(event) {
        const direction = event.currentTarget.dataset.direction;
        if (!direction) {
            console.error("[game_actions_controller.js] Move action missing direction.");
            alert("Direction is required to perform this action.");
            return;
        }
        this.sendAction("move", { direction });
    }

    occupy() {
        this.sendAction("occupy");
    }

    capture() {
        const direction = prompt("Enter direction to capture (Up, Down, Left, Right):");
        if (!direction) {
            console.warn("[game_actions_controller.js] Capture action canceled by the user.");
            return;
        }
        this.sendAction("capture", { direction });
    }

    useItem() {
        const itemId = prompt("Enter Item ID to use:");
        if (!itemId) {
            console.warn("[game_actions_controller.js] Use item action canceled by the user.");
            return;
        }
        this.sendAction("use_item", { item_id: itemId });
    }

    useTreasure() {
        const treasureId = prompt("Enter Treasure ID to use:");
        if (!treasureId) {
            console.warn("[game_actions_controller.js] Use treasure action canceled by the user.");
            return;
        }
        this.sendAction("use_treasure", { treasure_id: treasureId });
    }

    purchaseItem() {
        const itemId = prompt("Enter Item ID to purchase:");
        if (!itemId) {
            console.warn("[game_actions_controller.js] Purchase item action canceled by the user.");
            return;
        }
        this.sendAction("purchase_item", { item_id: itemId });
    }

    sendAction(actionType, extraParams = {}) {
        const gameId = document.querySelector('[data-server-id]')?.dataset.serverId;
        if (!gameId) {
            console.error("[game_actions_controller.js] Game ID not found.");
            alert("Game ID is missing. Cannot perform the action.");
            return;
        }

        const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
        if (!csrfToken) {
            console.error("[game_actions_controller.js] CSRF token not found.");
            alert("Security token is missing. Cannot perform the action.");
            return;
        }

        fetch(`/games/${gameId}/perform_action`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Accept: "application/json",
                "X-CSRF-Token": csrfToken,
            },
            body: JSON.stringify({ action_type: actionType, ...extraParams }),
        })
            .then((response) => {
                if (!response.ok) {
                    return response.json().then((err) => {
                        throw new Error(err.message);
                    });
                }
                return response.json();
            })
            .then((data) => {
                console.log("Action successful:", data.message);
            })
            .catch((error) => {
                console.error("Action failed:", error.message);
                alert(error.message || "An error occurred. Please try again.");
            });
    }
}
