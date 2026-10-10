import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df=pd.read_csv("Order_Items.csv")
df=df.drop_duplicates(subset=["order_id"])
df["order_id"] = df["order_id"].astype("string")
df["product_id"] = df["product_id"].astype("string")
df["seller_id"] = df["seller_id"].astype("string")
print((df["price"] < 0).sum())
print((df["freight_value"] < 0).sum())
df.to_csv("Order_Items.csv",index=False)