import matplotlib as plt
from container import Container
# from agent import Agent


c = Container('Hello World')
c.grid(30, 30)
agents_list =[]
for n in range(1, 21):
    a = Agent(n)
    agents_list.append(a)
