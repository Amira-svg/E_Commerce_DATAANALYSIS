import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df=pd.read_csv("Customers.csv")
df=df.drop_duplicates(subset=["customer_id"])
df["customer_id"]=df["customer_id"].astype("str")
df["customer_unique_id"]=df["customer_unique_id"].astype("str")
df["customer_zip_code_prefix"]=df["customer_zip_code_prefix"].astype("str")
df["customer_city"]=df["customer_city"].astype("str")
df["customer_state"]=df["customer_state"].astype("str")
df.to_csv("Customers.csv",index=False)