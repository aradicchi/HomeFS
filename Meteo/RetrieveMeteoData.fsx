open System
open System.IO
open System.Text
open System.Net
open System.Threading

Thread.CurrentThread.CurrentCulture <- new Globalization.CultureInfo("it-IT")

module Parameters =

    let DATAFOLDER = Path.Combine(__SOURCE_DIRECTORY__,"Data")
    
module RetrieveData =

    let formatMonth (month : int) =
        let tmpdt = new DateTime(2001,month,1)
        let tmpstr = tmpdt.ToString("MMMM")
        Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(tmpstr)

    let retrieveFile (city : string) (year : int) (month : int) =
        let wc = new WebClient()
        let ofilepath = Path.Combine(Parameters.DATAFOLDER,"ilmeteo",sprintf "%s_%4d%02d.csv" city year month)
        let url = sprintf "http://www.ilmeteo.it/portale/archivio-meteo/%s/%d/%s?format=csv" city year (formatMonth month)
        wc.DownloadFile(url,ofilepath)
    
    let doit (city : string) =
        for year in [2004..2016] do
            printfn "processing year %d" year
            for month in [1..12] do
                printfn "processing month %2d" month
                retrieveFile city year month

module MergeData =

    let doit (city : string) =
        let header = @"LOCALITA;DATA;TMEDIA °C;TMIN °C;TMAX °C;PUNTORUGIADA °C;UMIDITA %;VISIBILITA km;VENTOMEDIA km/h;VENTOMAX km/h;RAFFICA km/h;PRESSIONESLM mb;PRESSIONEMEDIA mb;PIOGGIA mm;FENOMENI"
        let alllines =
            seq {
                for file in Directory.GetFiles(Parameters.DATAFOLDER,sprintf "%s_*.csv" city) do
                    yield File.ReadAllLines(file).[1..]
                } |> Seq.concat |> Array.ofSeq
        let text = header :: (List.ofArray alllines)
        File.WriteAllLines(Path.Combine(Parameters.DATAFOLDER,sprintf "%s.csv" city), text)
            
MergeData.doit "Parma"