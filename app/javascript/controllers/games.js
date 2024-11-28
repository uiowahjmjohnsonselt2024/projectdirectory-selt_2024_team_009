document.addEventListener('DOMContentLoaded', () => {
    const actionTypeSelect = document.getElementById('action_type_select');
    const actionDetailsDiv = document.getElementById('action-details');

    function updateActionDetails() {
        const actionType = actionTypeSelect.value;
        let html = '';

        if (actionType === 'move' || actionType === 'capture') {
            html += '<label for="direction">Direction:</label>';
            html += '<select name="direction" id="direction">';
            html += '<option value="up">Up</option>';
            html += '<option value="down">Down</option>';
            html += '<option value="left">Left</option>';
            html += '<option value="right">Right</option>';
            html += '</select>';
        } else if (actionType === 'use_item') {
            html += '<label for="item_id">Select Item:</label>';
            html += '<select name="item_id" id="item_id">';
            actionDetailsDiv.dataset.items.forEach(item => {
                html += `<option value="${item.id}">${item.name}</option>`;
            });
            html += '</select>';
        } else if (actionType === 'purchase_item') {
            html += '<label for="item_id">Select Item to Purchase:</label>';
            html += '<select name="item_id" id="item_id">';
            actionDetailsDiv.dataset.shopItems.forEach(item => {
                html += `<option value="${item.id}">${item.name} - ${item.price} Shards</option>`;
            });
            html += '</select>';
        }

        actionDetailsDiv.innerHTML = html;
    }

    if (actionTypeSelect) {
        actionTypeSelect.addEventListener('change', updateActionDetails);
        updateActionDetails(); // Initialize on page load
    }
});
