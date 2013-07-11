(function() {

  $(function() {
    var centered, italy, path_generator, projection, svg, zoom_to;
    svg = d3.select('body').append('svg').attr('width', '100%').attr('height', '100%').attr('viewBox', '-200 -200 400 400');
    projection = d3.geo.albers().center([14, 34]).rotate([-14, 0]).parallels([38, 61]).scale(2100);
    path_generator = d3.geo.path().projection(projection);
    italy = svg.append('g').attr('class', 'italy');
    centered = null;
    zoom_to = function(d) {
      var centroid, level, x, y, zoom;
      level = d === centered ? 'zoom_italy' : d.properties.NOME_REG != null ? 'zoom_regione' : d.properties.NOME_PRO != null ? 'zoom_provincia' : 'zoom_comune';
      if (level !== 'zoom_italy') {
        centroid = path_generator.centroid(d);
        x = centroid[0];
        y = centroid[1];
        zoom = (function() {
          switch (level) {
            case 'zoom_regione':
              return 4;
            case 'zoom_provincia':
              return 9;
            case 'zoom_comune':
              return 16;
          }
        })();
        centered = d;
      } else {
        x = 0;
        y = 0;
        zoom = 1;
        centered = null;
      }
      italy.attr('class', level);
      italy.selectAll('.regione, .provincia, .comune').classed('active', function(d) {
        return d === centered;
      });
      return italy.transition().duration(750).attr('transform', 'scale(' + zoom + ')translate(' + -x + ',' + -y + ')');
    };
    return d3.json('data/istat/italy2011_g.topo.json', function(error, data) {
      var comuni, province, regioni;
      regioni = topojson.feature(data, data.objects.reg2011_g);
      province = topojson.feature(data, data.objects.prov2011_g);
      comuni = topojson.feature(data, data.objects.com2011_g);
      italy.selectAll('.comune').data(comuni.features).enter().append('path').attr('class', 'comune').attr('d', path_generator).on('click', zoom_to).append('title').text(function(d) {
        return d.properties.NOME_COM;
      });
      italy.selectAll('.provincia').data(province.features).enter().append('path').attr('class', 'provincia').attr('d', path_generator).on('click', zoom_to).append('title').text(function(d) {
        return d.properties.NOME_PRO;
      });
      return italy.selectAll('.regione').data(regioni.features).enter().append('path').attr('class', 'regione').attr('d', path_generator).on('click', zoom_to).append('title').text(function(d) {
        return d.properties.NOME_REG;
      });
    });
  });

}).call(this);
