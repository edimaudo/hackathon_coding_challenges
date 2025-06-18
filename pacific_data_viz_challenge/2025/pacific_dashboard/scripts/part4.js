Promise.all([
  fetch('data/data_thematic.json').then(res => res.json()),
  fetch('data/data_gov.json').then(res => res.json())
]).then(([thematic, gov]) => {
  const internet = thematic.filter(d => d.Indicator === 'PC_IND_IU_WEB');
  const egdi = gov.filter(d => d.Indicator === 'EGDI');

  drawScatterPlot(egdi, internet, 'scatter-egov-internet');
});

function drawScatterPlot(egov, internet, id) {
  const ctx = document.getElementById(id).getContext('2d');
  const countries = [...new Set(egov.map(d => d.Pacific_Island_Countries_and_territories))];

  const points = countries.map(country => {
    const e = egov.find(d => d.Pacific_Island_Countries_and_territories === country)?.OBS_VALUE || 0;
    const i = internet.find(d => d.Pacific_Island_Countries_and_territories === country)?.OBS_VALUE || 0;
    return { x: +i, y: +e, label: country };
  });

  new Chart(ctx, {
    type: 'scatter',
    data: {
      datasets: [{
        label: 'EGDI vs Internet Access',
        data: points,
        backgroundColor: '#90e0ef',
        parsing: {
          xAxisKey: 'x',
          yAxisKey: 'y'
        }
      }]
    },
    options: {
      plugins: {
        tooltip: {
          callbacks: {
            label: context => `${context.raw.label}: Internet ${context.raw.x}%, EGDI ${context.raw.y}`
          }
        }
      },
      scales: {
        x: { title: { display: true, text: 'Internet Access (%)' } },
        y: { title: { display: true, text: 'EGDI' } }
      }
    }
  });
}
