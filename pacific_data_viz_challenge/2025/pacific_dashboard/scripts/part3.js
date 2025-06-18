fetch('data/data_gov.json')
  .then(res => res.json())
  .then(data => {
    const egovIndex = data.filter(d => d.Indicator === 'EGDI');

    drawEgovChart(egovIndex, 'bar-egdi', 'E-Government Development Index');
  });

function drawEgovChart(data, id, label) {
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
        backgroundColor: '#00b4d8'
      }]
    }
  });
}
