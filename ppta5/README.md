To run execute `ruby ppta5.rb`
grammar definition in `grammar.json`
accepted string 'acab'
not accepted string 'acacb'

Console output for var 4 (example):

```
state: q          remainder: acab                           st: ["C"]
state: q          remainder: acab                           st: ["A", "c", "a"]
state: q          remainder: cab                            st: ["A", "c"]
state: q          remainder: ab                             st: ["A"]
state: q          remainder: ab                             st: ["X", "A", "a"]
state: q          remainder: b                              st: ["X", "A"]
state: q          remainder: ab                             st: ["A"]
state: q          remainder: ab                             st: ["X", "a"]
state: q          remainder: b                              st: ["X"]
state: q          remainder: b                              st: ["X", "b"]
state: q          remainder:                                st: ["X"]
Is string accepted? : true
rules applied: [{"C"=>"acA"}, {"A"=>"aX"}, {"X"=>"bX"}, {"X"=>"ε"}]


state: q          remainder: acacb                          st: ["C"]
state: q          remainder: acacb                          st: ["A", "c", "a"]
state: q          remainder: cacb                           st: ["A", "c"]
state: q          remainder: acb                            st: ["A"]
state: q          remainder: acb                            st: ["X", "A", "a"]
state: q          remainder: cb                             st: ["X", "A"]
state: q          remainder: acb                            st: ["A"]
state: q          remainder: acb                            st: ["X", "a"]
state: q          remainder: cb                             st: ["X"]
state: q          remainder: acb                            st: ["A"]
all rules are unsuitable
Is string accepted? : false
```
