import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df=pd.read_csv("Orders.csv")
df=df.drop_duplicates(subset=["order_id"])
df["order_id"]=df["order_id"].astype("string")
df["customer_id"]=df["customer_id"].astype("string")
df["order_status"]=df["order_status"].astype("string")
df=df[df["order_approved_at"]>=df["order_purchase_timestamp"]]
df=df[df["order_delivered_customer_date"]>=df["order_purchase_timestamp"]]
df.to_csv("Orders.csv",index=False)