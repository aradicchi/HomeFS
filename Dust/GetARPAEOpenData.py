
import urllib
import json
import datetime as dt
import matplotlib.pyplot as plt

def getArpaSeries(station_id):
    queryurl = """https://dati.arpae.it/api/action/datastore_search_sql?sql=SELECT * from "a1c46cfe-46e5-44b4-9231-7d9260a38e68" WHERE station_id=%s""" % station_id
    fileobj = urllib.urlopen(queryurl)
    datastr = fileobj.read()
    with open("c:/temp/arpa_data_%s.json" % station_id,'w') as ofile:
        ofile.write(datastr)
    return json.loads(datastr)

datadict = getArpaSeries("2000004")
datarecs = datadict["result"]["records"]
pm10s = map(lambda x: {"reftime":dt.datetime.strptime(x["reftime"],"%Y-%m-%dT%H:%M:%S").date(),"value":x["value"]},filter(lambda x: x["variable_id"]==5,datarecs))
pm2_5s = map(lambda x: {"reftime":dt.datetime.strptime(x["reftime"],"%Y-%m-%dT%H:%M:%S").date(),"value":x["value"]},filter(lambda x: x["variable_id"]==111,datarecs))

plt.plot_date(map(lambda x: x["reftime"],pm10s),map(lambda x: x["value"],pm10s))
plt.show()