$ ->
    heat_color = d3.scale.linear()
        .domain([0,1])
        .range(['purple', 'orange'])
        .interpolate(d3.interpolateHcl)
    
    svg = d3.select('body').append('svg')
        .attr('width', '100%')
        .attr('height', '100%')
        .attr('viewBox' , '-200 -200 400 400')
        
    # projection = d3.geo.mercator()
        # .scale(2800)
        # .translate([50, 2620])
        # .precision(0.1)
        
    projection = d3.geo.albers()
        .center([14, 34])
        .rotate([-14, 0])
        .parallels([38, 61])
        .scale(2100)
        
    path_generator = d3.geo.path()
        .projection(projection)
        
    italy = svg.append('g')
        .attr('class', 'italy')
        
    centered = null
    
    zoom_to = (d) ->
        level = if d == centered then 'zoom_italy' else if d.properties.NOME_REG? then 'zoom_regione' else if d.properties.NOME_PRO? then 'zoom_provincia' else 'zoom_comune'
        
        if level != 'zoom_italy'
            centroid = path_generator.centroid(d)
            x = centroid[0]
            y = centroid[1]
            zoom = switch level
                when 'zoom_regione' then 4
                when 'zoom_provincia' then 9
                when 'zoom_comune' then 16
            centered = d
        else
            x = 0
            y = 0
            zoom = 1
            centered = null
            
        italy.attr('class', level)
        
        italy.selectAll('.regione, .provincia, .comune')
            .classed('active', (d) -> d == centered)
            
        italy.transition()
            .duration(750)
            .attr('transform', 'scale(' + zoom + ')translate(' + -x + ',' + -y + ')')
            
    d3.json 'data/istat/italy2011_g.topo.json', (error, data) ->
        # console.log(data)
        
        regioni = topojson.feature(data, data.objects.reg2011_g)
        province = topojson.feature(data, data.objects.prov2011_g)
        comuni = topojson.feature(data, data.objects.com2011_g)
        
        italy.selectAll('.comune')
            .data(comuni.features)
          .enter().append('path')
            .attr('class', 'comune')
            .attr('d', path_generator)
            .attr('fill', (d) -> heat_color(Math.random()))
            .on('click', zoom_to)
          .append('title')
            .text((d) -> d.properties.NOME_COM)
            
        italy.selectAll('.provincia')
            .data(province.features)
          .enter().append('path')
            .attr('class', 'provincia')
            .attr('d', path_generator)
            .on('click', zoom_to)
          .append('title')
            .text((d) -> d.properties.NOME_PRO)
            
        italy.selectAll('.regione')
            .data(regioni.features)
          .enter().append('path')
            .attr('class', 'regione')
            .attr('d', path_generator)
            .on('click', zoom_to)
          .append('title')
            .text((d) -> d.properties.NOME_REG)
            