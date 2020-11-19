export default function define(runtime, observer) {
  const main = runtime.module();
  const fileAttachments = new Map([["Result_27.csv",new URL("./files/c0c11dc973b058e7e67aa3eb49f71d918b7fee9680ff6a58721cb0f72656b27145e6eb2262d09ddcf90c50f218b8d0c525f4404244e0fe4e641bbf67d266d8b9",import.meta.url)]]);
  main.builtin("FileAttachment", runtime.fileAttachments(name => fileAttachments.get(name)));
  main.variable(observer()).define(["md"], function(md){return(
md `#Allegation vs. Awards`
)});
  main.variable(observer("d3")).define("d3", ["require"], function(require){return(
require("d3@6")
)});
  main.variable(observer("data")).define("data", ["d3","FileAttachment"], async function(d3,FileAttachment){return(
d3.csvParse(await FileAttachment("Result_27.csv").text(), ({officer_id, number_of_awards, number_of_allegations}) => ({id: officer_id, x : +number_of_allegations, y: +number_of_awards, color: 1}))
)});
  main.variable(observer("height")).define("height", function(){return(
600
)});
  main.variable(observer("k")).define("k", ["height","width"], function(height,width){return(
height / width
)});
  main.variable(observer("grid")).define("grid", ["height","k","width"], function(height,k,width){return(
(g, x, y) => g
    .attr("stroke", "currentColor")
    .attr("stroke-opacity", 0.1)
    .call(g => g
      .selectAll(".x")
      .data(x.ticks(12))
      .join(
        enter => enter.append("line").attr("class", "x").attr("y2", height),
        update => update,
        exit => exit.remove()
      )
        .attr("x1", d => 0.5 + x(d))
        .attr("x2", d => 0.5 + x(d)))
    .call(g => g
      .selectAll(".y")
      .data(y.ticks(12 * k))
      .join(
        enter => enter.append("line").attr("class", "y").attr("x2", width),
        update => update,
        exit => exit.remove()
      )
        .attr("y1", d => 0.5 + y(d))
        .attr("y2", d => 0.5 + y(d)))
)});
  main.variable(observer("yAxis")).define("yAxis", ["d3","k"], function(d3,k){return(
(g, y) => g
    .call(d3.axisRight(y).ticks(12 * k))
    .call(g => g.select(".domain").attr("display", "none"))
)});
  main.variable(observer("xAxis")).define("xAxis", ["height","d3"], function(height,d3){return(
(g, x) => g
    .attr("transform", `translate(0,${height})`)
    .call(d3.axisTop(x).ticks(12))
    .call(g => g.select(".domain").attr("display", "none"))
)});
  main.variable(observer("xMin")).define("xMin", ["d3","data"], function(d3,data){return(
d3.min(data.map((d) => d.x))
)});
  main.variable(observer("xMax")).define("xMax", ["d3","data"], function(d3,data){return(
d3.max(data.map((d) => d.x))
)});
  main.variable(observer("yMin")).define("yMin", ["d3","data"], function(d3,data){return(
d3.min(data.map((d) => d.y))
)});
  main.variable(observer("yMax")).define("yMax", ["d3","data"], function(d3,data){return(
d3.max(data.map((d) => d.y))
)});
  main.variable(observer("z")).define("z", ["d3","data"], function(d3,data){return(
d3.scaleOrdinal()
    .domain(data.map(d => d.color))
    .range(d3.schemeCategory10)
)});
  main.variable(observer("y")).define("y", ["d3","yMin","yMax","height"], function(d3,yMin,yMax,height){return(
d3.scaleLinear()
    .domain([yMin,yMax])
    .range([height, 0])
)});
  main.variable(observer("x")).define("x", ["d3","xMin","xMax","width"], function(d3,xMin,xMax,width){return(
d3.scaleLinear()
    .domain([xMin,xMax])
    .range([0, width])
)});
  main.variable(observer("chart")).define("chart", ["d3","width","height","data","x","y","z","xAxis","yAxis","grid"], function(d3,width,height,data,x,y,z,xAxis,yAxis,grid)
{
  const zoom = d3.zoom()
      .scaleExtent([0.5, 32])
      .on("zoom", zoomed);

  const svg = d3.create("svg")
      .attr("viewBox", [-10, 30, width, height]);

  const gGrid = svg.append("g");

  const gDot = svg.append("g")
      .attr("fill", "none")
      .attr("stroke-linecap", "round");

  gDot.selectAll("path")
    .data(data)
    .join("path")
      .attr("d", d => `M${x(d.x)},${y(d.y)}h0`)
      .attr("stroke", d => z(d.color));

  const gx = svg.append("g");

  const gy = svg.append("g");

  svg.call(zoom).call(zoom.transform, d3.zoomIdentity);

  function zoomed({transform}) {
    const zx = transform.rescaleX(x).interpolate(d3.interpolateRound);
    const zy = transform.rescaleY(y).interpolate(d3.interpolateRound);
    gDot.attr("transform", transform).attr("stroke-width", 5 / transform.k);
    gx.call(xAxis, zx);
    gy.call(yAxis, zy);
    gGrid.call(grid, zx, zy);
  }

  return Object.assign(svg.node(), {
    reset() {
      svg.transition()
          .duration(750)
          .call(zoom.transform, d3.zoomIdentity);
    }
  });
}
);
  return main;
}
