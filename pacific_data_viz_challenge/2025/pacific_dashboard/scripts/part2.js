fetch('data/data_trade.json')
  .then(res => res.json())
  .then(data => {
    const ictGoods = data.filter(d => d.ICT_products_and_services === 'ICT_GOODS_TOTAL');
    const ictServices = data.filter(d => d.ICT_products_and_services === 'ICT_SERVICES_TOTAL');

    drawTradeChart(ictGoods, 'bar-ict-goods', 'ICT Goods Trade');
    drawTradeChart(ictServices, 'bar-ict-services', 'ICT Services Trade');
  });

function drawTradeChart(data, id, label) {
  const ctx = document.getElementById(id).getContext('2d');
  const countries = [...new Set(data.map(d => d.Pacific_Island_Countries_and_territories))];
  const values = countries.map(country =>
    +data.find(d => d.Pacific_Island_Countries_and_territories === country)?.OBS_VALUE || 0
  );

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: countries,
      datasets: [{
        label,
        data: values,
        backgroundColor: '#48cae4'
      }]
    }
  });
}
