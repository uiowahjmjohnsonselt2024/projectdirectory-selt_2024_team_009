document.addEventListener('DOMContentLoaded', function() {
  const shardAmountInput = document.getElementById('shard-amount');
  const purchaseButton = document.getElementById('purchase-button');
  const currencySelector = document.getElementById('currency');

  const currencyRates = {
    'USD': 1.0,
    'EUR': 1.2,
    'JPY': 0.8
  };

  function updatePrice() {
    const amount = parseInt(shardAmountInput.value, 10) || 0;
    const currency = currencySelector.value;
    const conversionRate = currencyRates[currency] || 1.0;
    console.log(currencySelector)
    const price = (amount * 0.01 * conversionRate).toFixed(2);
    purchaseButton.value = `Purchase Shards - ${currency} ${price}`;
  }

  shardAmountInput.addEventListener('input', updatePrice);
  currencySelector.addEventListener('change', updatePrice);
  updatePrice(); // Set initial price
});