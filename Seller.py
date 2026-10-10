import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv("Seller.csv", encoding="latin1")
df = df.drop_duplicates()
df["seller_id"] = df["seller_id"].astype("string")
df["seller_zip_code_prefix"] = df["seller_zip_code_prefix"].astype("string")
df["seller_city"] = (
    df["seller_city"]
    .str.strip()
)
df.to_csv("Seller.csv", index=False)