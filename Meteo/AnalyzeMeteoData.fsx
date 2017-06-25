//
//
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

#load "RetrieveMeteoData.fsx"

module Ilmeteo =

    let doit() =
        let dframe = Deedle.Frame.ReadCsv(Path.Combine(RetrieveMeteoData.Parameters.DATAFOLDER,"ilmeteo","Parma.csv"),
                                          separators=";",culture="it-IT")
        ()

module Dext3r =

    let doit() =
        let dframe = 
            Frame.ReadCsv(Path.Combine(RetrieveMeteoData.Parameters.DATAFOLDER,"clean","parma_mix_1980_2017.csv"),
                          separators=",")
            |> Frame.indexRowsDate "StartDateTime"
        let mavg_2000 =
            dframe?Tot_KG_M2
            |> Stats.movingMean 2000
            |> Series.observations
        let mavg_100 =
            dframe?Tot_KG_M2
            |> Stats.movingMean 100
            |> Series.observations
        let rainfalls = 
            dframe?Tot_KG_M2 
            |> Series.observations
            |> Seq.filter (fun (_,x) -> x > 0.0)
            |> List.ofSeq
        let waitdays =
            rainfalls
            |> Seq.pairwise
            |> Seq.map (fun ((dt1,_),(dt2,x2)) -> dt2, (dt2-dt1).Days |> float, x2)
            |> List.ofSeq
        let wdlines = 
            "dt,wdays,rainfall" ::
            (
                seq {
                    for (dt,wd,rf) in waitdays do
                        yield sprintf "%s,%.0f,%.3f" (dt.ToString("yyyy-MM-dd")) wd rf
                } |> List.ofSeq
            )
        File.WriteAllLines(Path.Combine(RetrieveMeteoData.Parameters.DATAFOLDER,"clean","waitdays.csv"),wdlines)
        let maxwds =
            waitdays |> Seq.map (fun (x,y,z) -> x, y)
            |> Series.ofObservations
            |> Stats.movingMax 100
            |> Series.observations
        (
        Chart.Rows
            [
                (
                Chart.Combine
                    [
                        Chart.FastPoint(mavg_100,Name="Avg rainfall (Period = 100D)")
                        Chart.FastLine(mavg_2000,Name="Avg rainfall (Period = 2000D)")
                    ]                    
                ).WithYAxis(Title="KG/M2")
                //Chart.FastLine(mstd)
                Chart.FastLine(maxwds,Name="Max Wait Days (Period = 100D)").WithYAxis(Title="Days")
            ]
        ) |> ignore
        ()