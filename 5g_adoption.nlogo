breed [marketers marketer]
breed [industries industry]
breed [peoples people]
breed [sas sa]

globals [
  buying-power
  seed-number
]

peoples-own [
  threshold
  adopt-prob
  wealth
  adoption-score
  adopt?
  buy?
  friendlist
  mno
  friends-met
  marketers-met
  peoples-met
  wait-time
  mno-red
  mno-blue
  mno-yellow
]

industries-own [
  threshold
  adoption-score
  adopt?
  buy?
  sas-met
  peoples-met
  wait-time
  mno
  mno-red
  mno-blue
  mno-yellow
  industries-list
]

marketers-own [
  adopt?
  mno
]

sas-own [
  adopt?
  mno
]

to setup

  clear-all

  set seed-number new-seed
  set buying-power 3
  random-seed seed-number

  set-default-shape peoples "person"
  set-default-shape marketers "person"
  set-default-shape industries "factory"
  set-default-shape sas "person business"
  create-influencer
  create-market
  create-companies
  create-solution-architect

  reset-ticks
  print seed-number

end

to go

  ask turtles [
    move
  ]

  ask peoples with [adopt? = false][
    marketers-influence
    if friends? = true [peoples-influence]
    if memory? = true [memory-influence]
    change-adopt
    change-mno
  ]

  ask industries with [adopt? = false][
    sas-influence
    people-industry-influence
    industry-industry-influence
    change-adopt
    change-mno
    ;; add change-mno to industry
  ]

  ask peoples [
    buy-tech
  ]

  ask industries [
    buy-tech
  ]

  tick

end

to create-influencer

  create-marketers (peoples-number * (1 - proportion-peoples-marketers)) [
    setxy random-xcor random-ycor
    set adopt? true
    ifelse random-float 1 >= 0.5 [
      set mno "red"
      set color red
    ][
      ifelse random-float 1 >= 0.4 [
        set mno "blue"
        set color blue
    ][
        set mno "yellow"
        set color yellow
    ]]
  ]

end

to create-solution-architect

  create-sas 0.2 * count industries [
    setxy random-xcor random-ycor
    set color grey
    set adopt? true

    ifelse random-float 1 >= 0.5 [
      set mno "red"
      set color red
    ][
      ifelse random-float 1 >= 0.4 [
        set mno "blue"
        set color blue
    ][
        set mno "yellow"
        set color yellow
    ]]
  ]

end

to create-market

  create-peoples (peoples-number * proportion-peoples-marketers) [
    setxy random-xcor random-ycor
    set color grey
    let threshold-num random-lognormal 30 20
    set threshold min (list threshold-num 100)
    set wealth random-lognormal lognormal-M lognormal-S
    set adoption-score 0
    set adopt-prob max (list min (list random-normal 60 20 100) 0.000001)
    set adopt? false
    set buy? false
    set friendlist other n-of 10 peoples
    set mno "grey"
    set friends-met 0
    set marketers-met 0
    set wait-time 0
    set mno-red 0
    set mno-yellow 0
    set mno-blue 0
  ]

end

to create-companies

  create-industries 0.1 * peoples-number [
    setxy random-xcor random-ycor
    set color grey
    set threshold random-normal 300 30
    set adoption-score 0
    set adopt? false
    set buy? false
    set peoples-met 0
    set sas-met 0
    set mno-red 0
    set mno-blue 0
    set mno-yellow 0
    set industries-list other n-of 3 industries
  ]

end

to move

  ifelse random-float 1 > 0.5 [rt random-float 180] [lt random-float 180]
  fd 1

end

to marketers-influence

  if any? marketers-here [
    let target one-of marketers-here
    let add-adoption-score random-normal 7.69 1.8
    set adoption-score adoption-score + add-adoption-score + (average-mno-sharing * 0.43862 * 7.69) + (average-govt-incentive * (0.43862 * 7.69 / 2)) + (average-local-govt-cooperation * (0.43862 * 7.69 / 3)) + (infra-co-innovation * (0.43862 * 7.69))
    set marketers-met marketers-met + 1
    ifelse [mno] of target = "red" [set mno-red mno-red + 1][ifelse [mno] of target = "yellow" [set mno-yellow mno-yellow + 1][set mno-blue mno-blue + 1]]
  ]

end

to sas-influence

  if any? sas-here [
    let target one-of sas-here
    let random-adoption-score random-normal 23.085 5.38
    set sas-met sas-met + 1
    set adoption-score adoption-score + random-adoption-score + (average-mno-sharing * 0.43862 * 23.085) + (average-govt-incentive * (0.43862 * 23.085 / 2)) + (average-local-govt-cooperation * (0.43862 * 23.085 / 3 )) + (infra-co-innovation * (0.43862 * 23.085))
    ifelse [mno] of target = "red" [set mno-red mno-red + 1][ifelse [mno] of target = "yellow" [set mno-yellow mno-yellow + 1][set mno-blue mno-blue + 1]]
  ]

