import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
df=pd.read_csv("Category_Name.csv")
print(df.isnull().sum())
df=df.drop_duplicates(subset="product_category_name")
df["product_category_name"]=df["product_category_name"].astype("str")
df["product_category_name_english"]=df["product_category_name_english"].astype("str")
df.to_csv("Category_Name.csv",index=False)
