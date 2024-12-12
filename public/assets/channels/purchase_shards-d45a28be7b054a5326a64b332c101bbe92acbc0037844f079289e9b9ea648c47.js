document.addEventListener('DOMContentLoaded', function() {
    const shardAmountInput = document.getElementById('shard-amount');
    const purchaseButton = document.getElementById('purchase-button');

    function updatePrice() {
      const amount = parseInt(shardAmountInput.value, 10) || 0;
      const price = (amount * 0.01).toFixed(2);
      purchaseButton.value = `Purchase Shards - $${price}`;
    }

    shardAmountInput.addEventListener('input', updatePrice);
    updatePrice(); // Set initial price
  });
