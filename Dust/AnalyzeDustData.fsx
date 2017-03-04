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

#I"../packages/FSharp.Data.2.3.2/lib/net40"
#r"FSharp.Data.dll"
#I"../packages/Deedle.1.2.5"
#load "Deedle.fsx"
#I"../packages/FSharp.Charting.0.90.14"
#load "FSharp.Charting.fsx"

open System
open System.IO
open FSharp.Data
open FSharp.Charting
open Deedle

let ccomb = Chart.Combine

type ARPACsvType = CsvProvider<"data/storico_2010_02000003_111.csv">

let pm25files = Directory.GetFiles(Path.Combine(__SOURCE_DIRECTORY__,"data"),"*_02000003_111.csv")
let pm10files = Directory.GetFiles(Path.Combine(__SOURCE_DIRECTORY__,"data"),"*_02000003_005.csv")

let readFiles (flist : seq<string>) =
    seq {
        for afile in flist do
            printfn "-> processing %s" afile
            for entry in ARPACsvType.Load(afile).Rows do
                yield DateTime.ParseExact(entry.DATA_INIZIO,"dd\/MM\/yyyy 00",null), entry.VALORE |> float
    } |> List.ofSeq

let pm10series = readFiles pm10files |> Series.ofObservations
let mavg = pm10series |> Stats.movingMean 90
let frm = Frame(["pm10";"mavg"],[pm10series;mavg])
let anomalie = (frm?pm10 - frm?mavg) |> Series.observations

Chart.Rows
    [
    Chart.FastLine(mavg |> Series.observations)
    Chart.FastPoint(anomalie)
    ]

let byyday = [for dt,vl in pm10series |> Series.observations -> (float dt.DayOfYear)/366.0, vl]
Chart.FastPoint(byyday)

