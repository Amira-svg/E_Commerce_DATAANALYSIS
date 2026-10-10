import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df=pd.read_csv("Products.csv")
df=df.drop_duplicates(subset=["product_id"])
df["product_id"] = df["product_id"].astype("string")
df["product_category_name"] = df["product_category_name"].astype("string")
df["product_category_name"] = (
    df["product_category_name"]
    .str.strip())

df.to_csv("Products.csv",index=False)