end

to memory-influence

  if any? peoples-here with [adopt? = true][
    let target one-of peoples-here
    let add-adoption-score random-normal 7.79 1.7
    if member? target friendlist = true [
      set adoption-score adoption-score + add-adoption-score
      ifelse [mno] of target = "red" [set mno-red mno-red + 1][ifelse [mno] of target = "yellow" [set mno-yellow mno-yellow + 1] [set mno-blue mno-blue + 1]]
      set friends-met friends-met + 1
    ]
  ]

end

to peoples-influence

  if any? peoples-here with [adopt? = true][
    let target one-of peoples with [adopt? = true]
    let random-adoption-score random-normal 7.79 1.7
    set adoption-score adoption-score + random-adoption-score
    ifelse [mno] of target = "red" [set mno-red mno-red + 1 ][ifelse [mno] of target = "yellow" [set mno-yellow mno-yellow + 1][set mno-blue mno-blue + 1]]
  ]

end

to people-industry-influence

  if any? peoples-here with [adopt? = true][
    set adoption-score adoption-score + (0.57 * 7.79)
  ]

end

to industry-industry-influence

  if any? industries-here with [adopt? = true][
    let target one-of industries with [adopt? = true]
    let random-adoption-score random-normal 23.37 5.1
    set adoption-score adoption-score + random-adoption-score
    ifelse [mno] of target = "red" [set mno-red mno-red + 1 ][ifelse [mno] of target = "yellow" [set mno-yellow mno-yellow + 1][set mno-blue mno-blue + 1]]
  ]

end

to change-adopt

  let breed-type [breed] of self
  if adoption-score > threshold and adopt? = false[
    ifelse breed-type = peoples [
      let prob random-float 100
      if adopt-prob < prob [
        set adopt? true
        let x min (list (wealth - buying-power) 0)
        ifelse x <= -2[set wait-time 312][ifelse x <= -1 [set wait-time 208][ifelse x < 0 [set wait-time 104][set wait-time 1]]]
    ]]
    [
      set adopt? true
      set wait-time 12 + random 40
    ]
  ]

end

to change-mno

  if adopt? = true [

    ifelse tie-mno self = true [
      ;; list mno color sendiri
      let mno-count-list (list mno-red mno-yellow mno-blue)
      ;; list pilihan warna
      let mno-color-list (list "red" "yellow" "blue")
      ;; hitung berapa angka yang sama
      let max-mno-count max-mno self
      let max-count frequency max-mno-count mno-count-list

      ifelse max-count = 3 [
        ;; kalau 3 random 1/3
        let x random-float 1
        ifelse x <= (1 / 3) [set mno "red"][ifelse x <= (2 / 3) [set mno "yellow"] [set mno "blue"]]
      ][
        ;; kalau 2 kurangin satu warna trus random berdasarkan posisi
        let min-mno-count min mno-count-list
        let min-pos position min-mno-count mno-count-list
        let list-mno-choice remove-item min-pos mno-color-list

        let x random-float 1

        ifelse x >= 0.5 [set mno item 0 list-mno-choice][set mno item 1 list-mno-choice]

      ]

      let target one-of turtles-here with [adopt? = true]
      let mno-color [mno] of target
      ifelse mno-color = "red" [set mno "red"][ifelse mno-color = "yellow" [set mno "yellow"][set mno "blue"]]
    ]
    [
      let max-pos max-mno self
      ifelse max-pos = 0 [set mno "red"][ifelse max-pos = 1 [set mno "yellow"][set mno "blue"]]
    ]
    change-color-mno
  ]

end

to change-color-mno

  ifelse mno = "red" [set color red][ifelse mno = "yellow" [set color yellow][set color blue]]

end

to buy-tech

  if adopt? = true and buy? = false [
    set wait-time wait-time - 1

    if wait-time = 0[
      set buy? true
    ]
  ]

end

to-report count-adopt

  report count peoples with [adopt? = true]

end

to-report count-friends-mno [agent color-mno]

  let friends-num (count [friendlist with [mno = color-mno]] of agent)
  report friends-num

end

to-report random-lognormal [miu sigma]

  let beta ln (1 + (sigma ^ 2 / miu ^ 2))
  let S sqrt beta
  let M ln miu - (beta / 2)
  report exp (random-normal M S)

end

to-report max-mno [agent]

  let red-temp [mno-red] of agent
  let yellow-temp [mno-yellow] of agent
  let blue-temp [mno-blue] of agent
  let mno-list (list mno-red mno-yellow mno-blue)
  let mno-max max mno-list
  report position mno-max mno-list

end

