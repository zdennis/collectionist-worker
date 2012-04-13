require 'rubygems'
require 'active_support/all'

NumberOfLinesForSummary = 2
PROJECT_NAME = File.basename(Dir.pwd)

data = []
Dir["roodi/*.txt"].sort_by{ |f| File.basename(f) }.each do |f|
  # contexttravel.2010-04-14.f128663.txt
  date = f.scan(/\d{4}-\d{2}-\d{2}/).flatten.first
  count = `wc -l #{f}`.to_i - NumberOfLinesForSummary
  data << [date, count]
end

TEMPLATE_STR = DATA.read

File.open("roodi.raw-data.txt", "w"){ |f| 
  f.puts data.map{ |r| r.join(",") }.join("\n") 
}

File.open("roodi-every-commit.googlechart.html", "w") do |f|
  hdata = data.map { |r| "[ '#{r.first}', #{r.last} ]" }
  f.puts TEMPLATE_STR.gsub("$PROJECT_NAME", PROJECT_NAME).gsub("$PLACEHOLDER", hdata.join(",\n"))
end

File.open("roodi-every-day.googlechart.html", "w") do |f|
  h = {}
  data.each do |date, count|
    if h[date]
      h[date] = count if h[date] < count
    else
      h[date] = count
    end
  end
  
  hdata = h.keys.sort.map { |key| "[ '#{key}', #{h[key]} ]" }
  f.puts TEMPLATE_STR.gsub("$PROJECT_NAME", PROJECT_NAME).gsub("$PLACEHOLDER", hdata.join(",\n"))
end

File.open("roodi-every-week.googlechart.html", "w") do |f|
  h = {}
  last_date = nil
  data.each do |date, count|
    ndate = (date.to_date rescue nil)
    next unless ndate
    if last_date && (last_date..last_date+7.days).include?(ndate)
      next
    else
      h[date] = count
      last_date = ndate
    end
  end
  
  hdata = h.keys.sort.map { |key| "[ '#{key}', #{h[key]} ]" }
  f.puts TEMPLATE_STR.gsub("$PROJECT_NAME", PROJECT_NAME).gsub("$PLACEHOLDER", hdata.join(",\n"))
end

File.open("roodi-every-30-days.googlechart.html", "w") do |f|
  h = {}
  last_date = nil
  data.each do |date, count|
    ndate = (date.to_date rescue nil)
    next unless ndate
    if last_date && (last_date..last_date+30.days).include?(ndate)
      next
    else
      h[date] = count
      last_date = ndate
    end
  end
  
  hdata = h.keys.sort.map { |key| "[ '#{key}', #{h[key]} ]" }
  f.puts TEMPLATE_STR.gsub("$PROJECT_NAME", PROJECT_NAME).gsub("$PLACEHOLDER", hdata.join(",\n"))
end

__END__
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Release');
        data.addColumn('number', 'Roodi Score');
        data.addRows([
$PLACEHOLDER
        ]);

        var options = {
          title: '$PROJECT_NAME',
          hAxis: {title: 'Release',  titleTextStyle: {color: 'red'}}
        };

        var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="chart_div" style="width: 1540; height: 800;"></div>
  </body>
</html>
