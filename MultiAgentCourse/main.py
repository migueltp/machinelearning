from MoneyModel import MoneyModel
import numpy as np


model = MoneyModel(N=50, height=10, width=10)
for i in range(100):
    model.step()

agent_counts = np.zeros(model.grid.width, model.grid.height)
agents = []
wealth = []
for cell in model.grid.coord_iter()
