// controllers/game_actions_controller.js
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
        this.sendAction("move", { direction: event.currentTarget.dataset.direction });
    }

    occupy() {
        this.sendAction("occupy");
    }

    capture() {
        const direction = prompt("Enter direction to capture (Up, Down, Left, Right):");
        if (direction) {
            this.sendAction("capture", { direction });
        }
    }

    useItem() {
        const itemId = prompt("Enter Item ID to use:");
        if (itemId) {
            this.sendAction("use_item", { item_id: itemId });
        }
    }

    useTreasure(){
        const treasureId = prompt("Enter Treasure ID to use:");
        if (treasureId) {
            this.sendAction("use_treasure", { treasure_id: treasureId });
        }
    }

    purchaseItem() {
        const itemId = prompt("Enter Item ID to purchase:");
        if (itemId) {
            this.sendAction("purchase_item", { item_id: itemId });
        }
    }

    sendAction(actionType, extraParams = {}) {
        const gameId = document.querySelector('[data-server-id]').dataset.serverId;
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
            .then(response => {
                if (!response.ok) {
                    return response.json().then(err => { throw new Error(err.message) });
                }
                return response.json();
            })
            .then(data => {
                console.log("Action successful:", data.message);
            })
            .catch(error => {
                console.error("Action failed:", error.message);
                alert(error.message || "An error occurred. Please try again.");
            });
    }
}