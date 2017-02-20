//
// TODO: get more series (not only 2016)
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

type ARPACsvType = CsvProvider<"data/storico_2016_02000232_111.csv">

let series =
    seq {
        for entry in ARPACsvType.GetSample().Rows do
            yield DateTime.ParseExact(entry.DATA_FINE,"dd\/MM\/yyyy 00",null), entry.VALORE |> float
    } |> List.ofSeq

//Chart.Line(series)

let grouped =
    query {for entry in series do
           groupBy (fst entry).DayOfWeek into g
           let avg =
            query {
                    for subentry in g do
                        averageBy (snd subentry)
                  }
           select (g.Key.ToString(),avg)} |> List.ofSeq

Chart.Column(grouped)
