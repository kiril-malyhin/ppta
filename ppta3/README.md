Do `gem install ruby-graphviz` or `bundle` if bundle is already installed. 
To run execute `ruby ppta3.rb` Results - `graph.png`, `minimized_graph.png` + 
state machine sets console output. 
Console output for var 4 (example):

```
Q: ["Y", "X", "Z", "I", "J", "K", "L", "N", "M"]
T: ["n", "m", "i", "j", "!", "/", "k"]
F: {"Y"=>{"n"=>"X", "m"=>"I"}, "X"=>{"i"=>"I", "j"=>"K"}, "Z"=>{"n"=>"X", "m"=>"K"}, "I"=>{"n"=>"L", "j"=>"J"}, "J"=>{"m"=>"X", "k"=>"N"}, "K"=>{"n"=>"M", "j"=>"J"}, "L"=>{"m"=>"J", "!"=>"N", "/"=>"L"}, "M"=>{"m"=>"J", "!"=>"N", "/"=>"M"}}
H: X
Z: ["N"]


Q: ["X", "J", "N", "A", "B"]
T: ["n", "m", "i", "j", "!", "/", "k"]
F: {"X"=>{"i"=>"A", "j"=>"A"}, "J"=>{"m"=>"X", "k"=>"N"}, "N"=>{}, "A"=>{"n"=>"B", "j"=>"J"}, "B"=>{"m"=>"J", "!"=>"N", "/"=>"B"}}
H: X
Z: ["N"]
partition: [["X"], ["I", "K"], ["J"], ["L", "M"], ["N"]]
group states map: {["I", "K"]=>"A", ["L", "M"]=>"B"}
```