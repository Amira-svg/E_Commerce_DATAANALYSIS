import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv("Geolocation.csv", encoding="latin1")
df=df.drop_duplicates(subset="geolocation_zip_code_prefix")
df["geolocation_zip_code_prefix"]=df["geolocation_zip_code_prefix"].astype("str")
df["geolocation_lat"]=df["geolocation_lat"].astype("float")
df["geolocation_lng"]=df["geolocation_lng"].astype("float")
df["geolocation_city"]=df["geolocation_city"].astype("str")
df["geolocation_state"]=df["geolocation_state"].astype("str")
df.to_csv("Geolocation.csv",index=False)