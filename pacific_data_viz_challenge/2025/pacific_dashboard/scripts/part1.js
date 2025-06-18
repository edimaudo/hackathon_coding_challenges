fetch('data/data_thematic.json')
  .then(res => res.json())
  .then(data => {
    const internetData = data.filter(d => d.Indicator === 'PC_IND_IU_WEB');
    const mobileData = data.filter(d => d.Indicator === 'IT_MOB_SUB');
    const roadsData = data.filter(d => d.Indicator === 'BPI_PRU');

    // Map for Internet Access
    drawChoroplethMap(internetData, 'map-internet', 'Internet Access (%)');

    // Map for Mobile Subscriptions
    drawChoroplethMap(mobileData, 'map-mobile', 'Mobile Subscriptions (per 100)');

    // Bar Chart: Internet
    drawBarChart(internetData, 'bar-internet', 'Internet Access');

    // Bar Chart: Mobile
    drawBarChart(mobileData, 'bar-mobile', 'Mobile Subscriptions');

    // Bar Chart: Unpaved Roads
    drawBarChart(roadsData, 'bar-roads', 'Unpaved Roads (%)');
  });

function drawChoroplethMap(data, containerId, label) {
  // Use Leaflet.js here to build the map
  console.log(`Render ${label} map in ${containerId}`);
}

function drawBarChart(data, canvasId, label) {
  const ctx = document.getElementById(canvasId).getContext('2d');
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
        backgroundColor: '#0077b6'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false }
      }
    }
  });
}
