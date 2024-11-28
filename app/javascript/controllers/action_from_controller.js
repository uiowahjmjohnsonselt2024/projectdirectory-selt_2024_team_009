// app/javascript/controllers/action_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["actionType", "actionDetails", "moveCaptureFields", "useItemFields", "purchaseItemFields", "selectedItem", "targetUserId", "targetX", "targetY"];

    connect() {
        this.updateActionDetails();
    }

    updateActionDetails() {
        const actionType = this.actionTypeTarget.value;
        this.hideAllFields();

        switch (actionType) {
            case 'move':
            case 'occupy':
            case 'capture':
                this.moveCaptureFieldsTarget.style.display = 'block';
                break;
            case 'use_item':
                this.useItemFieldsTarget.style.display = 'block';
                break;
            case 'purchase_item':
                this.purchaseItemFieldsTarget.style.display = 'block';
                break;
            default:
                break;
        }
    }

    updateUseItemFields() {
        const selectedItem = this.selectedItemTarget.options[this.selectedItemTarget.selectedIndex].text;

        if (selectedItem.includes('Swap') || selectedItem.includes('AP Stealer') || selectedItem.includes('Time Skip Device')) {
            this.targetUserIdTarget.style.display = 'block';
            this.coordinateFields(false);
        } else if (selectedItem.includes('Teleportation Scroll') || selectedItem.includes('Fortification Kit') || selectedItem.includes('Obstacle Remover')) {
            this.coordinateFields(true);
            this.targetUserIdTarget.style.display = 'none';
        } else {
            this.coordinateFields(false);
            this.targetUserIdTarget.style.display = 'none';
        }
    }

    coordinateFields(show) {
        if (show) {
            this.targetXTarget.parentElement.style.display = 'block';
            this.targetYTarget.parentElement.style.display = 'block';
        } else {
            this.targetXTarget.parentElement.style.display = 'none';
            this.targetYTarget.parentElement.style.display = 'none';
        }
    }

    hideAllFields() {
        this.moveCaptureFieldsTarget.style.display = 'none';
        this.useItemFieldsTarget.style.display = 'none';
        this.purchaseItemFieldsTarget.style.display = 'none';
        this.coordinateFields(false);
        this.targetUserIdTarget.style.display = 'none';
    }
}