to-report tie-mno [agent]

  let red-temp [mno-red] of agent
  let yellow-temp [mno-yellow] of agent
  let blue-temp [mno-blue] of agent
  let mno-list (list mno-red mno-yellow mno-blue)
  let mode-mno first modes mno-list
  let max-list-mno max mno-list
  report mode-mno = max-list-mno

end

to-report count-adopt?

  report count peoples with [adopt? = true]

end

to-report perc-adopt?

  report count-adopt? / count peoples

end

to-report count-adopt?-industries

  report count industries with [adopt? = true]

end

to-report count-buy?-people

  report count peoples with [buy? = true]

end

to-report count-buy?-industries

  report count industries with [buy? = true]

end

to-report perc-adopt?-industries

  report count-adopt?-industries / count industries

end

to-report count-mno-adopt? [mno-color]

  report count peoples with [adopt? = true and mno = mno-color]

end

to-report count-mno-industry [mno-color]

  report count industries with [adopt? = true and mno = mno-color]

end

to-report count-red-adopt?

  report count peoples with [adopt? = true and mno = "red"]

end

to-report count-yellow-adopt?

  report count peoples with [adopt? = true and mno = "yellow"]

end

to-report count-blue-adopt?

  report count peoples with [adopt? = true and mno = "blue"]

end

to-report count-mno-buy? [mno-color]

  report count peoples with [buy? = true and mno = mno-color]

end

to-report frequency [an-item a-list]

  report length (filter [i -> i = an-item] a-list)

