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

#load "RetrieveData.fsx"

module Ilmeteo =

    let doit() =
        let dframe = Deedle.Frame.ReadCsv(Path.Combine(RetrieveData.Parameters.DATAFOLDER,"ilmeteo","Parma.csv"),
                                          separators=";",culture="it-IT")
        ()

module Dext3r =

    let doit() =
        let dframe = 
            Deedle.Frame.ReadCsv(Path.Combine(RetrieveData.Parameters.DATAFOLDER,"dext3r","precipitazioni_parma.csv"),
                                 separators=",")
            |> Frame.indexRowsDate "StartDate"
        let rainfalls = 
            dframe?DayTot_KG_M2 
            |> Series.observations
            |> Seq.filter (fun (_,x) -> x > 0.0)
            |> List.ofSeq
        let waitdays =
            rainfalls
            |> Seq.pairwise
            |> Seq.map (fun ((dt1,_),(dt2,x2)) -> dt2, (dt2-dt1).Days, x2)
            |> List.ofSeq
        //Chart.Point([for (d,x,y) in waitdays -> x,y],Labels=[for (d,_,_) in waitdays -> d.Year.ToString()])
        //Chart.Point([for (d,x,y) in waitdays -> d.Month,x],Labels = [for (d,_,_) in waitdays -> d.Year.ToString()])
        printfn "RefDate,WaitDays,Rainfall"
        for (d,x,y) in waitdays do
            printfn "%s,%d,%.5f" (d.ToString "yyyy-MM-dd") x y