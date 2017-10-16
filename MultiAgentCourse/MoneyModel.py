from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
import random


class MoneyModel(Model):

    def __init__(self, N, width, height):
        self.num_agents = N
        self.grid = MultiGrid(width=width, height=height)
        x = random.randrange(width)
        y = random.randrange(height)

    def step(self):
        self.schedule.step()


class MoneyAgent(Agent):
    def __init__(self, unique_id, model):
        super(self).__init__(unique_id, model)
        self.wealth = 1

    def move(self):
        possible_steps = self.model.grid.get_neighborhood(self.pos,
                                                          moore=True,
                                                          include_center=False)
        new_position = random.choice(possible_steps)

    def step(self):
        self.move()
        if self.wealth > 0:
            self.give_money()

    def getMoney(self):
        return self.wealth

    def getId(self):
        return self.unique_id

