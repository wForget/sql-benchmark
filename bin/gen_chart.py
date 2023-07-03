import pandas as pd
import json
import sys
from pathlib import Path

file1 = sys.argv[1]
file2 = sys.argv[2]
outputFile = sys.argv[3]

# 读取第一个表格数据
table1 = pd.read_csv(sys.argv[1], delimiter=r'\s+')

# 读取第二个表格数据
table2 = pd.read_csv(sys.argv[2], delimiter=r'\s+')

# 根据File列进行合并
merged_table = pd.merge(table1, table2, on='File', suffixes=('_1', '_2'))

# 提取File和Duration列
data1 = list(zip(merged_table['File'], merged_table['Duration(s)_1']))
data2 = list(zip(merged_table['File'], merged_table['Duration(s)_2']))

# 构建ECharts数据
echarts_data = {
    'data1': [{'name': item[0], 'value': item[1]} for item in data1],
    'data2': [{'name': item[0], 'value': item[1]} for item in data2]
}

# 生成ECharts HTML文本
html_template = '''
<!DOCTYPE html>
<html>
<head>
    <title>ECharts Bar Chart</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.2.2/dist/echarts.min.js"></script>
    <style>
        #chart-container {
		    position: absolute;
            width: 100%%;
            height: 2200px;
        }
    </style>
</head>
<body>
    <div id="chart-container">
        <div id="chart" style="height: 100%%; width: 100%%"></div>
    </div>
    <script type="text/javascript">
        var data1 = %s;
        var data2 = %s;
        var seriesName1 = "%s";
        var seriesName2 = "%s";

        var chart = echarts.init(document.getElementById("chart"));
        var option = {
            title: {
                text: "Duration Bar Chart"
            },
            legend: {
                data: [seriesName1, seriesName2]
            },
            xAxis: {
                type: "value"
            },
            yAxis: {
                type: "category",
                data: data1.map(function (item) {
                    return item.name;
                })
            },
            series: [{
                name: seriesName1,
                type: "bar",
                data: data1.map(function (item) {
                    return item.value;
                })
            }, {
                name: seriesName2,
                type: "bar",
                data: data2.map(function (item) {
                    return item.value;
                })
            }]
        };
        chart.setOption(option);
    </script>
</body>
</html>
'''

# 将数据转换为JSON字符串
data1_json = json.dumps(echarts_data['data1'])
data2_json = json.dumps(echarts_data['data2'])

# 替换HTML模板中的数据
#name1 = os.path.splitext(os.path.basename(file1))[0]
#name2 = os.path.splitext(os.path.basename(file2))[0]
name1 = Path(file1).stem
name2 = Path(file2).stem
html_content = html_template % (data1_json, data2_json, name1, name2)

fh = open(outputFile, 'w')
fh.write(html_content)
fh.close()