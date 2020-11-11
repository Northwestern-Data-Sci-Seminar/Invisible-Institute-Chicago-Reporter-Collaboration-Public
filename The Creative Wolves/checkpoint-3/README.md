There are in total three visualization codes, one for salary vs. allegation count 

**Salary vs. Allegation Count Visualization**
To view this visualization, navigate to the src subfolder and locate the salary folder (cd into .../src/salary)

Then follow the instruction provided by observable

# Chicago Police Allegation Count vs. Average Salary

https://observablehq.com/@tzhang1404/sortable-bar-chart@293

View this notebook in your browser by running a web server in this folder. For
example:

~~~sh
python -m SimpleHTTPServer
~~~

Or, use the [Observable Runtime](https://github.com/observablehq/runtime) to
import this module directly into your application. To npm install:

~~~sh
npm install @observablehq/runtime@4
npm install https://api.observablehq.com/d/d00605f46d6aac3c.tgz?v=3
~~~

Then, import your notebook and the runtime as:

~~~js
import {Runtime, Inspector} from "@observablehq/runtime";
import define from "@tzhang1404/sortable-bar-chart";
~~~

To log the value of the cell named “foo”:

~~~js
const runtime = new Runtime();
const main = runtime.module(define);
main.value("foo").then(value => console.log(value));
~~~

In our experience, you can just run 
~~~sh
python -m SimpleHTTPServer
~~~
and open localhost:<portnumber> in your browser, replacing the port number by whatever is given in the terminal prompt and you will be able to interact with the graph


**Awards vs. Allegation Count Visualization**

The process is very similar to that of the salary visualization, navigate to the Awards vs. Allegation folder and follow the instruction below or use the link provided. 


https://observablehq.com/d/1ed0af1eec02a13d@279

View this notebook in your browser by running a web server in this folder. For
example:

~~~sh
python -m SimpleHTTPServer
~~~

Or, use the [Observable Runtime](https://github.com/observablehq/runtime) to
import this module directly into your application. To npm install:

~~~sh
npm install @observablehq/runtime@4
npm install https://api.observablehq.com/d/1ed0af1eec02a13d.tgz?v=3
~~~

Then, import your notebook and the runtime as:

~~~js
import {Runtime, Inspector} from "@observablehq/runtime";
import define from "1ed0af1eec02a13d";
~~~

To log the value of the cell named “foo”:

~~~js
const runtime = new Runtime();
const main = runtime.module(define);
main.value("foo").then(value => console.log(value));
~~~

**Beats vs. Complaint Count**

The link to the notebook is:
https://observablehq.com/@m4sum/visualize-beat-dynamics

Everything is explained in the notebook so you won't need to do anything with the code and files.