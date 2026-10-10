import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
df=pd.read_csv("Review.csv")
df=df.drop_duplicates(subset=["review_id"])
df["review_id"]=df["review_id"].astype("string")
df["order_id"]=df["order_id"].astype("string")
df["review_score"]=df["review_score"].astype("float64")
df.to_csv("Review.csv",index=False)