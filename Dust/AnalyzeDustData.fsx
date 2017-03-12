//
// SCOPO:
// Quanto senso hanno le 'domeniche ecologiche'? Visto che la domenica e' gia' di
// per se un giorno con particolato basso.
//
// SENSORI:
// --------
// PM10 = 5
// PM2.5 = 111
//
// STAZIONI:
// ---------
// CITTADELLA = 2000003
// MONTEBELLO = 2000004
// PARADIGNA = 2000232
//

#r"../packages/alglib2.dll.3.10.4/x86/Alglib2.dll"
#I"../packages/FSharp.Data.2.3.2/lib/net40"
#r"FSharp.Data.dll"
#I"../packages/Deedle.1.2.5"
#load "Deedle.fsx"
#I"../packages/FSharp.Charting.0.90.14"
#load "FSharp.Charting.fsx"
#r"../packages/MathNet.Numerics.3.13.1/lib/net40/MathNet.Numerics.dll"

open System
open System.IO
open System.Numerics
open FSharp.Data
open FSharp.Charting
open Deedle
open MathNet.Numerics

let ccomb = Chart.Combine

type ARPACsvType = CsvProvider<"data/storico_2010_02000003_111.csv">

//let pm25files = Directory.GetFiles(Path.Combine(__SOURCE_DIRECTORY__,"data"),"*_02000003_111.csv")
let pm10files = Directory.GetFiles(Path.Combine(__SOURCE_DIRECTORY__,"data"),"*_02000004_005.csv")
let no2files = Directory.GetFiles(Path.Combine(__SOURCE_DIRECTORY__,"data"),"*_02000004_008.csv")

let readFiles (flist : seq<string>) =
    seq {
        for afile in flist do
            printfn "-> processing %s" afile
            for entry in ARPACsvType.Load(afile).Rows do
                yield DateTime.ParseExact(entry.DATA_INIZIO,"dd\/MM\/yyyy HH",null), entry.VALORE |> float
    } |> List.ofSeq

let pm10series = readFiles pm10files |> Series.ofObservations
let no2series = 
    readFiles no2files 
    |> List.groupBy (fun (x,y) -> x.Date)
    |> List.map (fun (x,ss) -> x, ss |> Seq.averageBy snd)
    |> Series.ofObservations

let pm10forfft = 
    pm10series |> Series.observations 
    |> Seq.map (fun (_,y) -> Complex(y,0.0))
    |> Array.ofSeq

IntegralTransforms.Fourier.Forward(pm10forfft)

(
Chart.Rows
    (
    [
    Chart.Point(no2series |> Series.observations)
    Chart.Point(pm10series |> Series.observations)
    ]
    )
)

let avgw = 60
let mavg = pm10series |> Stats.movingMean avgw
let mstd = pm10series |> Stats.movingStdDev avgw
let frm = Frame(["pm10";"mavg"],[pm10series;mavg])
let anomalie = (frm?pm10 - frm?mavg) |> Series.observations

let pm10avgforfft =
    mavg |> Series.observations
    |> Seq.map (fun (_,y) -> Complex(y,0.0))
    |> Array.ofSeq
IntegralTransforms.Fourier.Forward(pm10avgforfft)

(
Chart.Combine
    (
    [
    Chart.Point([for x in pm10forfft.[..pm10forfft.Length/2] -> x.Magnitude])
    Chart.Point([for x in pm10avgforfft.[..pm10avgforfft.Length/2] -> x.Magnitude])
    ]
    )
).WithYAxis(Log=true)


//(
//Chart.Combine
//    (
//    [
//        for year in (pm10series |> Series.observations |> Seq.map (fun (x,_) -> x.Year) |> Seq.distinct)
//            -> Chart.FastLine(pm10series |> Series.observations 
//                                         |> Seq.filter (fun (x,_) -> x.Year = year)
//                                         |> Seq.map (fun (x,y) -> x.DayOfYear, y),Name=year.ToString())
//    ]
//    )
//).WithLegend()

let dotline = Windows.Forms.DataVisualization.Charting.ChartDashStyle.Dot
Chart.Rows
    [
    Chart.FastLine(mavg |> Series.observations).WithYAxis(MajorGrid=ChartTypes.Grid(LineDashStyle=dotline))
    Chart.FastLine(mstd |> Series.observations).WithYAxis(MajorGrid=ChartTypes.Grid(LineDashStyle=dotline))
    Chart.FastPoint(anomalie).WithYAxis(MajorGrid=ChartTypes.Grid(LineDashStyle=dotline))
    ]

let daysOfYear (year : int) =
    let span = (new DateTime(year,12,31))-(new DateTime(year,1,1))
    span.Days

let byyday = 
    [for dt,vl in pm10series |> Series.observations 
        -> (float dt.DayOfYear)/(float <| daysOfYear(dt.Year)), vl]

let xs = [|for (x,_) in byyday -> x|]
let ys = [|for (_,y) in byyday -> y|]

let (binterp : ref<alglib.spline1dinterpolant>) = ref null
let (binfo : ref<int>) = ref 0
let (bfit : ref<alglib.spline1dfitreport>) = ref null
alglib.spline1dfitcubic(xs,ys,20,binfo,binterp,bfit)
let sxs = [1..366] |> List.map (fun x -> (float x)/366.0)
let iSpline x =
    alglib.spline1dcalc(!binterp,x)
let sys = [for x in sxs -> iSpline x]

(*
Chart.Combine
    [
    Chart.FastPoint(byyday)
    Chart.FastLine(Seq.zip sxs sys)
    ]
*)

let noise = 
    [for (dt,vl) in pm10series |> Series.observations 
        -> dt, vl - iSpline((float dt.DayOfYear)/366.0)]

(*
Chart.FastPoint(noise)
*)

let wseries =
    [for (dt,vl) in noise
        -> (dt.DayOfWeek |> float)+Distributions.Normal.Sample(0.,1.0)/10.0, vl]

let col = Drawing.ColorTranslator.FromHtml("#55000000")
Chart.FastPoint(wseries,Color=col)