end
@#$#@#$#@
GRAPHICS-WINDOW
5
32
447
475
-1
-1
10.6
1
10
1
1
1
0
1
1
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
459
33
524
67
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
539
33
602
66
go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
709
189
995
339
MNO Adoption Market Share Percentage
Tick
Percentage
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Red" 1.0 0 -2674135 true "" "carefully [plot count-mno-adopt? \"red\" / count-adopt?] [plot 0]"
"Yellow" 1.0 0 -4079321 true "" "carefully [plot count-mno-adopt? \"yellow\" / count-adopt?] [plot 0]"
"Blue" 1.0 0 -14070903 true "" "carefully [plot count-mno-adopt? \"blue\" / count-adopt?] [plot 0]"

SLIDER
459
123
681
156
peoples-number
peoples-number
10
1000
700.0
1
1
NIL
HORIZONTAL

SLIDER
459
158
683
192
proportion-peoples-marketers
proportion-peoples-marketers
0.1
1
0.9
0.1
1
NIL
HORIZONTAL

MONITOR
460
69
512
114
Peoples
count peoples
17
1
11

MONITOR
579
69
641
114
Marketers
count marketers
17
1
11

SLIDER
459
194
682
228
average-mno-sharing
average-mno-sharing
0
4
1.0
1
1
NIL
HORIZONTAL

SLIDER
459
230
684
264
average-govt-incentive
average-govt-incentive
0
2
1.0
1
1
NIL
HORIZONTAL

SLIDER
458
267
685
301
average-local-govt-cooperation
average-local-govt-cooperation
0
3
1.0
1
1
NIL
HORIZONTAL

SWITCH
347
479
444
512
memory?
memory?
0
1
-1000

INPUTBOX
458
339
526
399
lognormal-M
5.0
1
0
Number

INPUTBOX
526
339
596
399
lognormal-S
6.0
1
0
Number

MONITOR
712
389
776
434
Red-adopt
count peoples with [adopt? = true and mno = \"red\"]
0
1
11

MONITOR
712
343
762
389
Adopt?
count peoples with [adopt? = true]
0
1
11

MONITOR
777
389
845
435
Yellow-adopt
count peoples with [adopt? = true  and mno = \"yellow\"]
0
1
11

MONITOR
846
389
916
435
Blue-adopt
count peoples with [adopt? = true and mno = \"blue\"]
17
1
11

SWITCH
347
515
443
548
friends?
friends?
1
1
-1000

MONITOR
514
69
577
114
Industries
count industries
0
1
11

MONITOR
643
69
705
115
Accounts
count sas
17
1
11

PLOT
1002
32
1280
182
Industry Adoption and Buy Percentage
Tick
Percentage
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"adopt?" 1.0 0 -15040220 true "" "plot count industries with [adopt? = true] / count industries"
"buy?" 1.0 0 -12895429 true "" "plot count industries with [buy? = true] / count industries"

MONITOR
763
343
818
389
I Adopt
count-adopt?-industries
0
1
11

PLOT
708
32
993
182
Peoples Adoption and Buy Percentage
Tick
Percentage
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"adopt?" 1.0 0 -14439633 true "" "plot count peoples with [adopt? = true] / count peoples"
"buy?" 1.0 0 -12895429 true "" "plot count peoples with [buy? = true] / count peoples"

SLIDER
458
304
685
338
infra-co-innovation
infra-co-innovation
0
2
0.0
1
1
NIL
HORIZONTAL

INPUTBOX
9
485
122
545
ARPU-mno-red
60300.0
1
0
Number

INPUTBOX
128
485
233
545
ARPU-mno-yellow
48240.0
1
0
Number

INPUTBOX
238
485
342
545
ARPU-mno-blue
43550.0
1
0
Number

PLOT
919
344
1278
501
MNOs Revenue
Tick
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Red" 1.0 0 -5298144 true "" "plot (count-mno-buy? \"red\" * (ARPU-mno-red / 4)) + (count-mno-industry \"red\" * ARPU-mno-red * 10)"
"Yellow" 1.0 0 -4079321 true "" "plot (count-mno-buy? \"yellow\" * (ARPU-mno-yellow / 4)) + (count-mno-industry \"yellow\" * ARPU-mno-yellow * 10)"
"Blue" 1.0 0 -14070903 true "" "plot (count-mno-buy? \"blue\" * (ARPU-mno-blue / 4)) + (count-mno-industry \"blue\" * ARPU-mno-blue * 10)"

PLOT
999
189
1277
339
MNO Adoption Market Share Percentage Industry
Tick
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Red" 1.0 0 -2674135 true "" "carefully [plot count-mno-industry \"red\" / count-adopt?-industries] [plot 0]"
"Yellow" 1.0 0 -4079321 true "" "carefully [plot count-mno-industry \"yellow\" / count-adopt?-industries] [plot 0]"
"Blue" 1.0 0 -14070903 true "" "carefully [plot count-mno-industry \"blue\" / count-adopt?-industries] [plot 0]"

MONITOR
712
437
775
482
I-R-Adpt
count industries with [color = red]
0
1
11

MONITOR
775
437
835
482
I-Y-Adpt
count industries with [color = yellow]
0
1
11

MONITOR
836
437
895
482
I-B-Adpt
count industries with [color = blue]
0
1
11

MONITOR
458
400
508
446
M-Red
count marketers with [color = red]
17
1
11

MONITOR
509
400
559
446
M-Yell
count marketers with [color = yellow]
0
1
11

MONITOR
560
400
610
446
M-Blue
Count marketers with [color = blue]
0
1
11

MONITOR
458
447
508
493
A-Red
count sas with [color = red]
0
1
11

MONITOR
509
447
559
493
A-Yell
count sas with [color = yellow]
17
1
11

MONITOR
560
447
610
493
A=Blue
count sas with [color = blue]
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="interaksi" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>seed-number</metric>
    <metric>count-adopt?</metric>
    <metric>count-red-adopt?</metric>
    <metric>count-blue-adopt?</metric>
    <metric>count-yellow-adopt?</metric>
    <metric>perc-adopt?</metric>
    <metric>perc-adopt?-industries</metric>
    <enumeratedValueSet variable="jumlah-orang">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proporsi-orang-marketer">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-S">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-M">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-local-govt-cooperation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teman?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-govt-incentive">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-mno-sharing">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="eksperimen 1" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>seed-number</metric>
    <metric>count-adopt?</metric>
    <metric>count-red-adopt?</metric>
    <metric>count-blue-adopt?</metric>
    <metric>count-yellow-adopt?</metric>
    <metric>perc-adopt?</metric>
    <metric>perc-adopt?-industries</metric>
    <enumeratedValueSet variable="jumlah-orang">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proporsi-orang-marketer">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-S">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-M">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-local-govt-cooperation">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-govt-incentive">
      <value value="0"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teman?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-mno-sharing">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="adopt buy 1" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>seed-number</metric>
    <metric>count-adopt?</metric>
    <metric>count-red-adopt?</metric>
    <metric>count-blue-adopt?</metric>
    <metric>count-yellow-adopt?</metric>
    <metric>perc-adopt?</metric>
    <metric>perc-adopt?-industries</metric>
    <enumeratedValueSet variable="jumlah-orang">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proporsi-orang-marketer">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-S">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-M">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-local-govt-cooperation">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-govt-incentive">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teman?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-mno-sharing">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-final" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1100"/>
    <metric>seed-number</metric>
    <metric>count-adopt?</metric>
    <metric>count-red-adopt?</metric>
    <metric>count-blue-adopt?</metric>
    <metric>count-yellow-adopt?</metric>
    <metric>perc-adopt?</metric>
    <metric>perc-adopt?-industries</metric>
    <enumeratedValueSet variable="jumlah-orang">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ARPU-mno-red">
      <value value="60300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proporsi-orang-marketer">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infra-co-innovation">
      <value value="0"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ARPU-mno-blue">
      <value value="43550"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-S">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lognormal-M">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teman?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-local-govt-cooperation">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-govt-incentive">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ARPU-mno-yellow">
      <value value="48240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-mno-sharing">
      <value value="0"/>
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
