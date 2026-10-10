import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df=pd.read_csv("Orders_Payment.csv")
df=df.drop_duplicates(subset=["order_id"])
df["order_id"] = df["order_id"].astype("string")
print("Negative payment values:",
      (df["payment_value"] < 0).sum())
print(df["payment_value"].describe())
df["payment_sequential"] = df["payment_sequential"].astype("int64")
df["payment_installments"] = df["payment_installments"].astype("int64")
df["payment_value"] = df["payment_value"].astype("float64")
df.to_csv("Orders_Payment.csv",index=False)